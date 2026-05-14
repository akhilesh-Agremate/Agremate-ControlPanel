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

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    final docType = json['documentType']?.toString().toLowerCase() ?? 'file';

    return DocumentModel(
      id: json['id'] ?? '',
      name: json['fileName'] ?? 'Unnamed Document',
      type: 'file',
      ownerId: '',
      ownerName: 'N/A',
      ownerType: 'landlord',
      propertyName: json['propertyName'],
      fileType: docType == 'images' ? 'image' : 'pdf',
      createdAt: json['uploadedDate'] != null
          ? DateTime.parse(json['uploadedDate'])
          : DateTime.now(),
      modifiedAt: json['uploadedDate'] != null
          ? DateTime.parse(json['uploadedDate'])
          : DateTime.now(),
    );
  }

  bool get isFolder => type == 'folder';
  bool get isFile => type == 'file';

  String get sizeFormatted {
    if (sizeKb == null) return '';
    if (sizeKb! > 1024) return '${(sizeKb! / 1024).toStringAsFixed(1)} MB';
    return '${sizeKb!.toStringAsFixed(0)} KB';
  }

  String get icon {
    if (isFolder) return 'folder';
    final lowerName = name.toLowerCase();
    if (lowerName.endsWith('.pdf')) return 'pdf';
    if (lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png')) return 'image';
    if (lowerName.endsWith('.doc') || lowerName.endsWith('.docx')) return 'doc';
    return 'file';
  }
}
