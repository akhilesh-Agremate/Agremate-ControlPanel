import 'dart:ui';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/core/widgets/kpi_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'components/property_detail_panel.dart';
import 'components/add_property_panel.dart';

class PropertyView extends StatelessWidget {
  const PropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();
    final fmt = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN');

    return Obx(() {
      final auth =
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
      final canAddProperty =
          auth == null || auth.isLandlord || !auth.isRestrictedRole;

      final isAddOpen = pc.isAddOpen.value && canAddProperty;
      final isDetailOpen = pc.selectedProperty.value != null;
      final isLoading = pc.isLoading.value;
      final page = pc.currentPage.value;
      final totalFiltered = pc.filteredProperties.length;
      final pageItems = pc.currentPageProperties;

      debugPrint(
          'PropertyView build: isAddOpen=${pc.isAddOpen.value} canAdd=$canAddProperty');
      if (isAddOpen) {
        return AddPropertyPanel(
          onBack: () => pc.isAddOpen.value = false,
          onSubmit: (data) => pc.createProperty(data),
          amenityOptions: pc.amenities.toList(),
          amenitiesLoading: pc.isAmenitiesLoading.value,
          featureOptions: pc.featureOptions.toList(),
          featuresLoading: pc.isFeaturesLoading.value,
        );
      }

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
                        sparkData: pc.kpiStats.value.propertiesSparkline.isEmpty
                            ? const [4.0, 6.0, 5.0, 8.0, 7.0, 9.0, 10.0, 8.0, 11.0, 13.0, 12.0, 16.0]
                            : pc.kpiStats.value.propertiesSparkline,
                        sparkLabels: pc.kpiStats.value.chartLabels.isEmpty
                            ? null
                            : pc.kpiStats.value.chartLabels,
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
                        subtitle:
                        '${pc.kpiStats.value.activeLandlordCount} active',
                        sparkData: pc.kpiStats.value.landlordsSparkline.isEmpty
                            ? const [3.0, 5.0, 4.0, 7.0, 6.0, 8.0, 9.0, 7.0, 10.0, 12.0, 11.0, 15.0]
                            : pc.kpiStats.value.landlordsSparkline,
                        sparkLabels: pc.kpiStats.value.chartLabels.isEmpty
                            ? null
                            : pc.kpiStats.value.chartLabels,
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
                        sparkData: pc.kpiStats.value.tenantsSparkline.isEmpty
                            ? const [5.0, 8.0, 7.0, 9.0, 12.0, 10.0, 14.0, 13.0, 16.0, 18.0, 17.0, 25.0]
                            : pc.kpiStats.value.tenantsSparkline,
                        sparkLabels: pc.kpiStats.value.chartLabels.isEmpty
                            ? null
                            : pc.kpiStats.value.chartLabels,
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
                        sparkData: pc.kpiStats.value.revenueSparkline.isEmpty
                            ? const [10.0, 12.0, 15.0, 14.0, 18.0, 20.0, 19.0, 22.0, 25.0, 24.0, 28.0, 30.0]
                            : pc.kpiStats.value.revenueSparkline,
                        sparkLabels: pc.kpiStats.value.chartLabels.isEmpty
                            ? null
                            : pc.kpiStats.value.chartLabels,
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
                  Text('($totalFiltered properties)', style: AppTheme.caption),
                  const Spacer(),
                  if (auth != null && auth.isSuperAdmin) ...[
                    _CategoryFilterSelector(pc: pc),
                    const SizedBox(width: 16),
                  ],
                  if (canAddProperty)
                    ElevatedButton.icon(
                      onPressed: () {
                        debugPrint('Add Property clicked');
                        pc.openAddProperty();
                      },
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
                    key: ValueKey('page_$page'),
                    spacing: 20,
                    runSpacing: 24,
                    children: pageItems
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
    switch (prop.status) {
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBDBDBD)
                                .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6)),
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
              icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
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

class _CategoryFilterSelector extends StatelessWidget {
  final PropertyController pc;
  const _CategoryFilterSelector({required this.pc});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentFilter = pc.selectedCategoryFilter.value;
      final totalCount = pc.totalPropertiesCount;
      final pgCount = pc.pgPropertiesCount;
      final individualCount = pc.individualPropertiesCount;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTab(
              label: 'All',
              count: totalCount,
              isSelected: currentFilter == PropertyCategoryFilter.all,
              onTap: () => pc.setCategoryFilter(PropertyCategoryFilter.all),
            ),
            const SizedBox(width: 4),
            _buildTab(
              label: 'PG',
              count: pgCount,
              isSelected: currentFilter == PropertyCategoryFilter.pg,
              onTap: () => pc.setCategoryFilter(PropertyCategoryFilter.pg),
            ),
            const SizedBox(width: 4),
            _buildTab(
              label: 'Individual',
              count: individualCount,
              isSelected: currentFilter == PropertyCategoryFilter.individual,
              onTap: () =>
                  pc.setCategoryFilter(PropertyCategoryFilter.individual),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTab({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF2F6BFF)
                      : const Color(0xFF5A6A85),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF2F6BFF)
                        : const Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}