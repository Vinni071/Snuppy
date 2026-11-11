import 'package:luminthor/features/workspace/domain/entities/workspace_document.dart';

/// Immutable snapshot of the workspace, most recently used document first.
class Workspace {
  final List<WorkspaceDocument> documents;
  final String? activeId;

  const Workspace({this.documents = const [], this.activeId});

  WorkspaceDocument? get activeDocument {
    for (final document in documents) {
      if (document.id == activeId) return document;
    }
    return null;
  }

  WorkspaceDocument? findByOrigin(String origin) {
    for (final document in documents) {
      if (document.origin == origin) return document;
    }
    return null;
  }

  /// Moves [document] to the top (replacing any version with the same id)
  /// and makes it the active one.
  Workspace activate(WorkspaceDocument document) => Workspace(
        documents: List.unmodifiable([
          document,
          ...documents.where((item) => item.id != document.id),
        ]),
        activeId: document.id,
      );
}
