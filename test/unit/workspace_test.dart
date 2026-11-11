import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminthor/core/storage/key_value_store.dart';
import 'package:luminthor/features/editor/presentation/viewmodels/editor_view_model.dart';
import 'package:luminthor/features/workspace/data/mappers/workspace_document_mapper.dart';
import 'package:luminthor/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:luminthor/features/workspace/presentation/viewmodels/workspace_view_model.dart';

import '../helpers/in_memory_key_value_store.dart';

void main() {
  final document = WorkspaceDocument(
    id: 'a',
    name: 'a.lumi',
    source: 'print(1);',
    updatedAt: DateTime.utc(2026, 1, 2, 3, 4),
    origin: DocumentOrigin.imported,
  );

  group('WorkspaceDocumentMapper', () {
    test('round-trips every field', () {
      final restored = WorkspaceDocumentMapper.fromMap(
          WorkspaceDocumentMapper.toMap(document));
      expect(restored.id, document.id);
      expect(restored.name, document.name);
      expect(restored.source, document.source);
      expect(restored.updatedAt, document.updatedAt);
      expect(restored.origin, document.origin);
    });

    test('defaults the origin of entries saved before it existed', () {
      final map = WorkspaceDocumentMapper.toMap(document)..remove('origin');
      expect(WorkspaceDocumentMapper.fromMap(map).origin,
          WorkspaceDocument.defaultOrigin);
    });
  });

  group('LocalWorkspaceRepository', () {
    test('skips corrupt entries instead of losing every file', () {
      final store = InMemoryKeyValueStore({
        LocalWorkspaceRepository.documentsKey: [
          WorkspaceDocumentMapper.toMap(document),
          {'id': 'quebrado'},
          'lixo',
        ],
      });
      final workspace = LocalWorkspaceRepository(store).load();
      expect(workspace.documents.map((d) => d.id), ['a']);
      expect(workspace.activeId, 'a');
    });

    test('migrates the legacy single-file draft once', () async {
      final store = InMemoryKeyValueStore(
          {LocalWorkspaceRepository.legacySourceKey: 'print("velho");'});
      final first = LocalWorkspaceRepository(store).load();
      await pumpEventQueue();
      final second = LocalWorkspaceRepository(store).load();

      expect(first.activeDocument?.source, 'print("velho");');
      expect(first.activeDocument?.origin, DocumentOrigin.legacy);
      expect(second.documents, hasLength(1));
    });
  });

  group('Workspace', () {
    test('activate moves a document to the top without duplicating it', () {
      final other = WorkspaceDocument(
          id: 'b', name: 'b.lumi', source: '', updatedAt: DateTime(2026));
      final workspace = Workspace(documents: [other, document], activeId: 'b')
          .activate(document.copyWith(source: 'print(2);'));
      expect(workspace.documents.map((d) => d.id), ['a', 'b']);
      expect(workspace.activeDocument?.source, 'print(2);');
    });

    test('ensureLumiExtension appends the extension only when missing', () {
      expect(ensureLumiExtension('ola'), 'ola.lumi');
      expect(ensureLumiExtension('Ola.LUMI'), 'Ola.LUMI');
    });
  });

  group('EditorNotifier document flows', () {
    late InMemoryKeyValueStore store;
    late ProviderContainer container;

    setUp(() {
      store = InMemoryKeyValueStore();
      container = ProviderContainer(
          overrides: [keyValueStoreProvider.overrideWithValue(store)]);
    });

    tearDown(() => container.dispose());

    test('createDocument opens the new file and persists it', () async {
      container
          .read(editorProvider.notifier)
          .createDocument(name: 'novo.lumi', source: 'print(3);');
      await pumpEventQueue();

      expect(container.read(editorProvider).source, 'print(3);');
      expect(
          container.read(workspaceProvider).activeDocument?.name, 'novo.lumi');
      expect(store.values[LocalWorkspaceRepository.documentsKey], hasLength(1));
    });

    test('openOrCreateDocument reuses the lesson file and keeps edits', () {
      final editor = container.read(editorProvider.notifier);
      final origin = DocumentOrigin.lesson('licao-1');
      final created = editor.openOrCreateDocument(
          name: 'licao-1.lumi', source: 'print(1);', origin: origin);
      editor.updateSource('print("editado");');
      editor.createDocument(name: 'outro.lumi');

      final reopened = editor.openOrCreateDocument(
          name: 'licao-1.lumi', source: 'print(1);', origin: origin);

      expect(reopened.id, created.id);
      expect(container.read(editorProvider).source, 'print("editado");');
      expect(container.read(workspaceProvider).documents, hasLength(2));
    });
  });
}
