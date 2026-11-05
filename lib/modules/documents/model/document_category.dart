class DocumentCategory {
  final int value;
  final String label;
  final bool needsProperty;

  const DocumentCategory(this.value, this.label, {this.needsProperty = false});

  static const propertyDocuments =
  DocumentCategory(3, 'Property documents', needsProperty: true);
  static const propertyImages =
  DocumentCategory(2, 'Property images', needsProperty: true);
  static const userDocuments =
  DocumentCategory(1, 'My documents (admin only)');

  static const all = [propertyDocuments, propertyImages, userDocuments];
}