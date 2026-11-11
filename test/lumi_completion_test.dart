import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/app/theme/app_theme.dart';
import 'package:luminthor/features/editor/domain/lumi_completion.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_controller.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_editor.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_completion_popup.dart';

/// Completes at the `|` marker in [marked].
List<String> labelsAt(String marked) {
  final cursor = marked.indexOf('|');
  final source = marked.replaceFirst('|', '');
  return lumiCompletionsAt(source, cursor).items.map((i) => i.label).toList();
}

void main() {
  group('Candidates', () {
    test('keywords match the typed prefix, ignoring case', () {
      expect(labelsAt('pr|'), ['print']);
      expect(labelsAt('PR|'), ['print']);
      expect(labelsAt('wh|'), ['while']);
    });

    test('the word already typed in full is not suggested', () {
      expect(labelsAt('print|'), isEmpty);
      expect(labelsAt('var total = 1;\ntotal|'), isEmpty);
      expect(labelsAt('var a = 1;\nvar ab = 2;\na|'),
          containsAllInOrder(['ab', 'and']));
    });

    test('declared names come before keywords', () {
      expect(labelsAt('var fator = 2;\nf|'), ['fator', 'for', 'fn', 'false']);
    });

    test('reports where the prefix starts', () {
      final result = lumiCompletionsAt('var x = pri', 11);
      expect(result.start, 8);
    });
  });

  group('Positions without suggestions', () {
    for (final marked in [
      '// pri|',
      '/* pri| */',
      '/* pri|',
      'print("pri|");',
      'print("pri|',
      r'print("a\"pri|");',
      '|',
      'var x = 1; |',
      '12|',
      'pri|nt',
      'var pr|',
      'const pr|',
      'fn pr|',
      'for pr|',
      'fn soma(pr|',
      'fn soma(a, pr|',
    ]) {
      test(marked, () => expect(labelsAt(marked), isEmpty));
    }

    test('invalid cursors', () {
      expect(lumiCompletionsAt('pri', -1).isEmpty, isTrue);
      expect(lumiCompletionsAt('pri', 20).isEmpty, isTrue);
    });
  });

  group('Scope', () {
    test('a variable is only visible after its declaration', () {
      expect(labelsAt('to|\nvar total = 1;'), isEmpty);
    });

    test('block variables are not visible once the block closes', () {
      const block = 'if true {\n  var total = 1;\n  to|\n}';
      expect(labelsAt(block), ['total']);
      expect(labelsAt('if true {\n  var total = 1;\n}\nto|'), isEmpty);
    });

    test('outer variables stay visible inside blocks', () {
      expect(labelsAt('var total = 1;\nwhile true {\n  to|\n}'), ['total']);
    });

    test('parameters are visible only in the function body', () {
      const body = 'fn soma(alfa, beta) {\n  be|\n}';
      expect(labelsAt(body), ['beta']);
      expect(labelsAt('fn soma(alfa, beta) {\n}\nbe|'), isEmpty);
    });

    test('the for variable is visible in the body but not the iterable', () {
      expect(labelsAt('for item in lista {\n  it|\n}'), ['item']);
      expect(labelsAt('for item in it| {\n}'), isEmpty);
      expect(labelsAt('for item in lista {\n}\nit|'), isEmpty);
    });

    test('top-level functions are visible before their declaration', () {
      expect(labelsAt('so|\nfn somar(a) {\n}'), ['somar']);
    });

    test('nested functions are not offered, matching the analyzer', () {
      expect(labelsAt('fn fora() {\n  fn somar() {\n  }\n  so|\n}'), isEmpty);
    });

    test('an inner name shadows an outer one without duplicates', () {
      const source = 'var total = 1;\nfn f(total) {\n  to';
      final result = lumiCompletionsAt(source, source.length);
      expect(result.items.map((i) => i.label), ['total']);
      expect(result.items.single.detail, 'Parâmetro');
    });

    test('commented and quoted declarations are ignored', () {
      expect(labelsAt('// var total = 1;\nto|'), isEmpty);
      expect(labelsAt('/* var total = 1; */\nto|'), isEmpty);
      expect(labelsAt('print("var total = 1;");\nto|'), isEmpty);
    });

    test('stray closing braces do not break the scan', () {
      expect(labelsAt('}\n}\nvar total = 1;\nto|'), ['total']);
    });
  });

  group('Function insertion', () {
    test('adds parentheses unless they are already there', () {
      final bare = lumiCompletionsAt('fn somar() {\n}\nso', 17).items.single;
      expect((bare.text, bare.suffix), ('somar(', ')'));
      final called =
          lumiCompletionsAt('fn somar() {\n}\nso(1)', 17).items.single;
      expect((called.text, called.suffix), ('somar', ''));
    });
  });

  group('Editor popup', () {
    late LumiCodeController controller;
    late FocusNode focusNode;
    late List<String> changes;

    Future<void> pumpEditor(
      WidgetTester tester, {
      bool readOnly = false,
      double height = 400,
    }) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: height,
            child: LumiCodeEditor(
              controller: controller,
              focusNode: focusNode,
              style: AppTheme.editorTextStyle,
              onChanged: changes.add,
              readOnly: readOnly,
            ),
          ),
        ),
      ));
      await tester.tap(find.byType(TextField));
      await tester.pump();
    }

    Future<void> type(WidgetTester tester, String text) async {
      tester.testTextInput.updateEditingValue(TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ));
      await tester.pump();
    }

    final popup = find.byType(LumiCompletionPopup);
    Finder item(String label) => find.byKey(ValueKey('lumi-completion-$label'));

    setUp(() {
      controller = LumiCodeController();
      focusNode = FocusNode();
      changes = [];
    });
    tearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('opens while typing and tapping inserts with autosave',
        (tester) async {
      await pumpEditor(tester);
      expect(popup, findsNothing);
      await type(tester, 'pri');
      expect(popup, findsOneWidget);

      await tester.tap(item('print'));
      await tester.pump();
      expect(controller.text, 'print();');
      expect(controller.selection.baseOffset, 6);
      expect(changes.last, 'print();');
      expect(popup, findsNothing);
      expect(focusNode.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('accepting does not reopen on a longer sibling',
        (tester) async {
      await pumpEditor(tester);
      await type(tester, 'var ab = 2;\nvar abc = 3;\na');
      await tester.tap(item('ab'));
      await tester.pump();
      expect(controller.text, endsWith('\nab'));
      expect(popup, findsNothing);
    });

    testWidgets('arrow keys choose and Enter accepts without a newline',
        (tester) async {
      await pumpEditor(tester);
      await type(tester, 'f');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controller.text, 'fn ');
      expect(changes.last, 'fn ');
    });

    testWidgets('arrow keys wrap around and Tab accepts', (tester) async {
      await pumpEditor(tester);
      await type(tester, 'f');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(controller.text, 'false');
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('selection scrolls into view past the visible items',
        (tester) async {
      await pumpEditor(tester);
      await type(tester,
          'var a1 = 1;\nvar a2 = 1;\nvar a3 = 1;\nvar a4 = 1;\nvar a5 = 1;\nvar a6 = 1;\na');
      expect(item('a6').hitTestable(), findsOneWidget);
      expect(item('a1').hitTestable(), findsNothing);
      for (var i = 0; i < 6; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
      }
      await tester.pump();
      expect(item('a6').hitTestable(), findsNothing);
      expect(item('a1').hitTestable(), findsOneWidget);
    });

    testWidgets('Escape closes it and keys go back to the editor',
        (tester) async {
      await pumpEditor(tester);
      await type(tester, 'pri');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(popup, findsNothing);
      expect(controller.text, 'pri');
      await type(tester, 'prin');
      expect(popup, findsOneWidget);
    });

    testWidgets('moving the cursor closes it', (tester) async {
      await pumpEditor(tester);
      await type(tester, 'pri');
      controller.selection = const TextSelection.collapsed(offset: 1);
      await tester.pump();
      expect(popup, findsNothing);
    });

    testWidgets('backspace refines an open list but does not open one',
        (tester) async {
      await pumpEditor(tester);
      await type(tester, 'pri');
      await type(tester, 'pr');
      expect(popup, findsOneWidget);
      await type(tester, 'print(x); ');
      expect(popup, findsNothing);
      await type(tester, 'print(x);');
      await type(tester, 'pri');
      expect(popup, findsNothing);
    });

    testWidgets('loading new source does not open it', (tester) async {
      await pumpEditor(tester);
      controller.text = 'var x = 1;\npri';
      await tester.pump();
      expect(popup, findsNothing);
    });

    testWidgets('losing focus closes it', (tester) async {
      await pumpEditor(tester);
      await type(tester, 'pri');
      focusNode.unfocus();
      await tester.pump();
      expect(popup, findsNothing);
    });

    testWidgets('read-only editors do not suggest', (tester) async {
      await pumpEditor(tester, readOnly: true);
      controller.value = const TextEditingValue(
        text: 'pri',
        selection: TextSelection.collapsed(offset: 3),
      );
      await tester.pump();
      expect(popup, findsNothing);
    });

    testWidgets('stays inside the editor at the bottom of a short viewport',
        (tester) async {
      await pumpEditor(tester, height: 200);
      await type(tester, '${'\n' * 6}f');
      expect(popup, findsOneWidget);
      final editor = tester.getRect(find.byType(LumiCodeEditor));
      final bounds = tester.getRect(popup);
      expect(bounds.top, greaterThanOrEqualTo(editor.top));
      expect(bounds.bottom, lessThanOrEqualTo(editor.bottom));
      expect(bounds.right, lessThanOrEqualTo(editor.right));
      expect(tester.takeException(), isNull);
    });

    testWidgets('keys stay with the editor when there is no room to draw it',
        (tester) async {
      await pumpEditor(tester, height: 30);
      await type(tester, 'pri');
      expect(popup, findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controller.text, 'pri');
      expect(tester.takeException(), isNull);
    });
  });
}
