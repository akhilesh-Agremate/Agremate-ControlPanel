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
    required this.createdAt,
    required this.modifiedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
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

    return DocumentModel(
      id: (json['id'] ?? json['documentId'] ?? '').toString(),
      name: name.isNotEmpty ? name : 'Document',
      type: 'file',
      ownerId: '',
      ownerName: (json['landlordName'] ?? 'N/A').toString(),
      ownerType: 'landlord',
      propertyName: json['propertyName']?.toString(),
      thumbnailUrl: _resolveUrl(thumb),
      relativePath: _resolveUrl(rawUrl.isNotEmpty ? rawUrl : thumb),
      fileType: isImage ? 'image' : 'pdf',
      createdAt: uploaded,
      modifiedAt: uploaded,
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

