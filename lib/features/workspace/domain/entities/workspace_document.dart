/// A Lumi source file kept in the learner's local workspace.
class WorkspaceDocument {
  static const defaultOrigin = 'Criado no Luminthor';

  final String id;
  final String name;
  final String source;
  final DateTime updatedAt;

  /// Human-readable provenance shown in the file list. Lesson documents use it
  /// as a stable lookup key (see [DocumentOrigin.lesson]).
  final String origin;

  const WorkspaceDocument({
    required this.id,
    required this.name,
    required this.source,
    required this.updatedAt,
    this.origin = defaultOrigin,
  });

  WorkspaceDocument copyWith({String? source, DateTime? updatedAt}) {
    return WorkspaceDocument(
      id: id,
      name: name,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      origin: origin,
    );
  }
}

/// Origin labels shared by every flow that creates documents.
abstract final class DocumentOrigin {
  static const created = WorkspaceDocument.defaultOrigin;
  static const imported = 'Importado do dispositivo';
  static const legacy = 'Seu arquivo anterior';

  static String template(String title) => 'Template · $title';

  static String lesson(String lessonId) => 'Trilha Lumi · $lessonId';
}

/// Appends the `.lumi` extension unless the name already has it.
String ensureLumiExtension(String name) =>
    name.toLowerCase().endsWith('.lumi') ? name : '$name.lumi';
