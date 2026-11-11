import 'package:flutter/material.dart';

class DocumentModel {
  final String id;
  final String name;
  final String type;
  final String? parentId;
  final String ownerId;
  final String ownerName;
  final String ownerType;
  final String? fileType;
  final double? sizeKb;
  final String? propertyName;
  final String? thumbnailUrl;
  final String? relativePath;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String> candidateIds;
  final bool isDeletable;
  final bool isSuperAdmin;
  final String? tag;
  final bool isAdminUploaded;

  DocumentModel({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    required this.ownerId,
    required this.ownerName,
    required this.ownerType,
    this.propertyName,
    this.thumbnailUrl,
    this.relativePath,
    this.fileType,
    this.sizeKb,
    this.candidateIds = const [],
    required this.createdAt,
    required this.modifiedAt,
    this.isDeletable = false,
    this.isSuperAdmin = false,
    this.tag,
    this.isAdminUploaded = false,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    if (json['documentDetail'] is Map) {
      return DocumentModel.fromPropertyDocumentApi(json);
    }
    final name = (json['fileName'] ??
            json['documentName'] ??
            json['name'] ??
            '')
        .toString()
        .trim();
    final rawUrl = (json['documentUrl'] ??
            json['url'] ??
            json['fileUrl'] ??
            json['relativePath'] ??
            json['thumbnailUrl'] ??
            '')
        .toString()
        .trim();
    final thumb = (json['thumbnailUrl'] ?? '').toString().trim();
    final lower = '${name.toLowerCase()} ${json['documentType'] ?? ''} ${json['fileType'] ?? ''}'
        .toLowerCase();
    final isImage = lower.contains('image') ||
        lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.gif') ||
        lower.contains('.webp');
    final uploaded = DateTime.tryParse(
          (json['uploadedDate'] ?? json['createdDate'] ?? '').toString(),
        ) ??
        DateTime.now();

    final candidateIds = <String>[];
    for (final key in [
      'documentId', 'id', 'fileId', 'documentFileId',
      'uploadedFileId', 'attachmentId',
    ]) {
      final v = (json[key] ?? '').toString().trim();
      if (v.isNotEmpty && v != 'null' && !candidateIds.contains(v)) {
        candidateIds.add(v);
      }
    }

    final uploadedBy = json['uploadedBy'] is Map
        ? Map<String, dynamic>.from(json['uploadedBy'] as Map)
        : null;
    final tag = (json['tag'] ?? '').toString().trim();
    final uploaderRole = (uploadedBy?['role'] ?? '').toString().trim();
    final uploaderName = (uploadedBy?['name'] ?? '').toString().trim();

    final isAdminUploaded = json['isAdminUploaded'] == true ||
        json['isSuperAdmin'] == true ||
        tag.toLowerCase() == 'super admin' ||
        uploaderRole.toLowerCase() == 'super admin' ||
        (json['ownerType'] ?? '').toString().toLowerCase() == 'super_admin' ||
        (json['uploadedBy'] is String &&
            (json['uploadedBy'] as String).toLowerCase().contains('admin'));

    final isSuperAdmin = isAdminUploaded;

    return DocumentModel(
      id: (json['id'] ?? json['documentId'] ?? '').toString(),
      name: name.isNotEmpty ? name : 'Document',
      type: 'file',
      ownerId: (uploadedBy?['userId'] ?? '').toString(),
      ownerName: (json['landlordName'] ??
              (uploaderName.isNotEmpty
                  ? uploaderName
                  : (isSuperAdmin ? 'Super Admin' : 'N/A')))
          .toString(),
      ownerType: isSuperAdmin ? 'super_admin' : 'landlord',
      propertyName: json['propertyName']?.toString(),
      thumbnailUrl: _resolveUrl(thumb),
      relativePath: _resolveUrl(rawUrl.isNotEmpty ? rawUrl : thumb),
      fileType: isImage ? 'image' : 'pdf',
      createdAt: uploaded,
      modifiedAt: uploaded,
      candidateIds: candidateIds,
      isDeletable: json['isDeletable'] == true,
      isSuperAdmin: isSuperAdmin,
      isAdminUploaded: isAdminUploaded,
      tag: tag.isNotEmpty ? tag : (isSuperAdmin ? 'Super Admin' : null),
    );
  }

  factory DocumentModel.fromPropertyDocumentApi(Map<String, dynamic> json) {
    final detail = json['documentDetail'] is Map
        ? Map<String, dynamic>.from(json['documentDetail'] as Map)
        : <String, dynamic>{};
    final prop = json['property'] is Map
        ? Map<String, dynamic>.from(json['property'] as Map)
        : <String, dynamic>{};
    final uploadedBy = json['uploadedBy'] is Map
        ? Map<String, dynamic>.from(json['uploadedBy'] as Map)
        : (detail['uploadedBy'] is Map
            ? Map<String, dynamic>.from(detail['uploadedBy'] as Map)
            : null);

    final name = (detail['fileName'] ??
            detail['name'] ??
            json['fileName'] ??
            json['documentName'] ??
            json['name'] ??
            '')
        .toString()
        .trim();

    final rawUrl = (detail['absolutePath'] ??
            detail['originalUrl'] ??
            detail['thumbnailUrl'] ??
            detail['fileUrl'] ??
            detail['relativePath'] ??
            json['documentUrl'] ??
            json['url'] ??
            json['fileUrl'] ??
            '')
        .toString()
        .trim();

    final thumb =
        (detail['thumbnailUrl'] ?? json['thumbnailUrl'] ?? '').toString().trim();

    final lower = name.toLowerCase();
    final isImage = lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');

    final uploaded = DateTime.tryParse(
          (detail['uploadedTime'] ??
                  detail['uploadedDate'] ??
                  json['createdAt'] ??
                  '')
              .toString(),
        ) ??
        DateTime.now();

    final candidateIds = <String>[];
    for (final v in [
      json['id'],
      json['documentDetailId'],
      detail['id'],
    ]) {
      final s = v?.toString().trim() ?? '';
      if (s.isNotEmpty && s != 'null' && !candidateIds.contains(s)) {
        candidateIds.add(s);
      }
    }

    final id = (json['id'] ?? detail['id'] ?? json['documentDetailId'] ?? '')
        .toString();

    final tag = (json['tag'] ?? detail['tag'] ?? '').toString().trim();
    final uploaderRole = (uploadedBy?['role'] ?? '').toString().trim();
    final uploaderName = (uploadedBy?['name'] ?? '').toString().trim();

    final bool isAdminUploaded = json['isAdminUploaded'] == true ||
        detail['isAdminUploaded'] == true ||
        json['isSuperAdmin'] == true ||
        tag.toLowerCase() == 'super admin' ||
        uploaderRole.toLowerCase() == 'super admin';

    final isSuperAdmin = isAdminUploaded;

    final ownerName = isSuperAdmin
        ? (uploaderName.isNotEmpty ? uploaderName : 'Super Admin')
        : (prop['name'] ?? 'Property').toString();

    return DocumentModel(
      id: id,
      name: name.isNotEmpty ? name : 'Document',
      type: 'file',
      ownerId: (uploadedBy?['userId'] ?? json['userId'] ?? '').toString(),
      ownerName: ownerName,
      ownerType: isSuperAdmin ? 'super_admin' : 'property',
      propertyName: (prop['name'] ?? json['propertyName'])?.toString(),
      thumbnailUrl: _resolveUrl(thumb.isNotEmpty ? thumb : rawUrl),
      relativePath: _resolveUrl(rawUrl.isNotEmpty ? rawUrl : thumb),
      fileType: isImage ? 'image' : 'pdf',
      createdAt: uploaded,
      modifiedAt: uploaded,
      candidateIds: candidateIds,
      isDeletable: detail['isDeletable'] == true || json['isDeletable'] == true,
      isSuperAdmin: isSuperAdmin,
      isAdminUploaded: isAdminUploaded,
      tag: tag.isNotEmpty ? tag : (isSuperAdmin ? 'Super Admin' : null),
    );
  }

  static String _resolveUrl(String path) {
    final value = path.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://amplify-agremate-dev-76a83-deployment.s3.ap-south-1.amazonaws.com/${value.startsWith('/') ? value.substring(1) : value}';
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
        lowerName.endsWith('.png'))
      return 'image';
    if (lowerName.endsWith('.doc') || lowerName.endsWith('.docx')) return 'doc';
    return 'file';
  }

  IconData get fileIcon {
    if (isFolder) return Icons.folder_rounded;
    switch (fileType) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
        return Icons.description_rounded;
      case 'spreadsheet':
        return Icons.table_chart_rounded;
      case 'image':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get fileColor {
    if (isFolder) return const Color(0xFF3B82F6);
    switch (fileType) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'doc':
        return const Color(0xFF3B82F6);
      case 'spreadsheet':
        return const Color(0xFF10B981);
      case 'image':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF94A3B8);
    }
  }
}

