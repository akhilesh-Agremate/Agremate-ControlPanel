class DocumentModel {
  final String id;
  final String name;
  final String type; // folder, file
  final String? parentId;
  final String ownerId;
  final String ownerName;
  final String ownerType; // landlord, tenant
  final String? fileType; // pdf, doc, image, etc.
  final double? sizeKb;
  final String? propertyName;
  final DateTime createdAt;
  final DateTime modifiedAt;

  DocumentModel({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    required this.ownerId,
    required this.ownerName,
    required this.ownerType,
    this.propertyName,
    this.fileType,
    this.sizeKb,
    required this.createdAt,
    required this.modifiedAt,
  });

  bool get isFolder => type == 'folder';
  bool get isFile => type == 'file';

  String get sizeFormatted {
    if (sizeKb == null) return '';
    if (sizeKb! > 1024) return '${(sizeKb! / 1024).toStringAsFixed(1)} MB';
    return '${sizeKb!.toStringAsFixed(0)} KB';
  }

  String get icon {
    if (isFolder) return 'folder';
    switch (fileType) {
      case 'pdf': return 'pdf';
      case 'doc': return 'doc';
      case 'image': return 'image';
      case 'spreadsheet': return 'spreadsheet';
      default: return 'file';
    }
  }
}
