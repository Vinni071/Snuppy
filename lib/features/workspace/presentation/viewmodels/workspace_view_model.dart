import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminthor/core/errors/error_reporter.dart';
import 'package:luminthor/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:luminthor/features/workspace/domain/entities/workspace.dart';
import 'package:luminthor/features/workspace/domain/entities/workspace_document.dart';

export 'package:luminthor/features/workspace/domain/entities/workspace.dart';
export 'package:luminthor/features/workspace/domain/entities/workspace_document.dart';

/// Owns the list of documents and which one is active.
///
/// Changes apply to the UI immediately and are persisted in the background;
/// a failed write is reported without blocking the learner's editing.
class WorkspaceNotifier extends Notifier<Workspace> {
  @override
  Workspace build() => ref.watch(workspaceRepositoryProvider).load();

  WorkspaceDocument create({
    required String name,
    String source = '',
    String origin = DocumentOrigin.created,
  }) {
    final now = DateTime.now();
    final document = WorkspaceDocument(
      id: '${now.microsecondsSinceEpoch}-${state.documents.length}',
      name: name,
      source: source,
      updatedAt: now,
      origin: origin,
    );
    _update(state.activate(document));
    return document;
  }

  void open(WorkspaceDocument document) {
    _update(state.activate(document.copyWith(updatedAt: DateTime.now())));
  }

  void updateSource(String source) {
    final active = state.activeDocument;
    if (active == null) {
      create(name: 'sem-titulo.lumi', source: source);
      return;
    }
    if (active.source == source) return;
    _update(state.activate(
      active.copyWith(source: source, updatedAt: DateTime.now()),
    ));
  }

  void _update(Workspace workspace) {
    state = workspace;
    unawaited(ref.read(workspaceRepositoryProvider).save(workspace).catchError(
      (Object error, StackTrace stack) {
        reportError(
            'Não foi possível salvar os arquivos do Luminthor', error, stack);
      },
    ));
  }
}

final workspaceProvider =
    NotifierProvider<WorkspaceNotifier, Workspace>(WorkspaceNotifier.new);
