class WorkspaceDocument {
  final String id;
  final String name;
  final String source;
  final DateTime updatedAt;
  final String origin;

  const WorkspaceDocument({
    required this.id,
    required this.name,
    required this.source,
    required this.updatedAt,
    this.origin = 'Criado no Luminthor',
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

  Map<String, Object> toMap() => {
        'id': id,
        'name': name,
        'source': source,
        'updated_at': updatedAt.toIso8601String(),
        'origin': origin,
      };

  factory WorkspaceDocument.fromMap(Map<dynamic, dynamic> map) {
    return WorkspaceDocument(
      id: map['id'] as String,
      name: map['name'] as String,
      source: map['source'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      origin: (map['origin'] as String? ?? 'Criado no Luminthor')
          .replaceAll('Luminthor', 'Luminthor'),
    );
  }
}
