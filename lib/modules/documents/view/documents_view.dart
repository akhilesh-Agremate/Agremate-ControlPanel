import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/documents/controller/document_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';

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
                    // ── Folders Section ─────────────────────────────────────
                    if (dc.currentFolders.isNotEmpty) ...[
                      const Text(
                        'Folders',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: dc.currentFolders.map((folder) {
                          final isLandlord = folder.ownerType == 'landlord';
                          final color = isLandlord ? const Color(0xFF3B82F6) : const Color(0xFF10B981);
                          return SizedBox(
                            width: 220,
                            child: InkWell(
                              onTap: () => dc.openFolder(folder.id, folder.name),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFEDF2F7)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.folder_rounded, color: color.withValues(alpha: 0.8), size: 56),
                                    const SizedBox(height: 14),
                                    Text(
                                      folder.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      folder.ownerType.capitalizeFirst ?? '',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],

                    // ── Files Section ───────────────────────────────────────
                    if (dc.currentFiles.isNotEmpty) ...[
                      const Text(
                        'Files',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...dc.currentFiles.map((file) {
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
                        return Container(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${file.fileType?.toUpperCase() ?? "FILE"} • ${file.sizeFormatted}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Date
                              Text(
                                '${file.modifiedAt.day}/${file.modifiedAt.month}/${file.modifiedAt.year}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Owner
                              SizedBox(
                                width: 120,
                                child: Text(
                                  file.ownerName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    if (dc.currentFolders.isEmpty && dc.currentFiles.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              Icon(Icons.folder_off_rounded, color: const Color(0xFFE2E8F0), size: 80),
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
}
