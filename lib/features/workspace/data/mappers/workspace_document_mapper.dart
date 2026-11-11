import 'package:luminthor/features/workspace/domain/entities/workspace_document.dart';

/// Converts documents to and from the map format stored on disk.
///
/// The keys are part of the persisted format; keep them backwards compatible.
abstract final class WorkspaceDocumentMapper {
  static Map<String, Object> toMap(WorkspaceDocument document) => {
        'id': document.id,
        'name': document.name,
        'source': document.source,
        'updated_at': document.updatedAt.toIso8601String(),
        'origin': document.origin,
      };

  /// Throws [FormatException] or [TypeError] for malformed entries.
  static WorkspaceDocument fromMap(Map<dynamic, dynamic> map) {
    return WorkspaceDocument(
      id: map['id'] as String,
      name: map['name'] as String,
      source: map['source'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      origin: map['origin'] as String? ?? WorkspaceDocument.defaultOrigin,
    );
  }
}
