import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:luminthor/features/editor/presentation/providers/editor_provider.dart';
import 'package:luminthor/features/home/presentation/providers/workspace_provider.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('luminthor-workspace-');
    Hive.init(directory.path);
    await Hive.openBox('ide_box');
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('Independent files, including empty code, survive closing and reopening',
      () async {
    var container = ProviderContainer();
    final workspace = container.read(workspaceProvider.notifier);
    final first = workspace.create(name: 'primeiro.lumi', source: 'print(1);');
    workspace.create(name: 'vazio.lumi');
    container.read(editorProvider.notifier).updateSource('print(2);');
    container.read(editorProvider.notifier).openDocument(first);
    expect(container.read(editorProvider).source, 'print(1);');
    container.read(editorProvider.notifier).updateSource('');
    await Hive.box('ide_box').flush();
    container.dispose();
    await Hive.close();
    await Hive.openBox('ide_box');
    container = ProviderContainer();
    expect(container.read(workspaceProvider).documents, hasLength(2));
    expect(container.read(editorProvider).source, isEmpty);
    expect(
        container.read(workspaceProvider).documents.last.source, 'print(2);');
    container.dispose();
  });

  test('Previous saved code migrates without being lost or duplicated',
      () async {
    await Hive.box('ide_box').put('source_code', 'print("rascunho antigo");');
    var container = ProviderContainer();
    expect(
        container.read(workspaceProvider).documents.single.name, 'Editor.lumi');
    expect(container.read(editorProvider).source, 'print("rascunho antigo");');
    await Hive.box('ide_box').flush();
    container.dispose();
    container = ProviderContainer();
    expect(container.read(workspaceProvider).documents, hasLength(1));
    container.dispose();
  });
}
