import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/core/errors/error_reporter.dart';
import 'package:luminthor/core/storage/key_value_store.dart';
import 'package:luminthor/features/workspace/data/mappers/workspace_document_mapper.dart';
import 'package:luminthor/features/workspace/domain/entities/workspace.dart';
import 'package:luminthor/features/workspace/domain/entities/workspace_document.dart';
import 'package:luminthor/features/workspace/domain/repositories/workspace_repository.dart';

class LocalWorkspaceRepository implements WorkspaceRepository {
  // Storage keys are part of the persisted format; do not rename.
  static const documentsKey = 'workspace_documents';
  static const activeIdKey = 'workspace_active_id';

  /// Single-file draft saved by versions before the multi-file workspace.
  static const legacySourceKey = 'source_code';
  static const legacyDocumentId = 'legacy-draft';

  final KeyValueStore _store;

  const LocalWorkspaceRepository(this._store);

  @override
  Workspace load() {
    if (!_store.isAvailable) return const Workspace();
    final saved = _store.read(documentsKey);
    final documents = <WorkspaceDocument>[];
    if (saved is List) {
      for (final item in saved) {
        // One corrupt entry must not make every other file disappear.
        try {
          documents.add(WorkspaceDocumentMapper.fromMap(item as Map));
        } catch (error, stack) {
          reportError('Não foi possível recuperar um arquivo', error, stack);
        }
      }
    } else {
      final legacy = _migrateLegacyDraft();
      if (legacy != null) documents.add(legacy);
    }
    documents.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final activeId = _store.read(activeIdKey);
    return Workspace(
      documents: List.unmodifiable(documents),
      activeId: activeId is String
          ? activeId
          : (documents.isEmpty ? null : documents.first.id),
    );
  }

  /// Keeps the previous single-file workspace accessible after the upgrade.
  WorkspaceDocument? _migrateLegacyDraft() {
    final legacySource = _store.read(legacySourceKey);
    if (legacySource is! String || legacySource.isEmpty) return null;
    final document = WorkspaceDocument(
      id: legacyDocumentId,
      name: 'Editor.lumi',
      source: legacySource,
      updatedAt: DateTime.now(),
      origin: DocumentOrigin.legacy,
    );
    unawaited(
      save(Workspace(documents: [document], activeId: document.id))
          .catchError((Object error, StackTrace stack) {
        reportError(
            'Não foi possível migrar o rascunho anterior', error, stack);
      }),
    );
    return document;
  }

  @override
  Future<void> save(Workspace workspace) async {
    await _store.write(
      documentsKey,
      workspace.documents.map(WorkspaceDocumentMapper.toMap).toList(),
    );
    await _store.write(activeIdKey, workspace.activeId);
  }
}

final workspaceRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => LocalWorkspaceRepository(ref.watch(keyValueStoreProvider)),
);
