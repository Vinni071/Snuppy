import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/theme/app_theme.dart';
import 'package:luminthor/features/editor/domain/compiler_state.dart';
import 'package:luminthor/features/editor/presentation/providers/editor_provider.dart';
import 'package:luminthor/features/editor/presentation/editor_screen.dart';
import 'package:luminthor/features/editor/presentation/widgets/console_panel.dart';
import 'package:luminthor/features/editor/presentation/widgets/debugger_tab.dart';
import 'package:luminthor/features/editor/presentation/widgets/editor_tab.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_controller.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_editor.dart';
import 'package:luminthor/src/rust/api.dart';
import 'package:luminthor/src/rust/ast.dart';
import 'package:luminthor/src/rust/errors.dart';
import 'package:luminthor/src/rust/interpreter.dart';
import 'package:luminthor/src/rust/interpreter/environment.dart';

class TestEditorNotifier extends EditorNotifier {
  final CompilerState initial;
  TestEditorNotifier(this.initial);

  @override
  CompilerState build() => initial;
}

CompileResult compileResult(List<ExecutionStep> trace,
        {List<CompileError> errors = const []}) =>
    CompileResult(
      tokens: const [],
      output: trace.map((step) => step.output ?? '').join(),
      errors: errors,
      memoryState: const {},
      executionTrace: trace,
      warnings: const [],
      success: errors.isEmpty,
    );

ExecutionStep step(int line,
        {String? output, List<ScopeSnapshot>? scopes, String? action}) =>
    ExecutionStep(
      line: line,
      column: 1,
      action: action ?? (output == null ? 'assignment' : 'print'),
      description: 'Passo na linha $line',
      variables: const {},
      scopes: scopes ??
          const [
            ScopeSnapshot(depth: 0, isFunctionScope: false, variables: {})
          ],
      scopeDepth: (scopes?.length ?? 1) - 1,
      callStack: const ['<main>'],
      output: output,
    );

Future<ProviderContainer> pumpEditorState(
    WidgetTester tester, CompilerState state, Widget child) async {
  final container = ProviderContainer(overrides: [
    editorProvider.overrideWith(() => TestEditorNotifier(state)),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 350));
  return container;
}

void main() {
  testWidgets('Line numbers include blank and trailing lines and follow edits',
      (tester) async {
    final controller = LumiCodeController(text: 'print("á");\n\n');
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LumiCodeEditor(
          controller: controller,
          focusNode: focus,
          style: AppTheme.editorTextStyle,
          onChanged: (_) {},
        ),
      ),
    ));
    for (var line = 1; line <= 3; line++) {
      expect(find.byKey(ValueKey('editor-line-$line')), findsOneWidget);
    }
    controller.text = '';
    await tester.pump();
    expect(find.byKey(const ValueKey('editor-line-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('editor-line-2')), findsNothing);
    controller.text = 'a\nb\nc\nd';
    await tester.pump();
    expect(find.byKey(const ValueKey('editor-line-4')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gutter stays aligned with wrapped source and debug highlight',
      (tester) async {
    final source = '// ${'ação ' * 25}\n\nprint(1);';
    final controller = LumiCodeController(text: source);
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 250,
          height: 400,
          child: LumiCodeEditor(
            controller: controller,
            focusNode: focus,
            style: AppTheme.editorTextStyle.copyWith(fontSize: 18),
            highlightedLine: 1,
            readOnly: true,
            onChanged: (_) {},
          ),
        ),
      ),
    ));
    await tester.pump();
    final editable = tester
        .state<EditableTextState>(find.byType(EditableText))
        .renderEditable;
    final offset = source.indexOf('print');
    final caret = editable.getLocalRectForCaret(TextPosition(offset: offset));
    final caretTop = editable.localToGlobal(caret.topLeft).dy;
    final numberTop =
        tester.getTopLeft(find.byKey(const ValueKey('editor-line-3'))).dy;
    expect(numberTop, closeTo(caretTop, 4));
    final highlight =
        tester.getRect(find.byKey(const ValueKey('debug-line-highlight')));
    final secondLineTop =
        tester.getTopLeft(find.byKey(const ValueKey('editor-line-2'))).dy;
    expect(highlight.bottom, closeTo(secondLineTop, 1));
    expect(highlight.height, greaterThan(50));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Editor highlights and reveals the selected debug line, then clears it',
      (tester) async {
    final source = List.generate(60, (index) => 'print($index);').join('\n');
    final controller = LumiCodeController(text: source);
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    final state = CompilerState(
      source: source,
      compileResult: compileResult([step(1), step(55)]),
      isLoading: false,
      isDebugging: true,
      currentStepIndex: 0,
    );
    final container = await pumpEditorState(
        tester,
        state,
        EditorTab(
          codeController: controller,
          focusNode: focus,
          keyboardVisible: true,
        ));
    final notifier = container.read(editorProvider.notifier);
    final editor = find.byType(LumiCodeEditor);
    notifier.goToStep(1);
    await tester.pump();
    await tester.pump();
    expect(tester.widget<LumiCodeEditor>(editor).highlightedLine, 55);
    expect(find.byKey(const ValueKey('editor-line-55')), findsOneWidget);
    expect(
        tester
            .getRect(find.byKey(const ValueKey('debug-line-highlight')))
            .overlaps(tester.getRect(editor)),
        isTrue);
    notifier.stepBackward();
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('editor-line-1')), findsOneWidget);
    notifier.stopDebugging();
    await tester.pump();
    expect(find.byKey(const ValueKey('debug-line-highlight')), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Debugger shows equal variable names in separate scopes and cumulative output',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const scopes = [
      ScopeSnapshot(
          depth: 0, isFunctionScope: false, variables: {'x': Value.int(1)}),
      ScopeSnapshot(
          depth: 1, isFunctionScope: true, variables: {'x': Value.int(2)}),
      ScopeSnapshot(
          depth: 2, isFunctionScope: false, variables: {'x': Value.int(3)}),
    ];
    final state = CompilerState(
      source: '',
      compileResult: compileResult([
        step(1, output: 'primeiro\n'),
        step(2, scopes: scopes),
        step(3, output: 'último\n')
      ]),
      isLoading: false,
      isDebugging: true,
      currentStepIndex: 1,
    );
    final container = await pumpEditorState(tester, state, const DebuggerTab());
    expect(find.text('Escopo global'), findsOneWidget);
    expect(find.text('Escopo de função (nível 1)'), findsOneWidget);
    expect(find.text('Escopo de bloco (nível 2)'), findsOneWidget);
    expect(find.text('x'), findsNWidgets(3));
    final output = find.text('primeiro\n');
    await tester.ensureVisible(output);
    expect(output, findsOneWidget);
    expect(find.text('primeiro\núltimo\n'), findsNothing);
    container.read(editorProvider.notifier).goToStep(2);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('primeiro\núltimo\n'), findsOneWidget);
    container.read(editorProvider.notifier).goToStep(0);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('primeiro\n'), findsOneWidget);
    expect(find.text('primeiro\núltimo\n'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Console uses output through the current debug step',
      (tester) async {
    final state = CompilerState(
      source: '',
      compileResult: compileResult(
          [step(1, output: 'a\n'), step(2), step(3, output: 'b\n')]),
      isLoading: false,
      isDebugging: true,
      currentStepIndex: 1,
    );
    final container =
        await pumpEditorState(tester, state, const ConsolePanel());
    expect(find.text('a\n'), findsOneWidget);
    container.read(editorProvider.notifier).stepForward();
    await tester.pump();
    expect(find.text('a\nb\n'), findsOneWidget);
    container.read(editorProvider.notifier).stepBackward();
    await tester.pump();
    expect(find.text('a\n'), findsOneWidget);
  });

  testWidgets('Diagnostics display Unicode columns', (tester) async {
    final state = CompilerState(
      source: 'print("á"); @',
      compileResult: compileResult([], errors: [
        const CompileError.lexerError(
          message: "Caractere ou literal inválido: '@'",
          span: Span(start: 13, end: 14, line: 1, column: 13),
        ),
      ]),
      isLoading: false,
      isDebugging: false,
      currentStepIndex: -1,
    );
    await pumpEditorState(tester, state, const ConsolePanel());
    await tester.tap(find.text('Diagnósticos'));
    await tester.pump();
    expect(find.text('Linha 1, Coluna 13'), findsOneWidget);
    expect(find.text('${' ' * 12}^'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A single-step trace keeps the timeline valid', (tester) async {
    final state = CompilerState(
      source: 'print(1);',
      compileResult: compileResult([step(1, output: '1\n')]),
      isLoading: false,
      isDebugging: true,
      currentStepIndex: 0,
    );
    await pumpEditorState(tester, state, const DebuggerTab());
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Debugger action labels fit a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = CompilerState(
      source: 'var x = 1;',
      compileResult: compileResult([
        step(1, action: 'var_decl'),
      ]),
      isLoading: false,
      isDebugging: true,
      currentStepIndex: 0,
    );
    await pumpEditorState(tester, state, const DebuggerTab());
    expect(find.text('DECLARAÇÃO DE VARIÁVEL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Changing debug steps keeps the editor tab selected',
      (tester) async {
    final state = CompilerState(
      source: 'var x = 1;\nprint(x);',
      compileResult: compileResult([step(1), step(2, output: '1\n')]),
      isLoading: false,
      isDebugging: false,
      currentStepIndex: -1,
    );
    final container =
        await pumpEditorState(tester, state, const EditorScreen());
    final notifier = container.read(editorProvider.notifier);
    notifier.startDebugging();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final tabs = tester.widget<TabBarView>(find.byType(TabBarView)).controller!;
    expect(tabs.index, 3);
    tabs.animateTo(0);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    notifier.stepForward();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(tabs.index, 0);
    expect(
        tester
            .widget<LumiCodeEditor>(find.byType(LumiCodeEditor))
            .highlightedLine,
        2);
    expect(tester.takeException(), isNull);
  });
}
