import 'dart:ui';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/kpi_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'components/property_detail_panel.dart';

class PropertyView extends StatelessWidget {
  const PropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();
    final fmt = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN');

    return Obx(() {
      final isDetailOpen = pc.selectedProperty.value != null;
      final isLoading = pc.isLoading.value;
      final page = pc.currentPage.value;
      final totalFiltered = pc.filteredProperties.length;
      final pageItems = pc.currentPageProperties;

      if (isDetailOpen) {
        return PropertyDetailPanel(property: pc.selectedProperty.value!);
      }

      return ColoredBox(
        color: const Color(0xFFF8FAFD),
          child: SingleChildScrollView(
        controller: pc.scrollController,
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Total Properties',
                      value: '${pc.kpiStats.value.totalProperties}',
                      icon: Icons.apartment_rounded,
                      accentColor: AppTheme.accentGreen,
                      subtitle: '${pc.kpiStats.value.rentedCount} rented',
                      sparkData: const [
                        4,
                        6,
                        5,
                        8,
                        7,
                        9,
                        10,
                        8,
                        11,
                        13,
                        12,
                        16,
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Total Landlords',
                      value: '${pc.kpiStats.value.totalLandlords}',
                      icon: Icons.person_rounded,
                      accentColor: AppTheme.landlordFill,
                      subtitle: '${pc.kpiStats.value.activeLandlordCount} active',
                      sparkData: const [3, 5, 4, 7, 6, 8, 9, 7, 10, 12, 11, 15],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Total Tenants',
                      value: '${pc.kpiStats.value.totalTenants}',
                      icon: Icons.groups_rounded,
                      accentColor: AppTheme.tenantFill,
                      subtitle:
                          'across ${pc.kpiStats.value.tenantsAcrossProperties} properties',
                      sparkData: const [
                        5,
                        8,
                        7,
                        9,
                        12,
                        10,
                        14,
                        13,
                        16,
                        18,
                        17,
                        25,
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Total Revenue',
                      value: fmt.format(pc.kpiStats.value.totalRevenue),
                      icon: Icons.trending_up_rounded,
                      accentColor: AppTheme.accentPurple,
                      sparkData: const [
                        10,
                        12,
                        15,
                        14,
                        18,
                        20,
                        19,
                        22,
                        25,
                        24,
                        28,
                        30,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Text('Properties', style: AppTheme.heading2),
                const SizedBox(width: 8),
                Text('($totalFiltered total)', style: AppTheme.caption),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddPropertyDialog(context, pc),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Property'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const crossAxisCount = 3;
                final cardWidth =
                    (constraints.maxWidth - 20 * (crossAxisCount - 1)) /
                    crossAxisCount;

                if (isLoading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (pageItems.isEmpty) {
                  return _EmptyState(
                    page: page,
                    onRefresh: pc.refreshProperties,
                  );
                }

                return Wrap(
                  key: ValueKey(
                    'page_$page',
                  ),
                  spacing: 20,
                  runSpacing: 24,
                  children:
                      pageItems
                          .map(
                            (prop) => _PropertyCard(
                              prop: prop,
                              pc: pc,
                              width: cardWidth,
                              isSelected:
                                  pc.selectedProperty.value?.id == prop.id,
                            ),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            _Pagination(pc: pc),
          ],
        ),
          ),
      );
    });
  }

  void _showAddPropertyDialog(BuildContext context, PropertyController pc) {
    final nameC = TextEditingController();
    final addressC = TextEditingController();
    final rentC = TextEditingController();
    final advanceC = TextEditingController();
    bool petsAllowed = false;
    Set<String> selectedAmenities = {};

    int? selectedBedrooms;
    int? selectedBathrooms;
    int? selectedKitchens;
    int? selectedBuiltYear;

    final amenitiesList = ['Game Room', 'Furnished', 'WiFi', 'Semi Furnished'];
    final yearList = List.generate(2027 - 1977 + 1, (index) => 1977 + index).reversed.toList();
    final countList = List.generate(10, (index) => index + 1);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: const Color(0xFFF8F9FB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Property',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildSection(
                            icon: Icons.info_outline_rounded,
                            title: 'Basic Info',
                            child: Column(
                              children: [
                                TextField(
                                  controller: nameC,
                                  decoration: const InputDecoration(
                                    labelText: 'Property Name',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: addressC,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    labelText: 'Address',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildSection(
                            icon: Icons.tune_rounded,
                            title: 'Features',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        value: selectedBedrooms,
                                        dropdownColor: Colors.white,
                                        items: countList.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                                        onChanged: (val) => setState(() => selectedBedrooms = val),
                                        decoration: InputDecoration(
                                          labelText: 'Bedrooms',
                                          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                          filled: true,
                                          fillColor: const Color(0xFFE0F2FE),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        value: selectedBathrooms,
                                        dropdownColor: Colors.white,
                                        items: countList.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                                        onChanged: (val) => setState(() => selectedBathrooms = val),
                                        decoration: InputDecoration(
                                          labelText: 'Bathrooms',
                                          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                          filled: true,
                                          fillColor: const Color(0xFFE0F2FE),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        value: selectedKitchens,
                                        dropdownColor: Colors.white,
                                        items: countList.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                                        onChanged: (val) => setState(() => selectedKitchens = val),
                                        decoration: InputDecoration(
                                          labelText: 'Kitchen',
                                          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                          filled: true,
                                          fillColor: const Color(0xFFE0F2FE),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        value: selectedBuiltYear,
                                        dropdownColor: Colors.white,
                                        items: yearList.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                                        onChanged: (val) => setState(() => selectedBuiltYear = val),
                                        decoration: InputDecoration(
                                          labelText: 'Built Year',
                                          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                          filled: true,
                                          fillColor: const Color(0xFFE0F2FE),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildSection(
                            icon: Icons.star_outline_rounded,
                            title: 'Amenities',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: amenitiesList.map((amenity) {
                                final isSelected = selectedAmenities.contains(amenity);
                                return _buildChip(
                                  label: amenity,
                                  isSelected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedAmenities.add(amenity);
                                      } else {
                                        selectedAmenities.remove(amenity);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildSection(
                            icon: Icons.pets_rounded,
                            title: 'Pets',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Pets Allowed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                ),
                                Switch(
                                  value: petsAllowed,
                                  activeColor: const Color(0xFF64748B),
                                  onChanged: (val) {
                                    setState(() => petsAllowed = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildSection(
                            icon: Icons.currency_rupee_rounded,
                            title: 'Pricing',
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: advanceC,
                                    decoration: const InputDecoration(
                                      labelText: 'Advance',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: TextField(
                                    controller: rentC,
                                    decoration: const InputDecoration(
                                      labelText: 'Rent',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.snackbar(
                              'Coming Soon',
                              'Property creation via API will be available soon.',
                              duration: const Duration(seconds: 3),
                            );
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Property',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required bool isSelected, required Function(bool) onSelected}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFEFF6FF),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF4A4A4A),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
        ),
      ),
      showCheckmark: false,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textMuted),
      filled: true,
      fillColor: AppTheme.bgCardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.accentGreen),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int page;
  final VoidCallback onRefresh;
  const _EmptyState({required this.page, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apartment_rounded,
            size: 90,
            color: AppTheme.textMuted.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 20),
          Text(
            page > 1 ? 'No Properties on Page $page' : 'No Properties Found',
            style: AppTheme.heading3.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            page > 1
                ? 'This page has no properties yet. New properties added by landlords will appear here automatically.'
                : 'No properties were returned from the API.',
            style: AppTheme.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh Now'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentGreen,
              side: const BorderSide(color: AppTheme.accentGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final PropertyModel prop;
  final PropertyController pc;
  final double width;
  final bool isSelected;
  const _PropertyCard({
    required this.prop,
    required this.pc,
    required this.width,
    this.isSelected = false,
  });

  static const double _cardHeight = 280;

  @override
  Widget build(BuildContext context) {
    final tenantName =
        (prop.primaryTenantName != null && prop.primaryTenantName!.isNotEmpty)
            ? prop.primaryTenantName!
            : 'N/A';
    final hasImage = prop.imageUrl != null && prop.imageUrl!.trim().isNotEmpty;

    Widget statusBadge;
    Color statusColor;
    switch (prop.status) {
      case PropertyStatus.rented:
        statusBadge = StatusBadge.rented();
        statusColor = AppTheme.statusRentedText;
        break;
      case PropertyStatus.available:
        statusBadge = StatusBadge.available();
        statusColor = AppTheme.statusAvailableText;
        break;
      case PropertyStatus.booked:
        statusBadge = StatusBadge.booked();
        statusColor = AppTheme.accentPurple;
        break;
      case PropertyStatus.requested:
        statusBadge = StatusBadge.requested();
        statusColor = AppTheme.statusRequestedText;
        break;
      case PropertyStatus.maintenance:
        statusBadge = StatusBadge.maintenance();
        statusColor = AppTheme.statusMaintenanceText;
        break;
      case PropertyStatus.unknown:
        statusBadge = StatusBadge.unknown();
        statusColor = const Color(0xFF9E9E9E);
        break;
    }

    return SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
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
              borderRadius: BorderRadius.circular(24),
              side: isSelected
                  ? const BorderSide(color: AppTheme.accentGreen, width: 2)
                  : const BorderSide(color: Color(0xFFD6E8FA), width: 1.5),
            ),
            child: InkWell(
              onTap: () => pc.openPropertyDetails(prop),
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
                  top: 12,
                  left: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBDBDBD).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          '₹ ${NumberFormat.decimalPattern('en_IN').format(prop.rentAmount)}/ Month',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 150,
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
                Positioned(top: 12, right: 12, child: statusBadge),

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              prop.address.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Pagination extends StatelessWidget {
  final PropertyController pc;
  const _Pagination({required this.pc});
  List<Widget> _buildPageButtons(int current, int total) {
    final Set<int> pagesToShow = {};
    pagesToShow.add(1);
    if (total > 0) pagesToShow.add(total);
    pagesToShow.add(current);
    final upperBound = current > total ? current : total;
    for (int d = -2; d <= 2; d++) {
      final p = current + d;
      if (p >= 1 && p <= upperBound) pagesToShow.add(p);
    }
    final sorted = pagesToShow.toList()..sort();

    final widgets = <Widget>[];
    int? prev;
    for (final page in sorted) {
      if (prev != null && page - prev > 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '…',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ),
        );
      }
      final isActive = page == current;
      widgets.add(
        InkWell(
          onTap: () => pc.goToPage(page),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.accentGreen : AppTheme.bgCardLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? AppTheme.accentGreen : AppTheme.border,
              ),
            ),
            child: Text(
              '$page',
              style: TextStyle(
                color: isActive ? AppTheme.bgDark : AppTheme.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
      prev = page;
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = pc.currentPage.value;
      final total = pc.totalPages;
      if (total <= 1) return const SizedBox.shrink();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (current > 1)
            IconButton(
              onPressed: () => pc.goToPage(current - 1),
              icon: const Icon(
                Icons.chevron_left,
                color: AppTheme.textPrimary,
              ),
            ),
          const SizedBox(width: 4),
          ..._buildPageButtons(current, total),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => pc.goToPage(current + 1),
            icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
          ),
        ],
      );
    });
  }
}
