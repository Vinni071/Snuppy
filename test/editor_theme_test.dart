import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/router/app_router.dart';
import 'package:luminthor/core/theme/app_theme.dart';
import 'package:luminthor/features/editor/presentation/editor_screen.dart';
import 'package:luminthor/features/editor/presentation/providers/editor_provider.dart';
import 'package:luminthor/features/editor/presentation/widgets/console_panel.dart';
import 'package:luminthor/features/editor/presentation/widgets/lumi_code_editor.dart';
import 'package:luminthor/features/home/presentation/providers/workspace_provider.dart';
import 'package:luminthor/features/settings/presentation/providers/settings_provider.dart';
import 'package:luminthor/src/rust/api.dart';
import 'package:luminthor/src/rust/ast.dart';
import 'package:luminthor/src/rust/errors.dart';
import 'package:luminthor/src/rust/interpreter.dart';
import 'package:luminthor/src/rust/interpreter/environment.dart';
import 'package:luminthor/src/rust/lexer.dart';

import 'widget_test.dart' show pumpApp;

double contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
}

Color editorBackground(WidgetTester tester) => tester
    .widgetList<Container>(find.ancestor(
        of: find.byType(LumiCodeEditor), matching: find.byType(Container)))
    .map((container) => container.decoration)
    .whereType<BoxDecoration>()
    .first
    .color!;

class ThemeTestApp extends ConsumerWidget {
  const ThemeTestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ref.watch(settingsProvider).themeMode,
        home: const EditorScreen(),
      );
}

const result = CompileResult(
  tokens: [
    TokenInfo(
        tokenType: 'Keyword(print)',
        lexeme: 'print',
        line: 1,
        column: 1,
        start: 0,
        end: 5),
  ],
  ast: AstNodeView(
    id: 0,
    label: 'Programa',
    nodeType: 'program',
    children: [],
    span: Span(start: 0, end: 10, line: 1, column: 1),
  ),
  output: '42\n',
  errors: [],
  memoryState: {},
  executionTrace: [
    ExecutionStep(
      line: 1,
      column: 1,
      action: 'print',
      description: 'Imprime 42',
      variables: {'x': Value.int(42)},
      scopes: [
        ScopeSnapshot(
            depth: 0, isFunctionScope: false, variables: {'x': Value.int(42)}),
      ],
      scopeDepth: 0,
      callStack: ['<main>'],
      output: '42\n',
    ),
  ],
  warnings: [],
  success: true,
);

void main() {
  testWidgets('Editor bar switches tabs, opens settings, clears the content',
      (tester) async {
    await pumpApp(tester, size: const Size(390, 844));
    AppRouter.router.go('/editor');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final tabs = tester.widget<TabBarView>(find.byType(TabBarView)).controller!;
    final bar = find.byKey(const ValueKey('home-dock-1'));
    final workspace = find.byKey(const ValueKey('editor-workspace'));
    expect(tester.getBottomLeft(workspace).dy,
        lessThanOrEqualTo(tester.getTopLeft(bar).dy));

    await tester.tap(find.text('Tokens'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tabs.index, 1);
    expect(find.byKey(const ValueKey('home-dock-active-1')), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Aparência'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(1440, 1100), const Size(390, 844)]) {
    testWidgets('Home theme reaches editor and preserves editing at $size',
        (tester) async {
      final container = await pumpApp(tester, size: size);
      await tester.tap(find.byTooltip('Ativar tema claro'));
      await tester.pumpAndSettle();
      final source = [
        'var x = 42;',
        'print("ação");',
        '// comentário',
        ...List.generate(80, (index) => 'print($index);'),
      ].join('\n');
      final document = container.read(workspaceProvider.notifier).create(
            name: 'tema.lumi',
            source: source,
          );
      container.read(editorProvider.notifier).openDocument(document);
      AppRouter.router.go('/editor');
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      final field = tester.widget<TextField>(find.byType(TextField));
      final background = editorBackground(tester);
      expect(background.computeLuminance(), greaterThan(0.9));
      expect(contrast(field.style!.color!, background), greaterThan(4.5));
      expect(contrast(field.cursorColor!, background), greaterThan(4.5));
      final spans = tester
          .state<EditableTextState>(find.byType(EditableText))
          .renderEditable
          .text as TextSpan;
      for (final token in ['var', '42', '"ação"', '// comentário']) {
        final span = spans.children!
            .whereType<TextSpan>()
            .firstWhere((span) => span.text == token);
        expect(contrast(span.style!.color!, background), greaterThan(4.5),
            reason: 'Light syntax contrast for $token');
      }
      final number =
          tester.widget<Text>(find.byKey(const ValueKey('editor-line-1')));
      expect(contrast(number.style!.color!, background), greaterThan(4.5));

      await tester.showKeyboard(find.byType(TextField));
      field.controller!.selection =
          const TextSelection(baseOffset: 4, extentOffset: 5);
      await tester.pump();
      await tester.drag(find.byType(TextField), const Offset(0, -300));
      await tester.pump(const Duration(seconds: 1));
      final selection = field.controller!.selection;
      final scroll = field.scrollController!.offset;
      expect(scroll, greaterThan(0));

      for (final light in [false, true]) {
        container.read(settingsProvider.notifier).toggleTheme();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        final nextField = tester.widget<TextField>(find.byType(TextField));
        expect(identical(nextField.controller, field.controller), isTrue);
        expect(nextField.controller!.text, source);
        expect(nextField.controller!.selection, selection);
        expect(nextField.focusNode!.hasFocus, isTrue);
        expect(nextField.scrollController!.offset, closeTo(scroll, 1));
        expect(editorBackground(tester).computeLuminance(),
            light ? greaterThan(0.9) : lessThan(0.1));
      }
      expect(container.read(workspaceProvider).activeDocument!.source, source);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Light theme covers console, tokens, AST and debug highlight',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(overrides: [
      sourceCompilerProvider.overrideWithValue((_) async => result),
    ]);
    addTearDown(container.dispose);
    container.read(settingsProvider.notifier).toggleTheme();
    container.read(editorProvider.notifier).updateSource('print(42);');
    await container.read(editorProvider.notifier).runCompilation();
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const ThemeTestApp()));
    await tester.pump(const Duration(seconds: 1));

    final output = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(contrast(output.style!.color!, editorBackground(tester)),
        greaterThan(4.5));
    final console = tester.widget<Container>(find
        .descendant(
            of: find.byType(ConsolePanel), matching: find.byType(Container))
        .first);
    expect((console.decoration as BoxDecoration).color!.computeLuminance(),
        greaterThan(0.9));

    final tabs = tester.widget<TabBarView>(find.byType(TabBarView)).controller!;
    for (final entry in {1: 'print', 2: 'Programa'}.entries) {
      tabs.animateTo(entry.key);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      final card = tester.widget<Card>(find.byType(Card).first);
      expect(card.color!.computeLuminance(), greaterThan(0.9));
      final label = find.text(entry.value, findRichText: true);
      expect(label, findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    container.read(editorProvider.notifier).startDebugging();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final variable = tester.widget<Text>(find.text('x'));
    expect(contrast(variable.style!.color!, Colors.white), greaterThan(4.5));
    expect(
        Theme.of(tester.element(find.byType(Card).first))
            .cardTheme
            .color!
            .computeLuminance(),
        greaterThan(0.9));
    expect(find.text('42\n'), findsOneWidget);

    tabs.animateTo(0);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final highlight = tester.widget<Container>(find.descendant(
        of: find.byKey(const ValueKey('debug-line-highlight')),
        matching: find.byType(Container)));
    final decoration = highlight.decoration as BoxDecoration;
    final highlightedBackground =
        Color.alphaBlend(decoration.color!, editorBackground(tester));
    final number =
        tester.widget<Text>(find.byKey(const ValueKey('editor-line-1')));
    expect(contrast(number.style!.color!, highlightedBackground),
        greaterThan(4.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Light diagnostics keep errors, source and suggestions readable',
      (tester) async {
    final container = ProviderContainer(overrides: [
      sourceCompilerProvider.overrideWithValue((_) async => const CompileResult(
            tokens: [],
            output: '',
            errors: [
              CompileError.semanticError(
                message: 'Variável não declarada: y',
                suggestion: 'Você quis dizer x?',
                span: Span(start: 6, end: 7, line: 1, column: 7),
              ),
            ],
            memoryState: {},
            executionTrace: [],
            warnings: [],
            success: false,
          )),
    ]);
    addTearDown(container.dispose);
    container.read(settingsProvider.notifier).toggleTheme();
    container.read(editorProvider.notifier).updateSource('print(y);');
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const ThemeTestApp()));
    await container.read(editorProvider.notifier).runCompilation();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    for (final text in [
      'Erro Semântico',
      'Variável não declarada: y',
      'print(y);',
      'Dica: Você quis dizer x?',
    ]) {
      final label = tester.widget<Text>(find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == text));
      expect(contrast(label.style!.color!, Colors.white), greaterThan(4.5));
    }
    expect(tester.takeException(), isNull);
  });
}
