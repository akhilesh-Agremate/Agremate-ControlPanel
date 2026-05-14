import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/documents/controller/document_controller.dart';
import 'package:agremate_admin/modules/documents/model/document_model.dart';

class DocumentsView extends StatelessWidget {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final dc = Get.find<DocumentController>();

    return Obx(() {
      return Container(
        color: const Color(0xFFFBFDFF), // Very light clean background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEDF2F7))),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: dc.goBack,
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF475569), size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Files List ───────────────────────────────────────
                    ...dc.allFiles.map((file) {
                      IconData fileIcon;
                      Color fileColor;
                      switch (file.fileType) {
                        case 'pdf': 
                          fileIcon = Icons.picture_as_pdf_rounded; 
                          fileColor = const Color(0xFFEF4444); 
                          break;
                        case 'doc': 
                          fileIcon = Icons.description_rounded; 
                          fileColor = const Color(0xFF3B82F6); 
                          break;
                        case 'spreadsheet': 
                          fileIcon = Icons.table_chart_rounded; 
                          fileColor = const Color(0xFF10B981); 
                          break;
                        default: 
                          fileIcon = Icons.insert_drive_file_rounded; 
                          fileColor = const Color(0xFF94A3B8);
                      }
                      return InkWell(
                        onTap: () => _showDocumentPreview(context, file, fileIcon, fileColor),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEDF2F7)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.01),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: fileColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(fileIcon, color: fileColor, size: 24),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.propertyName ?? 'No Property',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${file.name} • ${file.fileType?.toUpperCase() ?? "FILE"} (${file.sizeFormatted})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Date and Owner on the right
                              SizedBox(
                                width: 180,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${file.modifiedAt.day}/${file.modifiedAt.month}/${file.modifiedAt.year}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${file.ownerType.capitalizeFirst}: ${file.ownerName}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    if (dc.allFiles.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              const Icon(Icons.folder_off_rounded, color: Color(0xFFE2E8F0), size: 80),
                              const SizedBox(height: 16),
                              const Text(
                                'No documents found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showDocumentPreview(BuildContext context, DocumentModel file, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 900,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(file.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        Text('${file.propertyName} • ${file.ownerName} (${file.ownerType})', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: color.withValues(alpha: 0.2), size: 120),
                        const SizedBox(height: 24),
                        const Text('Document Preview is Loading...', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Text('Size: ${file.sizeFormatted}', style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
