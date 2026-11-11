import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/web_network_image.dart';
import 'package:agremate_admin/modules/documents/controller/document_controller.dart';
import 'package:agremate_admin/modules/documents/model/document_model.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/full_pdf_page.dart';
import '../../../core/widgets/pdf_iframe_view.dart';
import '../../auth/controller/auth_controller.dart';
import '../model/document_category.dart';

class DocumentsView extends StatelessWidget {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final dc = Get.find<DocumentController>();

    return Obx(() {
      final _ = dc.searchQuery;
      if (dc.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (dc.errorMessage.value.isNotEmpty && dc.selectedProperty.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                dc.errorMessage.value,
                style: const TextStyle(color: AppColors.hintGrey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: dc.refreshData,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        );
      }

      final selected = dc.selectedProperty.value;
      if (selected != null) {
        return _PropertyDocumentsView(property: selected, dc: dc);
      }

      return _PropertyCardsView(dc: dc);
    });
  }
}

class _PropertyCardsView extends StatelessWidget {
  const _PropertyCardsView({required this.dc});

  final DocumentController dc;
  @override
  Widget build(BuildContext context) {
    final items = dc.visibleProperties;

    return ColoredBox(
      color: AppColors.scaffoldLight,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 600
              ? 14
              : (MediaQuery.sizeOf(context).width < 850 ? 20 : 28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            items.isEmpty
                ? const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  AppStrings.noPropertiesFound,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hintGrey,
                  ),
                ),
              ),
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 520
                    ? 1
                    : constraints.maxWidth < 820
                    ? 2
                    : constraints.maxWidth < 1100
                    ? 3
                    : 4;
                final cardWidth =
                    (constraints.maxWidth - 16 * (crossAxisCount - 1)) /
                        crossAxisCount;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: items
                      .map(
                        (prop) => _DocumentPropertyCard(
                      prop: prop,
                      width: cardWidth,
                      onTap: () => dc.openPropertyDocuments(prop),
                    ),
                  )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentPropertyCard extends StatelessWidget {
  const _DocumentPropertyCard({
    required this.prop,
    required this.width,
    required this.onTap,
  });

  final PropertyModel prop;
  final double width;
  final VoidCallback onTap;

  static const double _cardHeight = 180;

  @override
  Widget build(BuildContext context) {
    final tenantName =
        (prop.primaryTenantName != null && prop.primaryTenantName!.isNotEmpty)
            ? prop.primaryTenantName!
            :  AppStrings.notAvailable;
    final hasImage = prop.imageUrl != null && prop.imageUrl!.trim().isNotEmpty;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlue.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: AppColors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          ),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: _cardHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    Image.network(
                      prop.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _placeholder(),
                    )
                  else
                    _placeholder(),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 110,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prop.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: _personLabel(
                                icon: Icons.person_rounded,
                                text: AppStrings.landlordLabel(prop.landlordName),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _personLabel(
                                icon: Icons.groups_outlined,
                                text: AppStrings.tenantLabel(tenantName),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Image.asset(
      'assets/images/placer.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (c, e, s) => Container(color: AppTheme.bgCardLight),
    );
  }

  Widget _personLabel({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 12),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PropertyDocumentsView extends StatelessWidget {
  const _PropertyDocumentsView({
    required this.property,
    required this.dc,
  });

  final PropertyModel property;
  final DocumentController dc;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final files = dc.currentFiles;
      final propertyFiles = files.where((f) => !f.isSuperAdmin).toList();
      final adminFiles = files.where((f) => f.isSuperAdmin).toList();

      final auth = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : null;
      final bool isSuperAdmin = auth != null && !auth.isRestrictedRole;
      final bool showAdminPanel = auth != null && auth.isSuperAdmin;

      return ColoredBox(
        color: AppColors.documentsBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width < 600 ? 14 : 24,
                vertical: 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.dividerLight)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: dc.goBack,
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF475569), size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.documents,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          property.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.hintGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: dc.isDetailLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(
                        MediaQuery.sizeOf(context).width < 600 ? 14 : 32,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final propertySection = _buildColumnSection(
                            context: context,
                            title: 'Property Documents',
                            icon: Icons.folder_outlined,
                            badgeColor: const Color(0xFFF1F5F9),
                            badgeTextColor: const Color(0xFF64748B),
                            emptyText: 'No property documents found',
                            files: propertyFiles,
                            isSuperAdmin: isSuperAdmin,
                          );
                          if (!showAdminPanel || adminFiles.isEmpty) return propertySection;

                          final adminSection = _buildColumnSection(
                            context: context,
                            title: 'Super Admin Documents',
                            icon: Icons.admin_panel_settings_outlined,
                            badgeColor: const Color(0xFFE8F1FD),
                            badgeTextColor: const Color(0xFF2083D5),
                            emptyText: 'No documents uploaded by Super Admin',
                            files: adminFiles,
                            isSuperAdmin: isSuperAdmin,
                          );
                          final isTwoColumn = constraints.maxWidth >= 850;
                          if (isTwoColumn) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: propertySection),
                                const SizedBox(width: 24),
                                Expanded(child: adminSection),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              adminSection,
                              const SizedBox(height: 24),
                              propertySection,
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildColumnSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color badgeColor,
    required Color badgeTextColor,
    required String emptyText,
    required List<DocumentModel> files,
    required bool isSuperAdmin,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: badgeTextColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${files.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (files.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder_off_rounded,
                  color: AppColors.inputBorder,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  emptyText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hintGrey,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: files.length,
            itemBuilder: (ctx, idx) => _buildDocumentCard(context, files[idx], isSuperAdmin),
          ),
      ],
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentModel file, bool isSuperAdmin) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 600 ? 12 : 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFEDF2F7),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: file.fileColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                file.fileIcon,
                color: file.fileColor,
                size: 24,
              ),
            ),
            SizedBox(width: MediaQuery.sizeOf(context).width < 600 ? 10 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        file.fileType?.toUpperCase() ?? 'FILE',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.hintGrey,
                        ),
                      ),
                      if (file.tag != null && file.tag!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            file.tag!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2083D5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if ((file.relativePath ?? '').isNotEmpty) ...[
              _roundIconButton(
                icon: Icons.visibility_outlined,
                tooltip: 'Preview',
                background: Colors.transparent,
                iconColor: Colors.black,
                onTap: () => _openDocument(context, file),
              ),
              const SizedBox(width: 4),
              _roundIconButton(
                icon: Icons.download_rounded,
                tooltip: 'Download',
                background: Colors.transparent,
                iconColor: const Color(0xFF475569),
                onTap: () => downloadFileWeb(file.relativePath!, file.name),
              ),
            ],
            if (isSuperAdmin && file.isDeletable) ...[
              const SizedBox(width: 4),
              _roundIconButton(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Delete',
                background: Colors.transparent,
                iconColor: const Color(0xFFDC2626),
                onTap: () => _confirmDelete(context, file),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required String tooltip,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
    Color? borderColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
          ),
          child: Icon(icon, size: 19, color: iconColor),
        ),
      ),
    );
  }

  void _openDocument(BuildContext context, DocumentModel file) {
    final url = (file.relativePath ?? '').isNotEmpty
        ? file.relativePath!
        : (file.thumbnailUrl ?? '');

    final isPdf = (file.fileType ?? '').toLowerCase() == 'pdf' ||
        file.name.toLowerCase().endsWith('.pdf');

    if (isPdf && url.isNotEmpty) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => FullPdfPage(url: url, title: file.name),
        ),
      );
      return;
    }
    _showDocumentPreview(context, file);
  }

  void _confirmDelete(BuildContext context, DocumentModel file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete document',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Delete "${file.name}"? This can\'t be undone.',
          style: const TextStyle(fontSize: 14, color: AppColors.hintGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              dc.deleteDocument(file);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentPreview(BuildContext context, DocumentModel file) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 600 ? 12 : 40,
          vertical: 40,
        ),
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
                    decoration: BoxDecoration(
                      color: file.fileColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(file.fileIcon, color: file.fileColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      file.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: _buildPreviewBody(file),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if ((file.relativePath ?? '').isNotEmpty)
                    TextButton(
                      onPressed: () {
                        downloadFileWeb(file.relativePath!, file.name);
                      },
                      child: const Text(AppStrings.openDownload),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(AppStrings.close),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewBody(DocumentModel file) {
    final url = (file.relativePath ?? '').isNotEmpty
        ? file.relativePath!
        : (file.thumbnailUrl ?? '');
    if (url.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.previewNotAvailable,
          style: TextStyle(color: AppColors.hintGrey),
        ),
      );
    }

    final isPdf = (file.fileType ?? '').toLowerCase() == 'pdf' ||
        file.name.toLowerCase().endsWith('.pdf');
    if (isPdf) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PdfIframeView(url: url),
      );
    }

    final previewUrl = (file.thumbnailUrl ?? '').isNotEmpty
        ? file.thumbnailUrl!
        : url;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: WebNetworkImage(url: previewUrl, fit: BoxFit.contain),
    );
  }
}

class _DocumentsToolbar extends StatelessWidget {
  const _DocumentsToolbar();

  @override
  Widget build(BuildContext context) {
    final bool isSuperAdmin = Get.isRegistered<AuthController>()
        ? !Get.find<AuthController>().isRestrictedRole
        : false;
    if (!isSuperAdmin) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: () => showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.45),
            builder: (_) => const CreateDocumentDialog(),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'Create Document',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2083D5),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateDocumentDialog extends StatefulWidget {
  const CreateDocumentDialog({super.key});

  @override
  State<CreateDocumentDialog> createState() => CreateDocumentDialogState();
}

class CreateDocumentDialogState extends State<CreateDocumentDialog> {
  PlatformFile? _file;
  bool _uploading = false;

  DocumentCategory? _category;
  DocumentEntity? _entity;

  final DocumentController _dc = Get.find<DocumentController>();

  DocumentCategory? get _effectiveCategory => _category ?? _dc.defaultCategory;

  @override
  void initState() {
    super.initState();
    _dc.fetchCategories().then((_) {
      final category = _effectiveCategory;
      if (category != null) {
        _dc.fetchEntities(category.value).then((_) {
          if (!mounted) return;
          final sel = _dc.selectedProperty.value;
          if (sel != null && _entity == null) {
            final match = _dc.entities.firstWhereOrNull((e) =>
                e.id.toLowerCase() == sel.id.toLowerCase() ||
                e.name.toLowerCase() == sel.name.toLowerCase());
            if (match != null) {
              setState(() => _entity = match);
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.any);
      if (files.isEmpty) return;
      setState(() => _file = files.first);
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    ),
  );

  InputDecoration _fieldDecoration() => InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF7F9FC),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2083D5), width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Create document',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close,
                          size: 20, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _label('Category'),
              Obx(() {
                if (_dc.isCategoriesLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                if (_dc.categories.isEmpty) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dc.categoriesError.value.isNotEmpty
                              ? _dc.categoriesError.value
                              : 'No categories available',
                          style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626)),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _dc.fetchCategories(force: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }
                return DropdownButtonFormField<DocumentCategory>(
                  key: ValueKey(_dc.categories.length),
                  initialValue: _effectiveCategory,
                  isExpanded: true,
                  decoration: _fieldDecoration(),
                  items: _dc.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (c) {
                    setState(() {
                      _category = c;
                      _entity = null;
                    });
                    if (c != null) _dc.fetchEntities(c.value);
                  },
                );
              }),
              const SizedBox(height: 20),

              if (_effectiveCategory != null) ...[
                _label('Entity'),
                Obx(() {
                  if (_dc.isEntitiesLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  if (_dc.entitiesError.value.isNotEmpty) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dc.entitiesError.value,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFFDC2626)),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final category = _effectiveCategory;
                            if (category != null) {
                              _dc.fetchEntities(category.value);
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  }
                  if (_dc.entities.isEmpty) {
                    return const Text(
                      'No entities for this category',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    );
                  }
                  return DropdownButtonFormField<DocumentEntity>(
                    key: ValueKey(
                        '${_effectiveCategory?.value}-${_dc.entities.length}-${_entity?.id}'),
                    value: _dc.entities
                        .firstWhereOrNull((e) => e.id == _entity?.id),
                    isExpanded: true,
                    menuMaxHeight: 240,
                    hint: const Text('Select entity'),
                    decoration: _fieldDecoration(),
                    items: _dc.entities
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.additionalInfo.isEmpty
                                    ? e.name
                                    : '${e.name} · ${e.additionalInfo}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (e) => setState(() => _entity = e),
                  );
                }),
                const SizedBox(height: 20),
              ],

              _label('Upload file'),
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD6E4F5)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F1FD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.upload_file_rounded,
                            size: 22, color: Color(0xFF2083D5)),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Click to choose a file',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'PDF, images or any other document',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ),
              if (_file != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_outlined,
                          size: 18, color: Color(0xFF2083D5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _file!.name,
                          style: const TextStyle(fontSize: 12.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _file = null),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_uploading || _effectiveCategory == null) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2083D5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _uploading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Create document'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final category = _effectiveCategory;
    if (category == null) {
      AppToast.error('Please select a category.');
      return;
    }
    if (_entity == null) {
      AppToast.error('Please select an entity.');
      return;
    }
    if (_file == null) {
      AppToast.error('Please choose a file to upload.');
      return;
    }
    setState(() => _uploading = true);
    final ok = await _dc.uploadDocument(
      file: _file!,
      category: category,
      entityId: _entity!.id,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    if (ok) Navigator.pop(context);
  }
}
