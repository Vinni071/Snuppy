import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/app/theme/app_theme.dart';
import 'package:luminthor/features/editor/presentation/screens/editor_screen.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_controller.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_editor.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_keyboard_toolbar.dart';
import 'package:luminthor/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luminthor/features/workspace/presentation/viewmodels/workspace_view_model.dart';

Future<ProviderContainer> pumpEditor(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double keyboardHeight = 320,
  bool light = false,
  double fontSize = 14,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(settingsProvider.notifier).setFontSize(fontSize);
  final document = container.read(workspaceProvider.notifier).create(
        name: 'atalhos.lumi',
        source: 'var x = 1;',
      );
  container.read(editorProvider.notifier).openDocument(document);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: light ? AppTheme.lightTheme : AppTheme.darkTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const EditorScreen(),
    ),
  ));
  // The Execute button has a continuous pulse animation.
  await tester.pump(const Duration(seconds: 1));
  expect(find.byType(LumiKeyboardToolbar), findsNothing);
  await tester.tap(find.byType(TextField));
  await tester.pump();
  expect(tester.testTextInput.isVisible, isTrue);
  // Focus alone (e.g. with a hardware keyboard) must not show the toolbar.
  expect(find.byType(LumiKeyboardToolbar), findsNothing);
  tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('Shortcut insertion', () {
    late LumiCodeController controller;

    setUp(() => controller = LumiCodeController(text: 'var x = 1;'));
    tearDown(() => controller.dispose());

    test('inserts at the cursor and clears the IME composing range', () {
      controller.value = const TextEditingValue(
        text: 'var x = 1;',
        selection: TextSelection.collapsed(offset: 4),
        composing: TextRange(start: 4, end: 5),
      );
      controller.insertText('  ');
      expect(controller.text, 'var   x = 1;');
      expect(controller.selection.baseOffset, 6);
      expect(controller.value.composing, TextRange.empty);
    });

    test('replaces a reversed selection without changing surrounding code', () {
      controller.selection =
          const TextSelection(baseOffset: 5, extentOffset: 4);
      controller.insertText('total');
      expect(controller.text, 'var total = 1;');
      expect(controller.selection.baseOffset, 9);
    });

    test('places the cursor inside empty pairs', () {
      controller.selection = const TextSelection.collapsed(offset: 8);
      controller.insertText('(', suffix: ')');
      expect(controller.text, 'var x = ()1;');
      expect(controller.selection.baseOffset, 9);
    });

    test('wraps a selection and places the cursor before the suffix', () {
      controller.value = const TextEditingValue(
        text: '1 + 2',
        selection: TextSelection(baseOffset: 5, extentOffset: 0),
      );
      controller.insertText('print(', suffix: ');');
      expect(controller.text, 'print(1 + 2);');
      expect(controller.selection.baseOffset, 11);
    });

    test('appends safely when the selection is invalid or out of bounds', () {
      controller.insertText(';');
      expect(controller.text, 'var x = 1;;');
      controller.value = const TextEditingValue(
        text: 'x',
        selection: TextSelection.collapsed(offset: 20),
      );
      controller.insertText('"', suffix: '"');
      expect(controller.text, 'x""');
      expect(controller.selection.baseOffset, 2);
    });
  });

  for (final size in [
    const Size(390, 844),
    const Size(320, 568),
    const Size(740, 400),
  ]) {
    testWidgets('Toolbar fits above the keyboard at $size', (tester) async {
      final keyboardHeight = size.height < 500 ? 180.0 : 280.0;
      await pumpEditor(tester, size: size, keyboardHeight: keyboardHeight);
      final toolbar = find.byType(LumiKeyboardToolbar);
      expect(toolbar, findsOneWidget);
      final bounds = tester.getRect(toolbar);
      expect(bounds.bottom, lessThanOrEqualTo(size.height - keyboardHeight));
      expect(bounds.height, greaterThanOrEqualTo(48));
      expect(tester.getRect(find.byType(LumiCodeEditor)).bottom,
          lessThanOrEqualTo(bounds.top));
      expect(find.text('Saída'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Recolher teclado'));
      await tester.pumpAndSettle();
      expect(toolbar, findsNothing);
      expect(
          tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
          isFalse);
      tester.view.resetViewInsets();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Saída'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final scenario in [
    (size: const Size(844, 390), keyboard: 260.0),
    (size: const Size(740, 360), keyboard: 240.0),
    (size: const Size(640, 320), keyboard: 230.0),
  ]) {
    testWidgets(
        'Landscape typing stays usable with a ${scenario.keyboard}px keyboard',
        (tester) async {
      final container = await pumpEditor(tester,
          size: scenario.size, keyboardHeight: scenario.keyboard);
      final field = tester.widget<TextField>(find.byType(TextField));
      final bounds = tester.getRect(find.byType(LumiCodeEditor));
      expect(bounds.height,
          greaterThanOrEqualTo(field.style!.fontSize! * field.style!.height!));
      expect(bounds.bottom,
          lessThanOrEqualTo(scenario.size.height - scenario.keyboard));
      tester.testTextInput.updateEditingValue(const TextEditingValue(
        text: 'print("ação");',
        selection: TextSelection.collapsed(offset: 14),
      ));
      await tester.pump();
      expect(field.focusNode!.hasFocus, isTrue);
      expect(container.read(workspaceProvider).activeDocument!.source,
          'print("ação");');
      expect(tester.takeException(), isNull);
    });
  }

  for (final light in [false, true]) {
    testWidgets(
        'Rotation keeps the keyboard client and cursor active (light: $light)',
        (tester) async {
      final container =
          await pumpEditor(tester, light: light, keyboardHeight: 280);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      final originalState =
          tester.state<EditableTextState>(find.byType(EditableText));
      const source = 'var texto = "ação";\nprint(texto);';
      const selection = TextSelection(baseOffset: 13, extentOffset: 17);
      tester.testTextInput.updateEditingValue(const TextEditingValue(
        text: source,
        selection: selection,
      ));
      await tester.pump();

      for (final landscape in [true, false, true]) {
        tester.view.physicalSize =
            landscape ? const Size(844, 390) : const Size(390, 844);
        tester.view.viewInsets = FakeViewPadding(bottom: landscape ? 260 : 280);
        tester.view.viewPadding = landscape
            ? const FakeViewPadding(left: 28, right: 24, bottom: 16)
            : const FakeViewPadding(top: 24, bottom: 16);
        tester.view.padding = landscape
            ? const FakeViewPadding(left: 28, right: 24)
            : const FakeViewPadding(top: 24);
        await tester.pumpAndSettle();
        expect(tester.state<EditableTextState>(find.byType(EditableText)),
            same(originalState));
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller!.selection, selection);
        expect(field.focusNode!.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
        expect(tester.getSize(find.byType(LumiCodeEditor)).height,
            greaterThan(40));
        final caret = originalState.renderEditable
            .getLocalRectForCaret(const TextPosition(offset: 17));
        final position =
            originalState.renderEditable.localToGlobal(caret.center);
        expect(tester.getRect(find.byType(LumiCodeEditor)).contains(position),
            isTrue);
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.byKey(const ValueKey('lumi-shortcut-()')));
      await tester.pump();
      expect(container.read(workspaceProvider).activeDocument!.source,
          'var texto = "(ação)";\nprint(texto);');
      tester.testTextInput.enterText('print(42);');
      await tester.pump();
      expect(container.read(workspaceProvider).activeDocument!.source,
          'print(42);');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Large text and a tall landscape keyboard prioritize code input',
      (tester) async {
    final container = await pumpEditor(tester,
        size: const Size(740, 360),
        keyboardHeight: 240,
        fontSize: 22,
        textScale: 1.4);
    expect(find.byType(LumiKeyboardToolbar), findsNothing);
    expect(tester.getSize(find.byType(LumiCodeEditor)).height, greaterThan(60));
    tester.testTextInput.enterText('print(420);');
    await tester.pumpAndSettle();
    expect(container.read(workspaceProvider).activeDocument!.source,
        'print(420);');
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
        isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Shortcuts preserve focus, selection and autosave while scrolling',
      (tester) async {
    final container = await pumpEditor(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    field.controller!.selection =
        const TextSelection(baseOffset: 8, extentOffset: 9);
    await tester.tap(find.byKey(const ValueKey('lumi-shortcut-()')));
    await tester.pump();
    expect(field.controller!.text, 'var x = (1);');
    expect(field.controller!.selection.baseOffset, 10);
    expect(field.focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(container.read(editorProvider).source, 'var x = (1);');
    expect(container.read(workspaceProvider).activeDocument!.source,
        'var x = (1);');

    final printShortcut = find.byKey(const ValueKey('lumi-shortcut-print'));
    tester.testTextInput.updateEditingValue(const TextEditingValue(
      text: '42',
      selection: TextSelection(baseOffset: 0, extentOffset: 2),
    ));
    await tester.pump();
    await tester.ensureVisible(printShortcut);
    await tester.tap(printShortcut);
    await tester.pump();
    expect(field.controller!.text, 'print(42);');
    expect(field.controller!.selection.baseOffset, 8);
    expect(field.focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    tester.testTextInput.enterText('print(420);');
    await tester.pump();
    expect(container.read(workspaceProvider).activeDocument!.source,
        'print(420);');
    tester.view.resetViewInsets();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LumiKeyboardToolbar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search keyboard does not show code shortcuts', (tester) async {
    await pumpEditor(tester);
    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    expect(find.text('Buscar no arquivo'), findsOneWidget);
    expect(find.byType(LumiKeyboardToolbar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Leaving the editor dismisses code shortcuts', (tester) async {
    await pumpEditor(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    tester.widget<TabBarView>(find.byType(TabBarView)).controller!.animateTo(1);
    await tester.pumpAndSettle();
    expect(find.byType(LumiKeyboardToolbar), findsNothing);
    expect(field.focusNode!.hasFocus, isFalse);
    expect(tester.takeException(), isNull);
  });
}
