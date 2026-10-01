import 'dart:ui';

import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/kpi_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../modules/property/model/property_model.dart';

class PropertyView extends StatelessWidget {
  const PropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();
    final nav = Get.find<NavigationController>();
    final fmt = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN');

    return Obx(() {
      if (nav.searchQuery.value != pc.searchQuery.value) {
        pc.search(nav.searchQuery.value);
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Total Landlords',
                    value: '${pc.landlords.length}',
                    icon: Icons.person_rounded,
                    accentColor: AppTheme.accentOrange,
                    subtitle:
                        '${pc.landlords.where((l) => l?.isActive == true).length} active',
                    sparkData: [3, 5, 4, 7, 6, 8, 9, 7, 10, 12, 11, 15],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KpiCard(
                    title: 'Total Tenants',
                    value: '${pc.tenants.length}',
                    icon: Icons.groups_rounded,
                    accentColor: AppTheme.accentCyan,
                    subtitle: 'across ${pc.properties.length} properties',
                    sparkData: [5, 8, 7, 9, 12, 10, 14, 13, 16, 18, 17, 25],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KpiCard(
                    title: 'Total Properties',
                    value: '${pc.properties.length}',
                    icon: Icons.apartment_rounded,
                    accentColor: AppTheme.accentGreen,
                    subtitle:
                        '${pc.properties.where((p) => p.isRented).length} rented',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            const SizedBox(height: 16),
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
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  pc.currentPageProperties
                      .map((prop) => _PropertyCard(prop: prop, pc: pc))
                      .toList(),
            ),
            const SizedBox(height: 24),

            if (pc.totalPages > 1) _Pagination(pc: pc),
          ],
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
    this.width = 300,
    this.isSelected = false,
  });

  static const double _cardHeight = 280;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    final showTenant =
        prop.primaryTenantName != null && prop.primaryTenantName!.isNotEmpty;
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
      child: GlassCard(
        glowColor: isSelected
            ? AppTheme.accentGreen
            : statusColor.withValues(alpha: 0.2),
        padding: EdgeInsets.zero,
        onTap: () => pc.selectedProperty.value = prop,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
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
                  top: 0,
                  height: 90,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
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

                Positioned(
                  top: 12,
                  left: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '${fmt.format(prop.rentAmount)}/ Month',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                          if (showTenant) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: _personLabel(
                                icon: Icons.person_outline_rounded,
                                text: 'Tenant: ${prop.primaryTenantName}',
                              ),
                            ),
                          ],
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

  @override
  Widget build(BuildContext context) {
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
        ...List.generate(pc.totalPages, (i) {
          final page = i + 1;
          final isActive = page == pc.currentPage.value;
          return GestureDetector(
            onTap: () => pc.goToPage(page),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
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
  }
}
