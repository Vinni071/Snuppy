import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../domain/workspace_document.dart';

class WorkspaceState {
  final List<WorkspaceDocument> documents;
  final String? activeId;

  const WorkspaceState({this.documents = const [], this.activeId});

  WorkspaceDocument? get activeDocument {
    for (final document in documents) {
      if (document.id == activeId) return document;
    }
    return null;
  }
}

class WorkspaceNotifier extends Notifier<WorkspaceState> {
  @override
  WorkspaceState build() {
    if (!Hive.isBoxOpen('ide_box')) return const WorkspaceState();
    final box = Hive.box('ide_box');
    final saved = box.get('workspace_documents');
    final documents = <WorkspaceDocument>[];
    if (saved is List) {
      for (final item in saved) {
        try {
          documents.add(WorkspaceDocument.fromMap(item as Map));
        } catch (error) {
          debugPrint('Não foi possível recuperar um arquivo: $error');
        }
      }
    } else {
      // Keep the previous single-file workspace accessible after the upgrade.
      final legacySource = box.get('source_code');
      if (legacySource is String && legacySource.isNotEmpty) {
        documents.add(WorkspaceDocument(
          id: 'legacy-draft',
          name: 'Editor.lumi',
          source: legacySource,
          updatedAt: DateTime.now(),
          origin: 'Seu arquivo anterior',
        ));
        _persist(
            WorkspaceState(documents: documents, activeId: 'legacy-draft'));
      }
    }
    documents.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final activeId = box.get('workspace_active_id') as String?;
    return WorkspaceState(
      documents: List.unmodifiable(documents),
      activeId: activeId ?? (documents.isEmpty ? null : documents.first.id),
    );
  }

  WorkspaceDocument create({
    required String name,
    String source = '',
    String origin = 'Criado no Luminthor',
  }) {
    final now = DateTime.now();
    final document = WorkspaceDocument(
      id: '${now.microsecondsSinceEpoch}-${state.documents.length}',
      name: name,
      source: source,
      updatedAt: now,
      origin: origin,
    );
    state = WorkspaceState(
      documents: List.unmodifiable([document, ...state.documents]),
      activeId: document.id,
    );
    _persist(state);
    return document;
  }

  void open(WorkspaceDocument document) {
    final updated = document.copyWith(updatedAt: DateTime.now());
    state = WorkspaceState(
      documents: List.unmodifiable([
        updated,
        ...state.documents.where((item) => item.id != document.id),
      ]),
      activeId: document.id,
    );
    _persist(state);
  }

  void updateSource(String source) {
    final active = state.activeDocument;
    if (active == null) {
      create(name: 'sem-titulo.lumi', source: source);
      return;
    }
    if (active.source == source) return;
    final updated = active.copyWith(source: source, updatedAt: DateTime.now());
    state = WorkspaceState(
      documents: List.unmodifiable([
        updated,
        ...state.documents.where((item) => item.id != active.id),
      ]),
      activeId: active.id,
    );
    _persist(state);
  }

  Future<void> _persist(WorkspaceState workspace) async {
    if (!Hive.isBoxOpen('ide_box')) return;
    try {
      final box = Hive.box('ide_box');
      await box.put('workspace_documents',
          workspace.documents.map((document) => document.toMap()).toList());
      await box.put('workspace_active_id', workspace.activeId);
    } catch (error) {
      debugPrint('Não foi possível salvar os arquivos do Luminthor: $error');
    }
  }
}

final workspaceProvider =
    NotifierProvider<WorkspaceNotifier, WorkspaceState>(WorkspaceNotifier.new);
