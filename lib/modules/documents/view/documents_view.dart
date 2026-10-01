import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/web_network_image.dart';
import 'package:agremate_admin/modules/documents/controller/document_controller.dart';
import 'package:agremate_admin/modules/documents/model/document_model.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';

import '../../../core/widgets/full_pdf_page.dart';
import '../../../core/widgets/pdf_iframe_view.dart';

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
              const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 16),
              Text(
                dc.errorMessage.value,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: dc.refreshData,
                child: const Text('Retry'),
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
      color: const Color(0xFFF8FAFD),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: items.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(
                    'No properties found.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  const crossAxisCount = 4;
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
            : 'N/A';
    final hasImage = prop.imageUrl != null && prop.imageUrl!.trim().isNotEmpty;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.10),
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
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD6E8FA), width: 1.5),
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
                            color: Colors.white,
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
                                text: 'Landlord: ${prop.landlordName}',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _personLabel(
                                icon: Icons.groups_outlined,
                                text: 'Tenant: $tenantName',
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
    final files = dc.currentFiles;

    return ColoredBox(
      color: const Color(0xFFFBFDFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        property.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
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
                    padding: const EdgeInsets.all(32),
                    child: files.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.folder_off_rounded,
                                    color: Color(0xFFE2E8F0),
                                    size: 80,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No documents found for this property',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: files.length,
                            itemBuilder: (context, idx) {
                              final file = files[idx];
                              return InkWell(
                                onTap: () => _openDocument(context, file),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                                          color: file.fileColor
                                              .withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          file.fileIcon,
                                          color: file.fileColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              file.fileType?.toUpperCase() ??
                                                  'FILE',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
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

  void _showDocumentPreview(BuildContext context, DocumentModel file) {
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
                        color: Color(0xFF1E293B),
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
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      child: const Text('Open / Download'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
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
          'Document preview is not available.',
          style: TextStyle(color: Color(0xFF94A3B8)),
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
