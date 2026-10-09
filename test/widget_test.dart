import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/constants/editor_templates.dart';
import 'package:luminthor/core/router/app_router.dart';
import 'package:luminthor/features/editor/presentation/providers/editor_provider.dart';
import 'package:luminthor/features/home/data/workspace_file_service.dart';
import 'package:luminthor/features/home/presentation/providers/workspace_provider.dart';
import 'package:luminthor/features/settings/presentation/providers/settings_provider.dart';
import 'package:luminthor/main.dart';

class FakeFileService extends WorkspaceFileService {
  ImportedSource? nextFile;
  bool fail = false;
  String? exportedName;
  String? exportedSource;

  @override
  Future<ImportedSource?> open() async {
    if (fail) throw const FormatException('Invalid UTF-8');
    return nextFile;
  }

  @override
  Future<bool> export({required String name, required String source}) async {
    exportedName = name;
    exportedSource = source;
    return true;
  }
}

Future<ProviderContainer> pumpApp(WidgetTester tester,
    {Size size = const Size(1440, 1100), FakeFileService? fileService}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(overrides: [
    if (fileService != null)
      workspaceFileServiceProvider.overrideWithValue(fileService),
  ]);
  addTearDown(container.dispose);
  AppRouter.router.go('/');
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MyApp(showSplash: false),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  for (final size in [
    const Size(1440, 1100),
    const Size(1040, 500),
    const Size(960, 900),
    const Size(390, 844),
    const Size(320, 568),
  ]) {
    testWidgets('Home adapts to ${size.width.toInt()}px in both themes',
        (tester) async {
      final container = await pumpApp(tester, size: size);
      expect(find.text('Seu próximo código\ncomeça aqui.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      container.read(settingsProvider.notifier).toggleTheme();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('New file starts blank, autosaves, reopens and exports',
      (tester) async {
    final files = FakeFileService();
    final container = await pumpApp(tester, fileService: files);
    await tester.tap(find.byKey(const ValueKey('hero-new-file')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('new-file-name')), 'teste');
    await tester.tap(find.text('Criar arquivo'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('teste.lumi'), findsOneWidget);
    expect(container.read(editorProvider).source, isEmpty);
    await tester.enterText(find.byType(TextField), 'print(42);');
    await tester.pump();
    expect(
        container.read(workspaceProvider).activeDocument!.source, 'print(42);');
    await tester.tap(find.byTooltip('Exportar arquivo'));
    await tester.pump();
    expect(files.exportedName, 'teste.lumi');
    expect(files.exportedSource, 'print(42);');
    await tester.tap(find.byTooltip('Voltar à Home'));
    await tester.pumpAndSettle();
    expect(find.text('teste.lumi'), findsOneWidget);
    await tester.tap(find.text('teste.lumi'));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(editorProvider).source, 'print(42);');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Templates filter by category and open a separate document',
      (tester) async {
    final container = await pumpApp(tester);
    container
        .read(workspaceProvider.notifier)
        .create(name: 'anterior.lumi', source: 'print(1);');
    await tester.tap(find.text('Explorar templates'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Funções'));
    await tester.pumpAndSettle();
    expect(find.text('Funções e escopos'), findsOneWidget);
    expect(find.text('Olá, variáveis'), findsNothing);
    await tester.tap(find.text('Funções e escopos'));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(editorProvider).source,
        EditorTemplates.templates[3].code);
    expect(container.read(workspaceProvider).documents, hasLength(2));
    expect(
        container.read(workspaceProvider).documents.last.source, 'print(1);');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('funcoes.lumi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Import opens selected code; cancellation and errors keep drafts',
      (tester) async {
    final files = FakeFileService();
    final container = await pumpApp(tester, fileService: files);
    await tester.tap(find.text('Abrir arquivo'));
    await tester.pumpAndSettle();
    expect(container.read(workspaceProvider).documents, isEmpty);
    files.fail = true;
    await tester.tap(find.text('Abrir arquivo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('UTF-8'), findsOneWidget);
    expect(container.read(workspaceProvider).documents, isEmpty);
    files.fail = false;
    files.nextFile =
        const ImportedSource(name: 'importado.lumi', source: 'print("Olá");');
    await tester.tap(find.text('Abrir arquivo'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('importado.lumi'), findsOneWidget);
    expect(container.read(editorProvider).source, 'print("Olá");');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search finds recent files and matching templates',
      (tester) async {
    final container = await pumpApp(tester);
    container
        .read(workspaceProvider.notifier)
        .create(name: 'meu-fatorial.lumi', source: 'print(120);');
    await tester.enterText(find.byType(TextField), 'fatorial');
    await tester.pumpAndSettle();
    expect(find.text('meu-fatorial.lumi'), findsOneWidget);
    expect(find.text('Repetições e fatorial'), findsOneWidget);
    expect(find.text('Olá, variáveis'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
