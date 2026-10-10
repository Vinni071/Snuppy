import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/theme/app_theme.dart';
import 'package:luminthor/features/editor/presentation/editor_screen.dart';
import 'package:luminthor/features/editor/presentation/providers/editor_provider.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_controller.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_keyboard_toolbar.dart';
import 'package:luminthor/features/home/presentation/providers/workspace_provider.dart';

Future<ProviderContainer> pumpEditor(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double keyboardHeight = 320,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final document = container.read(workspaceProvider.notifier).create(
        name: 'atalhos.lumi',
        source: 'var x = 1;',
      );
  container.read(editorProvider.notifier).openDocument(document);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(theme: AppTheme.darkTheme, home: const EditorScreen()),
  ));
  // The Execute button has a continuous pulse animation.
  await tester.pump(const Duration(seconds: 1));
  expect(find.byType(LumiKeyboardToolbar), findsNothing);
  await tester.showKeyboard(find.byType(TextField));
  await tester.pump();
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
      expect(bounds.bottom, size.height - keyboardHeight - 10);
      expect(bounds.height, 56);
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
