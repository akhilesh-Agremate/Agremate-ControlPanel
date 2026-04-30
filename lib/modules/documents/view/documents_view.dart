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
      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(
              children: [
                InkWell(
                  onTap: () => dc.navigateToBreadcrumb(-1),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_rounded, color: AppTheme.accentPurple, size: 20),
                      const SizedBox(width: 6),
                      Text('Documents', style: AppTheme.heading3.copyWith(color: dc.currentPath.isEmpty ? AppTheme.textPrimary : AppTheme.accentPurple)),
                    ],
                  ),
                ),
                ...dc.currentPath.asMap().entries.map((e) => Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 18),
                    ),
                    InkWell(
                      onTap: () => dc.navigateToBreadcrumb(e.key),
                      child: Text(
                        e.value['name'] ?? '',
                        style: AppTheme.heading3.copyWith(
                          color: e.key == dc.currentPath.length - 1 ? AppTheme.textPrimary : AppTheme.accentPurple,
                        ),
                      ),
                    ),
                  ],
                )),
                const Spacer(),
                if (dc.currentPath.isNotEmpty)
                  IconButton(
                    onPressed: dc.goBack,
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Folders
            if (dc.currentFolders.isNotEmpty) ...[
              Text('Folders', style: AppTheme.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: dc.currentFolders.map((folder) {
                  final isLandlord = folder.ownerType == 'landlord';
                  final color = isLandlord ? AppTheme.accentOrange : AppTheme.accentCyan;
                  return SizedBox(
                    width: 200,
                    child: GlassCard(
                      glowColor: color,
                      onTap: () => dc.openFolder(folder.id, folder.name),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.folder_rounded, color: color, size: 48),
                          const SizedBox(height: 10),
                          Text(folder.name, style: AppTheme.heading3, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(folder.ownerType.capitalizeFirst ?? '', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
            ],

            // Files
            if (dc.currentFiles.isNotEmpty) ...[
              Text('Files', style: AppTheme.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...dc.currentFiles.map((file) {
                IconData fileIcon;
                Color fileColor;
                switch (file.fileType) {
                  case 'pdf': fileIcon = Icons.picture_as_pdf_rounded; fileColor = AppTheme.accentRed; break;
                  case 'doc': fileIcon = Icons.description_rounded; fileColor = AppTheme.accentBlue; break;
                  case 'image': fileIcon = Icons.image_rounded; fileColor = AppTheme.accentGreen; break;
                  case 'spreadsheet': fileIcon = Icons.table_chart_rounded; fileColor = AppTheme.accentGreen; break;
                  default: fileIcon = Icons.insert_drive_file_rounded; fileColor = AppTheme.textMuted;
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: AppTheme.solidCardDecoration(borderRadius: 10),
                  child: Row(
                    children: [
                      Icon(fileIcon, color: fileColor, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(file.name, style: AppTheme.heading3.copyWith(fontSize: 14)),
                            Text('${file.fileType?.toUpperCase() ?? "FILE"} • ${file.sizeFormatted}', style: AppTheme.caption),
                          ],
                        ),
                      ),
                      Text('${file.modifiedAt.day}/${file.modifiedAt.month}/${file.modifiedAt.year}', style: AppTheme.caption),
                      const SizedBox(width: 16),
                      Text(file.ownerName, style: AppTheme.caption),
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
                      Icon(Icons.folder_off_rounded, color: AppTheme.textMuted.withValues(alpha: 0.3), size: 64),
                      const SizedBox(height: 12),
                      Text('No documents found', style: AppTheme.bodyText),
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
