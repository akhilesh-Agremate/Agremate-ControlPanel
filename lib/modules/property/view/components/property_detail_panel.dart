import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/web_network_image.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/finance/controller/finance_controller.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import '../../../../core/widgets/full_pdf_page.dart';
import '../../../../core/widgets/pdf_iframe_view.dart';

class PropertyDetailPanel extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailPanel({super.key, required this.property});

  @override
  State<PropertyDetailPanel> createState() => _PropertyDetailPanelState();
}

class _PropertyDetailPanelState extends State<PropertyDetailPanel> {
  String? _currentImageUrl;
  String? _openDocName;
  String? _openDocUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.property.imageUrl;
  }

  @override
  void didUpdateWidget(covariant PropertyDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.property.id != widget.property.id ||
        oldWidget.property.imageUrl != widget.property.imageUrl) {
      _currentImageUrl = widget.property.imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();
    final nav = Get.find<NavigationController>();
    final fmt = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    final showTenant =
        widget.property.primaryTenantName != null &&
        widget.property.primaryTenantName!.isNotEmpty;

    Widget statusBadge;
    switch (widget.property.status) {
      case PropertyStatus.rented:
        statusBadge = StatusBadge.rented();
        break;
      case PropertyStatus.available:
        statusBadge = StatusBadge.available();
        break;
      case PropertyStatus.booked:
        statusBadge = StatusBadge.booked();
        break;
      case PropertyStatus.requested:
        statusBadge = StatusBadge.requested();
        break;
      case PropertyStatus.maintenance:
        statusBadge = StatusBadge.maintenance();
        break;
      case PropertyStatus.unknown:
        statusBadge = StatusBadge.unknown();
        break;
    }

    final landlordCard = _buildContactCard(
      title: 'Landlord',
      name: widget.property.landlordName,
      phone: widget.property.landlordPhone?.isNotEmpty == true
          ? widget.property.landlordPhone!
          : 'N/A',
      email: widget.property.landlordEmail?.isNotEmpty == true
          ? widget.property.landlordEmail!
          : 'N/A',
      address: widget.property.landlordAddress?.isNotEmpty == true
          ? widget.property.landlordAddress!
          : 'N/A',
      accentColor: AppTheme.accentBlue,
    );

    final tenantCard = showTenant
        ? _buildContactCard(
            title: 'Tenant',
            name: widget.property.primaryTenantName ?? 'N/A',
            phone: widget.property.primaryTenantPhone?.isNotEmpty == true
                ? widget.property.primaryTenantPhone!
                : 'N/A',
            email: widget.property.primaryTenantEmail?.isNotEmpty == true
                ? widget.property.primaryTenantEmail!
                : 'N/A',
            address: widget.property.address.address.isNotEmpty
                ? widget.property.address.address
                : 'N/A',
            accentColor: AppTheme.accentGreen,
          )
        : _buildEmptyTenantCard();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF8FAFD),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_openDocName != null) {
                      setState(() {
                        _openDocName = null;
                        _openDocUrl = null;
                      });
                      return;
                    }
                    if (pc.returnTabIndex.value != null) {
                      nav.currentIndex.value = pc.returnTabIndex.value!;
                      pc.returnTabIndex.value = null;
                    }
                    pc.search('');
                    pc.closePropertyDetails();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 8),
                Text(
                  _openDocName ?? 'Property Detail',
                  style: AppTheme.heading2.copyWith(color: Colors.black),
                ),
                const Spacer(),
                statusBadge,
              ],
            ),
          ),
          const Divider(color: Colors.black12, height: 1),
          Obx(
            () => pc.isDetailLoading.value
                ? const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppTheme.accentBlue,
                    backgroundColor: Color(0xFFE8F1FB),
                  )
                : const SizedBox(height: 2),
          ),
          Expanded(
            child: _openDocName != null
                ? _buildDocumentViewer()
                : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 920;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroRow(),
                      const SizedBox(height: 20),
                      _buildDetailsAndContacts(
                        isWide: isWide,
                        landlordCard: landlordCard,
                        tenantCard: tenantCard,
                        fmt: fmt,
                        nav: nav,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsAndContacts({
    required bool isWide,
    required Widget landlordCard,
    required Widget tenantCard,
    required NumberFormat fmt,
    required NavigationController nav,
  }) {
    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Features & Facilities'),
        const SizedBox(height: 8),
        _buildFeaturesWrap(),
        const SizedBox(height: 12),
        _buildSectionHeader('Amenities'),
        const SizedBox(height: 8),
        widget.property.amenitiesList.isNotEmpty
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.property.amenitiesList
                    .map(
                      (a) => _buildFeatureIcon(
                        _amenityIcon(a['name'] ?? ''),
                        a['name'] ?? '',
                      ),
                    )
                    .toList(),
              )
            : Text(
                'No amenities data available',
                style: AppTheme.bodyText.copyWith(
                  color: Colors.black38,
                  fontSize: 13,
                ),
              ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSectionHeader('Finance'),
            const Spacer(),
            _buildMoreDetailsButton(nav),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFinanceCard(
                'Monthly Rent',
                fmt.format(
                  widget.property.agreementRentAmount ??
                      widget.property.rentAmount,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinanceCard(
                'Advance',
                fmt.format(widget.property.advanceAmount),
              ),
            ),
          ],
        ),
        if (widget.property.agreementStartDate != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFinanceCard(
                  'Agreement Start',
                  DateFormat('dd MMM yyyy').format(
                    widget.property.agreementStartDate!,
                  ),
                ),
              ),
              if (widget.property.agreementPeriodMonths != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinanceCard(
                    'Agreement Period',
                    '${widget.property.agreementPeriodMonths} months',
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );

    final rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        landlordCard,
        const SizedBox(height: 12),
        tenantCard,
        const SizedBox(height: 12),
        _buildDocumentsSection(),
      ],
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftColumn,
          const SizedBox(height: 12),
          rightColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: leftColumn),
        const SizedBox(width: 24),
        Expanded(flex: 5, child: rightColumn),
      ],
    );
  }

  Widget _buildMoreDetailsButton(NavigationController nav) {
    return TextButton.icon(
      onPressed: () {
        final fc = Get.find<FinanceController>();
        fc.selectProperty(widget.property.id, widget.property.name);
        nav.currentIndex.value = 3;
      },
      icon: const Icon(
        Icons.info_outline_rounded,
        size: 14,
        color: AppTheme.accentBlue,
      ),
      label: const Text(
        'More Details',
        style: TextStyle(
          color: AppTheme.accentBlue,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.08),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildHeroRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 720;
        final image = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildHeroImage(180),
            ),
            if (widget.property.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.property.images.length,
                  itemBuilder: (context, index) {
                    final imgUrl = widget.property.images[index];
                    final isSelected = _currentImageUrl == imgUrl;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _currentImageUrl = imgUrl);
                        _showImageGallery(context, index);
                      },
                      child: Container(
                        width: 48,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accentBlue
                                : Colors.black12,
                            width: isSelected ? 2 : 1,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(imgUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );

        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.property.name,
              style: AppTheme.heading1.copyWith(
                fontSize: 26,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.property.description?.isNotEmpty == true
                  ? widget.property.description!
                  : 'Premium ${widget.property.propertyTypeLabel} located in the heart of ${widget.property.city}.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bodyText.copyWith(
                height: 1.45,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppTheme.accentRed,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.property.address.address,
                    style: AppTheme.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image,
              const SizedBox(height: 16),
              info,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: image),
            const SizedBox(width: 24),
            Expanded(flex: 5, child: info),
          ],
        );
      },
    );
  }

  Widget _buildHeroImage(double height) {
    if (_currentImageUrl == null) {
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: Color(0xFFCBD5E1),
          size: 40,
        ),
      );
    }

    return Image.network(
      _currentImageUrl!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: double.infinity,
          color: Colors.grey.shade100,
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.accentBlue),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: double.infinity,
          color: Colors.grey.shade100,
          child: const Icon(
            Icons.image_not_supported_rounded,
            color: Color(0xFFCBD5E1),
            size: 40,
          ),
        );
      },
    );
  }

  Widget _buildFeaturesWrap() {
    final features = <Map<String, dynamic>>[];
    if (widget.property.bedrooms > 0) {
      features.add({
        'icon': Icons.bed_rounded,
        'label':
            '${widget.property.bedrooms} Bedroom${widget.property.bedrooms > 1 ? 's' : ''}',
      });
    }
    if (widget.property.bathrooms > 0) {
      features.add({
        'icon': Icons.bathroom_rounded,
        'label':
            '${widget.property.bathrooms} Bathroom${widget.property.bathrooms > 1 ? 's' : ''}',
      });
    }
    if (widget.property.kitchen > 0) {
      features.add({
        'icon': Icons.kitchen_rounded,
        'label':
            '${widget.property.kitchen} Kitchen${widget.property.kitchen > 1 ? 's' : ''}',
      });
    }
    if (widget.property.builtYear > 0) {
      features.add({
        'icon': Icons.calendar_today_rounded,
        'label': 'Built ${widget.property.builtYear}',
      });
    }

    if (features.isEmpty) {
      return Text(
        'No features data available',
        style: AppTheme.bodyText.copyWith(color: Colors.black38, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features
          .map(
            (f) => _buildFeatureIcon(
              f['icon'] as IconData,
              f['label'] as String,
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTheme.heading3.copyWith(
        fontSize: 12,
        letterSpacing: 1.4,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.accentBlue, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  IconData _amenityIcon(String name) {
    switch (name.toLowerCase()) {
      case 'balcony':
        return Icons.balcony;
      case 'parking':
        return Icons.local_parking;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'bakery':
        return Icons.bakery_dining;
      case 'gym':
        return Icons.fitness_center;
      case 'pool':
      case 'swimming pool':
        return Icons.pool;
      case 'wifi':
      case 'fast wifi':
        return Icons.wifi;
      case 'garden':
      case 'park':
        return Icons.park;
      case 'security':
        return Icons.security_rounded;
      case 'elevator':
      case 'lift':
        return Icons.elevator;
      case 'food':
        return Icons.restaurant_rounded;
      case 'fire safety':
        return Icons.local_fire_department_rounded;
      case 'ac':
      case 'air conditioning':
      case 'central ac':
        return Icons.ac_unit;
      case 'large room':
        return Icons.king_bed_rounded;
      case 'washroom':
      case 'bathroom':
        return Icons.bathroom_rounded;
      case 'kitchen':
        return Icons.kitchen;
      case 'storage':
        return Icons.inventory_2_rounded;
      case 'cctv':
        return Icons.videocam_rounded;
      case 'power backup':
        return Icons.battery_charging_full_rounded;
      case 'gas':
        return Icons.local_fire_department_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Widget _buildFinanceCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.caption.copyWith(color: Colors.black45)),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTheme.heading1.copyWith(color: Colors.black, fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String name,
    required String phone,
    required String email,
    required String address,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.caption.copyWith(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      name,
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildContactRow(Icons.phone_rounded, phone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactRow(Icons.email_rounded, email),
              ),
            ],
          ),
          if (address.isNotEmpty && address != 'N/A') ...[
            const SizedBox(height: 8),
            _buildContactRow(Icons.location_on_rounded, address),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    final docs = <Map<String, String>>[];
    for (final item in widget.property.documents) {
      if (item is! Map) continue;
      final json = Map<String, dynamic>.from(item);
      final name =
          (json['fileName'] ?? json['name'] ?? 'Document').toString();
      final fileUrl = _documentUrl(
        (json['relativePath'] ?? json['url'] ?? json['fileUrl'] ?? '')
            .toString(),
      );
      final thumbUrl = _documentUrl(
        (json['thumbnailUrl'] ?? '').toString(),
      );
      final type = (json['documentType'] ?? json['fileType'] ?? '').toString();
      docs.add({
        'name': name,
        'url': fileUrl.isNotEmpty ? fileUrl : thumbUrl,
        'thumb': thumbUrl.isNotEmpty ? thumbUrl : fileUrl,
        'type': type,
      });
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: AppTheme.accentBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Documents',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.accentBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (docs.isEmpty)
            Text(
              'No documents available',
              style: AppTheme.bodyText.copyWith(
                color: Colors.black38,
                fontSize: 13,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < docs.length; i++)
                  _buildDocumentThumb(
                    index: i,
                    name: docs[i]['name']!,
                    url: docs[i]['url']!,
                    thumb: docs[i]['thumb']!,
                    type: docs[i]['type']!,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentThumb({
    required int index,
    required String name,
    required String url,
    required String thumb,
    required String type,
  }) {
    final isImage = _isImageDocument(name, type) || _isImageDocument(thumb, '');
    final isPdf = _isPdfDocument('$name $url', type);
    final Color accent = isPdf
        ? Colors.red.shade400
        : isImage
            ? const Color(0xFF3B82F6)
            : AppTheme.accentBlue;

    return KeyedSubtree(
      key: ValueKey('property_doc_${index}_${name}_$url'),
      child: InkWell(
        onTap: () {
          final docUrl = url.isNotEmpty ? url : thumb;
          if (isPdf) {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => FullPdfPage(url: docUrl, title: name),
              ),
            );
            return;
          }
          setState(() {
            _openDocName = name;
            _openDocUrl = docUrl;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6E6F8)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isImage && thumb.isNotEmpty
                ? Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: Colors.white,
                      child: Icon(
                        Icons.image_outlined,
                        color: accent,
                        size: 28,
                      ),
                    ),
                  )
                : ColoredBox(
                    color: Colors.white,
                    child: Icon(
                      isPdf
                          ? Icons.picture_as_pdf_rounded
                          : isImage
                              ? Icons.image_outlined
                              : Icons.insert_drive_file_outlined,
                      color: accent,
                      size: 28,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentViewer() {
    final url = _openDocUrl ?? '';
    final isPdf = _isPdfDocument('${_openDocName ?? ''} $url', '');

    return ColoredBox(
      color: const Color(0xFFF8FAFD),
      child: url.isEmpty
          ? Center(
        child: Text(
          'Document preview is not available.',
          style: AppTheme.bodyText,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(24),
        child: isPdf
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PdfIframeView(key: ValueKey(url), url: url),
        )
            : WebNetworkImage(url: url, fit: BoxFit.contain),
      ),
    );
  }

  String _documentUrl(String path) {
    final value = path.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'https://amplify-agremate-dev-76a83-deployment.s3.ap-south-1.amazonaws.com/${value.startsWith('/') ? value.substring(1) : value}';
  }

  bool _isImageDocument(String name, String type) {
    final lower = '${name.toLowerCase()} ${type.toLowerCase()}';
    return lower.contains('image') ||
        lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.gif') ||
        lower.contains('.webp');
  }

  bool _isPdfDocument(String nameAndUrl, String type) {
    final lower = '${nameAndUrl.toLowerCase()} ${type.toLowerCase()}';
    return lower.contains('pdf') ||
        lower.contains('.pdf') ||
        lower.contains('application/pdf');
  }

  Widget _buildEmptyTenantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_add_disabled_rounded,
            color: Colors.black38,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'No Tenant Occupying',
            style: AppTheme.bodyText.copyWith(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black38, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyText.copyWith(
              fontSize: 13,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showImageGallery(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        int currentIndex = initialIndex;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withValues(alpha: 0.9),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                        onPressed: currentIndex > 0
                            ? () => setDialogState(() => currentIndex--)
                            : null,
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.property.images[currentIndex],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                        onPressed: currentIndex <
                                widget.property.images.length - 1
                            ? () => setDialogState(() => currentIndex++)
                            : null,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 40,
                    right: 40,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    child: Text(
                      '${currentIndex + 1} / ${widget.property.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
