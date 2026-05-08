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
      // Reading these reactive values inside Obx ensures rebuild on any change
      final isDetailOpen = pc.selectedProperty.value != null;
      final isLoading = pc.isLoading.value;
      final page = pc.currentPage.value;
      final totalFiltered = pc.filteredProperties.length;

      // Compute page slice directly here — no caching, no stale state
      final pageItems = pc.currentPageProperties;

      if (isDetailOpen) {
        return PropertyDetailPanel(property: pc.selectedProperty.value!);
      }

      return SingleChildScrollView(
        controller: pc.scrollController,
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── KPI Row ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Total Landlords',
                      value: '${pc.landlords.length}',
                      icon: Icons.person_rounded,
                      accentColor: AppTheme.landlordFill,
                      subtitle: '${pc.landlords.length} active',
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
                      value: '${pc.tenants.length}',
                      icon: Icons.groups_rounded,
                      accentColor: AppTheme.tenantFill,
                      subtitle: 'across ${pc.properties.length} properties',
                      sparkData: const [5, 8, 7, 9, 12, 10, 14, 13, 16, 18, 17, 25],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Total Properties',
                      value: '${pc.properties.length}',
                      icon: Icons.apartment_rounded,
                      accentColor: AppTheme.accentGreen,
                      subtitle: '${pc.properties.where((p) => p.isRented).length} rented',
                      sparkData: const [4, 6, 5, 8, 7, 9, 10, 8, 11, 13, 12, 16],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Total Revenue',
                      value: fmt.format(pc.landlords.fold<double>(0, (s, l) => s + (l.totalRevenue ?? 0))),
                      icon: Icons.trending_up_rounded,
                      accentColor: AppTheme.accentPurple,
                      sparkData: const [10, 12, 15, 14, 18, 20, 19, 22, 25, 24, 28, 30],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Header ─────────────────────────────────────────────────────
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
                    backgroundColor: AppTheme.accentGreen,
                    foregroundColor: AppTheme.bgDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Grid ───────────────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                const crossAxisCount = 3;
                final cardWidth = (constraints.maxWidth - 16 * (crossAxisCount - 1)) / crossAxisCount;

                if (isLoading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (pageItems.isEmpty) {
                  return _EmptyState(page: page, onRefresh: pc.refreshProperties);
                }

                return Wrap(
                  key: ValueKey('page_$page'),   // force widget tree rebuild each page
                  spacing: 16,
                  runSpacing: 16,
                  children: pageItems
                      .map((prop) => _PropertyCard(
                            prop: prop,
                            pc: pc,
                            width: cardWidth,
                            isSelected: pc.selectedProperty.value?.id == prop.id,
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // ── Pagination ─────────────────────────────────────────────────
            _Pagination(pc: pc),
          ],
        ),
      );
    });
  }

  void _showAddPropertyDialog(BuildContext context, PropertyController pc) {
    final nameC = TextEditingController();
    final addressC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Property',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Property Name',
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
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressC,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Address',
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
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monthly Rent',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.bgCardLight,
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(color: AppTheme.textPrimary),
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
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: AppTheme.bgDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (nameC.text.isNotEmpty && addressC.text.isNotEmpty) {
                Get.snackbar(
                  'Coming Soon',
                  'Property creation via API will be available soon.',
                  duration: const Duration(seconds: 3),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────
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

// ── Property Card ─────────────────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    final showTenant = prop.status == PropertyStatus.rented ||
        prop.status == PropertyStatus.booked;

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
    }

    return SizedBox(
      width: width,
      child: GlassCard(
        glowColor: isSelected ? AppTheme.accentGreen : statusColor.withValues(alpha: 0.2),
        padding: EdgeInsets.zero,
        onTap: () => pc.selectedProperty.value = prop,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    prop.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 180,
                      width: double.infinity,
                      color: AppTheme.bgCardLight,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_rounded,
                            color: AppTheme.textMuted,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image Not Available',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(top: 12, right: 12, child: statusBadge),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prop.name, style: AppTheme.heading3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(
                    prop.address.address,
                    style: AppTheme.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (showTenant && prop.primaryTenantName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, color: AppTheme.tenantFill, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Tenant: ${prop.primaryTenantName}',
                              style: AppTheme.caption.copyWith(color: AppTheme.tenantFill, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, color: AppTheme.landlordFill, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Landlord: ${prop.landlordName}',
                          style: AppTheme.caption.copyWith(color: AppTheme.landlordFill, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        fmt.format(prop.rentAmount),
                        style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text('/month', style: AppTheme.caption),
                      const Spacer(),
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 4),
                      Text(prop.statusLabel, style: AppTheme.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pagination ────────────────────────────────────────────────────────────────
class _Pagination extends StatelessWidget {
  final PropertyController pc;
  const _Pagination({required this.pc});

  /// Builds a smart windowed page list:
  /// Always shows first, last, current ±2, with '…' gaps in between.
  List<Widget> _buildPageButtons(int current, int total) {
    final Set<int> pagesToShow = {};
    // Always anchor: page 1 and the last known data page
    pagesToShow.add(1);
    if (total > 0) pagesToShow.add(total);
    // Always include current page (even if it exceeds total)
    pagesToShow.add(current);
    // Show neighbours bounded by 1 on left; on right extend up to max(total, current)
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
        // Ellipsis gap
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('…',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
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
                  color: isActive ? AppTheme.accentGreen : AppTheme.border),
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
          // ← Prev
          IconButton(
            onPressed: current > 1 ? () => pc.goToPage(current - 1) : null,
            icon: Icon(Icons.chevron_left,
                color: current > 1 ? AppTheme.textPrimary : AppTheme.textMuted),
          ),
          const SizedBox(width: 4),
          // Page buttons with smart windowing
          ..._buildPageButtons(current, total),
          const SizedBox(width: 4),
          // → Next (no upper bound — allows navigating to empty pages)
          IconButton(
            onPressed: () => pc.goToPage(current + 1),
            icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
          ),
        ],
      );
    });
  }
}
