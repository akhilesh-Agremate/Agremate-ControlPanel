import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/kpi_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'components/property_detail_panel.dart';

class PropertyView extends StatelessWidget {
  const PropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();
    final nav = Get.find<NavigationController>();
    final fmt = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN');

    return Obx(() {
      // Apply search from top bar
      if (nav.searchQuery.value != pc.searchQuery.value) {
        pc.search(nav.searchQuery.value);
      }

      final isDetailOpen = pc.selectedProperty.value != null;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isDetailOpen
            ? PropertyDetailPanel(property: pc.selectedProperty.value!)
            : SingleChildScrollView(
                key: const ValueKey('list'),
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Row
                    Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 2.0,
                            child: KpiCard(
                              title: 'Total Landlords',
                              value: '${pc.landlords.length}',
                              icon: Icons.person_rounded,
                              accentColor: AppTheme.landlordFill,
                              subtitle:
                                  '${pc.landlords.where((l) => l.isActive).length} active',
                              sparkData: [3, 5, 4, 7, 6, 8, 9, 7, 10, 12, 11, 15],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 2.0,
                            child: KpiCard(
                              title: 'Total Tenants',
                              value: '${pc.tenants.length}',
                              icon: Icons.groups_rounded,
                              accentColor: AppTheme.tenantFill,
                              subtitle:
                                  'across ${pc.properties.length} properties',
                              sparkData: [
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
                            aspectRatio: 2.0,
                            child: KpiCard(
                              title: 'Total Properties',
                              value: '${pc.properties.length}',
                              icon: Icons.apartment_rounded,
                              accentColor: AppTheme.accentGreen,
                              subtitle:
                                  '${pc.properties.where((p) => p.isRented).length} rented',
                              sparkData: [
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
                            aspectRatio: 2.0,
                            child: KpiCard(
                              title: 'Total Revenue',
                              value: fmt.format(
                                pc.landlords.fold<double>(
                                  0,
                                  (s, l) => s + l.totalRevenue,
                                ),
                              ),
                              icon: Icons.trending_up_rounded,
                              accentColor: AppTheme.accentPurple,
                              sparkData: [
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

                    // Property list header
                    Row(
                      children: [
                        Text('Properties', style: AppTheme.heading2),
                        const SizedBox(width: 8),
                        Text(
                          '(${pc.filteredProperties.length} total)',
                          style: AppTheme.caption,
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _showAddLandlordDialog(context, pc),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Landlord'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Property cards grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = 3;
                        final cardWidth =
                            (constraints.maxWidth - (16 * (crossAxisCount - 1))) /
                            crossAxisCount;

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children:
                              pc.currentPageProperties
                                  .map(
                                    (prop) => _PropertyCard(
                                      prop: prop,
                                      pc: pc,
                                      width: cardWidth,
                                      isSelected:
                                          pc.selectedProperty.value?.id ==
                                          prop.id,
                                    ),
                                  )
                                  .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    if (pc.totalPages > 1) _Pagination(pc: pc),
                  ],
                ),
              ),
      );
    });
  }

  void _showAddLandlordDialog(BuildContext context, PropertyController pc) {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final emailC = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Add Landlord',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneC,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailC,
                    decoration: const InputDecoration(labelText: 'Email'),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameC.text.isNotEmpty &&
                      phoneC.text.isNotEmpty &&
                      emailC.text.isNotEmpty) {
                    pc.addLandlord(nameC.text, phoneC.text, emailC.text);
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
    final fmt = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    // Visibility logic based on status
    final showTenant =
        prop.status == PropertyStatus.rented ||
        prop.status == PropertyStatus.booked ||
        prop.status == PropertyStatus.requested;

    final showLandlord =
        true; // Landlord is always displayed according to the rules

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
        glowColor:
            isSelected
                ? AppTheme.accentGreen
                : statusColor.withValues(alpha: 0.3),
        padding: EdgeInsets.zero,
        onTap: () => pc.selectedProperty.value = prop,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=400&h=200&auto=format&fit=crop',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (c, e, s) => Container(
                          height: 180,
                          width: double.infinity,
                          color: AppTheme.bgCardLight,
                          child: const Icon(
                            Icons.image_not_supported_rounded,
                            color: AppTheme.textMuted,
                          ),
                        ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: statusBadge,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          prop.name,
                          style: AppTheme.heading3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppTheme.textMuted,
                          size: 18,
                        ),
                        color: AppTheme.bgCardLight,
                        onSelected: (v) {
                          if (v == 'delete') {
                            pc.deleteLandlord(prop.landlordId);
                          }
                        },
                        itemBuilder:
                            (_) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete Property',
                                  style: TextStyle(color: AppTheme.accentRed),
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prop.address,
                    style: AppTheme.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Contact display based on status
                  if (showTenant && prop.primaryTenantName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            color: AppTheme.tenantFill,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Tenant: ${prop.primaryTenantName}',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.tenantFill,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (showLandlord)
                    Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          color: AppTheme.landlordFill,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Landlord: ${prop.landlordName}',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.landlordFill,
                              fontWeight: FontWeight.w600,
                            ),
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
                        style: const TextStyle(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
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

class _Pagination extends StatelessWidget {
  final PropertyController pc;
  const _Pagination({required this.pc});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                pc.currentPage.value > 1
                    ? () => pc.goToPage(pc.currentPage.value - 1)
                    : null,
            icon: Icon(
              Icons.chevron_left,
              color:
                  pc.currentPage.value > 1
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(pc.totalPages, (i) {
            final page = i + 1;
            final isActive = page == pc.currentPage.value;

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: () => pc.goToPage(page),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppTheme.accentGreen : AppTheme.bgCardLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? AppTheme.accentGreen : AppTheme.border,
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow:
                        isActive
                            ? [
                              BoxShadow(
                                color: AppTheme.accentGreen.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Text(
                    '$page',
                    style: TextStyle(
                      color:
                          isActive ? AppTheme.bgDark : AppTheme.textSecondary,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          IconButton(
            onPressed:
                pc.currentPage.value < pc.totalPages
                    ? () => pc.goToPage(pc.currentPage.value + 1)
                    : null,
            icon: Icon(
              Icons.chevron_right,
              color:
                  pc.currentPage.value < pc.totalPages
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted,
            ),
          ),
        ],
      );
    });
  }
}
