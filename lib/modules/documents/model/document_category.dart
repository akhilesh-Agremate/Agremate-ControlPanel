class DocumentCategory {
  final int value;
  final String key;
  final String label;
  final String description;

  const DocumentCategory({
    required this.value,
    required this.key,
    required this.label,
    this.description = '',
  });

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    final key = (json['value'] ?? '').toString();
    return DocumentCategory(
      value: (json['enumValue'] as num).toInt(),
      key: key,
      label: (json['displayName'] ?? key).toString(),
      description: (json['description'] ?? '').toString(),
    );
  }

  static const _allowedKeys = {
    'PropertyDocuments',
    'PropertyImages',
    'UserDocuments',
  };

  static const _propertyScopedKeys = {
    'PropertyDocuments',
    'PropertyImages',
  };

  bool get isSelectable => _allowedKeys.contains(key);
  bool get needsProperty => _propertyScopedKeys.contains(key);

  @override
  bool operator ==(Object other) =>
      other is DocumentCategory && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class DocumentEntity {
  final String id;
  final String name;
  final String additionalInfo;

  const DocumentEntity({
    required this.id,
    required this.name,
    this.additionalInfo = '',
  });

  factory DocumentEntity.fromJson(Map<String, dynamic> json) {
    return DocumentEntity(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      additionalInfo: (json['additionalInfo'] ?? '').toString(),
    );
  }

  @override
  bool operator ==(Object other) => other is DocumentEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}