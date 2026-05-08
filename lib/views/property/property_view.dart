import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/kpi_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Row
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Total Landlords',
                    value: '${pc.landlords.length}',
                    icon: Icons.person_rounded,
                    accentColor: AppTheme.accentOrange,
                    subtitle:
                        '${pc.landlords.where((l) => l.isActive).length} active',
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

            // Property list header with Add/Delete
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
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  pc.currentPageProperties
                      .map((prop) => _PropertyCard(prop: prop, pc: pc))
                      .toList(),
            ),
            const SizedBox(height: 24),

            // Pagination
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

// class _LoginTile extends StatelessWidget {
//   final Map<String, dynamic> login;
//   const _LoginTile({required this.login});

//   @override
//   Widget build(BuildContext context) {
//     final isLandlord = login['type'] == 'landlord';
//     final time = login['time'] as DateTime;
//     final diff = DateTime.now().difference(time);
//     String ago;
//     if (diff.inMinutes < 60) { ago = '${diff.inMinutes}m ago'; }
//     else if (diff.inHours < 24) { ago = '${diff.inHours}h ago'; }
//     else { ago = '${diff.inDays}d ago'; }

//     return InkWell(
//       onTap: () => _showDetail(context),
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: (isLandlord ? AppTheme.accentOrange : AppTheme.accentCyan).withValues(alpha: 0.15),
//               child: Icon(isLandlord ? Icons.person : Icons.person_outline, color: isLandlord ? AppTheme.accentOrange : AppTheme.accentCyan, size: 16),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(login['name'] as String, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
//                   Text(ago, style: AppTheme.caption),
//                 ],
//               ),
//             ),
//             isLandlord ? StatusBadge.landlord() : StatusBadge.tenant(),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDetail(BuildContext context) {
//     final isLandlord = login['type'] == 'landlord';
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: AppTheme.bgCard,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(children: [
//           isLandlord ? StatusBadge.landlord() : StatusBadge.tenant(),
//           const SizedBox(width: 12),
//           Text(login['name'] as String, style: const TextStyle(color: AppTheme.textPrimary)),
//         ]),
//         content: Text(
//           isLandlord ? 'Properties owned: ${login['count']}' : 'Renting: ${login['property']}',
//           style: const TextStyle(color: AppTheme.textSecondary),
//         ),
//         actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
//       ),
//     );
//   }
// }

class _PropertyCard extends StatelessWidget {
  final dynamic prop;
  final PropertyController pc;
  const _PropertyCard({required this.prop, required this.pc});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );
    return SizedBox(
      width: 300,
      child: GlassCard(
        glowColor: AppTheme.accentOrange.withValues(alpha: 0.5),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=300&h=150&auto=format&fit=crop',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (c, e, s) => Container(
                      height: 120,
                      width: double.infinity,
                      color: AppTheme.bgCardLight,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_rounded,
                            color: AppTheme.textMuted,
                            size: 28,
                          ),
                          SizedBox(height: 6),
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
            const SizedBox(height: 16),
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
                            'Delete Landlord',
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
            Row(
              children: [
                StatusBadge(
                  label: prop.propertyType,
                  color: AppTheme.accentPurple,
                ),
                const Spacer(),
                Text(
                  fmt.format(prop.rentAmount),
                  style: TextStyle(
                    color: AppTheme.accentGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text('/mo', style: AppTheme.caption),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  color: AppTheme.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    prop.landlordName,
                    style: AppTheme.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${prop.occupiedUnits}/${prop.totalUnits} units',
                  style: AppTheme.caption,
                ),
              ],
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
