import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/finance/controller/finance_controller.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/documents/controller/document_controller.dart';

class PropertyDetailPanel extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailPanel({super.key, required this.property});

  @override
  State<PropertyDetailPanel> createState() => _PropertyDetailPanelState();
}

class _PropertyDetailPanelState extends State<PropertyDetailPanel> {
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.property.imageUrl;
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

    // Show tenant card if the API returned tenant data, regardless of status
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

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white, // Light theme background
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (pc.returnTabIndex.value != null) {
                      nav.currentIndex.value = pc.returnTabIndex.value!;
                      pc.returnTabIndex.value = null;
                    }
                    pc.search(''); // Clear search filter
                    pc.selectedProperty.value = null;
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                  tooltip: 'Back to List',
                ),
                const SizedBox(width: 8),
                Text(
                  'Property Detail',
                  style: AppTheme.heading2.copyWith(color: Colors.black),
                ),
                const Spacer(),
                statusBadge,
              ],
            ),
          ),
          const Divider(color: Colors.black12, height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW 1: Image + Name/Desc
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child:
                                  _currentImageUrl != null
                                      ? Image.network(
                                        _currentImageUrl!,
                                        height: 280,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            height: 280,
                                            width: double.infinity,
                                            color: Colors.grey.shade100,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                color: AppTheme.accentGreen,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Container(
                                              height: 280,
                                              width: double.infinity,
                                              color: Colors.grey.shade100,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .image_not_supported_rounded,
                                                    color: Colors.grey.shade300,
                                                    size: 48,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Property Image Not Available',
                                                    style: AppTheme.bodyText
                                                        .copyWith(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade400,
                                                          fontSize: 14,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      )
                                      : Container(
                                        height: 280,
                                        width: double.infinity,
                                        color: Colors.grey.shade100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_not_supported_rounded,
                                              color: Colors.grey.shade300,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No Image Available',
                                              style: AppTheme.bodyText.copyWith(
                                                color: Colors.grey.shade400,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                            ),
                            if (widget.property.images.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.property.images.length,
                                  itemBuilder: (context, index) {
                                    final imgUrl =
                                        widget.property.images[index];
                                    final isSelected =
                                        _currentImageUrl == imgUrl;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(
                                          () => _currentImageUrl = imgUrl,
                                        );
                                        _showImageGallery(context, index);
                                      },
                                      child: Container(
                                        width: 60,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? AppTheme.accentGreen
                                                    : Colors.transparent,
                                            width: 2,
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
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              widget.property.name,
                              style: AppTheme.heading1.copyWith(
                                fontSize: 36,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.property.description?.isNotEmpty == true
                                  ? widget.property.description!
                                  : 'Premium ${widget.property.propertyType} located in the heart of ${widget.property.city}. Featuring modern architecture and top-tier security systems for a comfortable living experience.',
                              style: AppTheme.bodyText.copyWith(
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppTheme.accentRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${widget.property.address.address}, ${widget.property.city}',
                                    style: AppTheme.bodyText.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // MAIN BODY: Two-Column Layout to prevent vertical gaps
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN: Features, Amenities, Finance
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'Features & Facilities',
                              Colors.black,
                            ),
                            const SizedBox(height: 20),
                            Builder(
                              builder: (context) {
                                // Build features dynamically from API fields
                                final features = <Map<String, dynamic>>[];
                                if (widget.property.bedrooms > 0)
                                  features.add({
                                    'icon': Icons.bed_rounded,
                                    'label':
                                        '${widget.property.bedrooms} Bedroom${widget.property.bedrooms > 1 ? 's' : ''}',
                                  });
                                if (widget.property.bathrooms > 0)
                                  features.add({
                                    'icon': Icons.bathroom_rounded,
                                    'label':
                                        '${widget.property.bathrooms} Bathroom${widget.property.bathrooms > 1 ? 's' : ''}',
                                  });
                                if (widget.property.kitchen > 0)
                                  features.add({
                                    'icon': Icons.kitchen_rounded,
                                    'label':
                                        '${widget.property.kitchen} Kitchen${widget.property.kitchen > 1 ? 's' : ''}',
                                  });
                                if (widget.property.builtYear > 0)
                                  features.add({
                                    'icon': Icons.calendar_today_rounded,
                                    'label':
                                        'Built ${widget.property.builtYear}',
                                  });
                                final raw = widget.property.rawJson;
                                if (raw['hasElectricity'] == true)
                                  features.add({
                                    'icon': Icons.bolt_rounded,
                                    'label': 'Electricity',
                                  });
                                if (raw['hasWater'] == true)
                                  features.add({
                                    'icon': Icons.water_drop_rounded,
                                    'label': 'Water',
                                  });
                                if (raw['hasGas'] == true)
                                  features.add({
                                    'icon': Icons.local_fire_department_rounded,
                                    'label': 'Gas',
                                  });

                                if (features.isEmpty) {
                                  return Text(
                                    'No features data available',
                                    style: AppTheme.bodyText.copyWith(
                                      color: Colors.black38,
                                      fontSize: 13,
                                    ),
                                  );
                                }

                                return Wrap(
                                  spacing: 16,
                                  runSpacing: 12,
                                  children:
                                      features
                                          .map(
                                            (f) => _buildFeatureIcon(
                                              f['icon'] as IconData,
                                              f['label'] as String,
                                            ),
                                          )
                                          .toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            _buildSectionHeader('Amenities', Colors.black),
                            const SizedBox(height: 20),
                            widget.property.amenitiesList.isNotEmpty
                                ? Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children:
                                      widget.property.amenitiesList
                                          .map(
                                            (a) => _buildAmenityBox(
                                              a['name'] ?? '',
                                              _amenityIcon(a['name'] ?? ''),
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
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionHeader('Finance', Colors.black),
                                TextButton.icon(
                                  onPressed: () {
                                    final fc = Get.find<FinanceController>();
                                    fc.selectProperty(
                                      widget.property.id,
                                      widget.property.name,
                                    );
                                    nav.currentIndex.value = 3; // Finance tab
                                  },
                                  icon: const Icon(
                                    Icons.info_outline_rounded,
                                    size: 14,
                                    color: AppTheme.accentGreen,
                                  ),
                                  label: const Text(
                                    'More Details',
                                    style: TextStyle(
                                      color: AppTheme.accentGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppTheme.accentGreen
                                        .withValues(alpha: 0.1),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFinanceCard(
                                    'Monthly Rent',
                                    fmt.format(
                                      widget.property.agreementRentAmount ??
                                          widget.property.rentAmount,
                                    ),
                                    Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFinanceCard(
                                    'Advance',
                                    fmt.format(widget.property.advanceAmount),
                                    Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.property.agreementStartDate != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFinanceCard(
                                      'Agreement Start',
                                      DateFormat('dd MMM yyyy').format(
                                        widget.property.agreementStartDate!,
                                      ),
                                      Colors.black,
                                    ),
                                  ),
                                  if (widget.property.agreementPeriodMonths !=
                                      null) ...[
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildFinanceCard(
                                        'Agreement Period',
                                        '${widget.property.agreementPeriodMonths} months',
                                        Colors.black,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      // RIGHT COLUMN: Landlord, Tenant, Documents
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContactCard(
                              title: 'Landlord',
                              name: widget.property.landlordName,
                              phone:
                                  widget.property.landlordPhone?.isNotEmpty ==
                                          true
                                      ? widget.property.landlordPhone!
                                      : 'N/A',
                              email:
                                  widget.property.landlordEmail?.isNotEmpty ==
                                          true
                                      ? widget.property.landlordEmail!
                                      : 'N/A',
                              address: 'N/A',
                              accentColor: AppTheme.accentBlue,
                            ),
                            const SizedBox(height: 24),
                            showTenant
                                ? _buildContactCard(
                                  title: 'Tenant',
                                  name:
                                      widget.property.primaryTenantName ??
                                      'N/A',
                                  phone:
                                      widget
                                                  .property
                                                  .primaryTenantPhone
                                                  ?.isNotEmpty ==
                                              true
                                          ? widget.property.primaryTenantPhone!
                                          : 'N/A',
                                  email:
                                      widget
                                                  .property
                                                  .primaryTenantEmail
                                                  ?.isNotEmpty ==
                                              true
                                          ? widget.property.primaryTenantEmail!
                                          : 'N/A',
                                  address:
                                      widget.property.tenancyStartDate != null
                                          ? 'Since: ${DateFormat('dd MMM yyyy').format(widget.property.tenancyStartDate!)}'
                                          : widget.property.address.address,
                                  accentColor: AppTheme.accentGreen,
                                )
                                : Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.person_add_disabled_rounded,
                                        color: Colors.black38,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No Tenant Occupying',
                                        style: AppTheme.bodyText.copyWith(
                                          color: Colors.black45,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, [Color color = AppTheme.textMuted]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTheme.heading3.copyWith(
            fontSize: 14,
            letterSpacing: 2,
            color: color == Colors.black ? Colors.black54 : color,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black87, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.bodyText.copyWith(
              fontSize: 13,
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
      case 'ac':
      case 'air conditioning':
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

  Widget _buildAmenityBox(String label, IconData icon) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentCyan, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTheme.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.caption.copyWith(color: Colors.black45)),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.heading1.copyWith(color: color, fontSize: 28),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 12),
          _buildContactRow(Icons.phone_rounded, phone),
          const SizedBox(height: 8),
          _buildContactRow(Icons.email_rounded, email),
          const SizedBox(height: 8),
          _buildContactRow(Icons.location_on_rounded, address),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black38, size: 18),
        const SizedBox(width: 12),
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
                        onPressed:
                            currentIndex > 0
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
                        onPressed:
                            currentIndex < widget.property.images.length - 1
                                ? () => setDialogState(() => currentIndex++)
                                : null,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 40,
                    right: 40,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
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
