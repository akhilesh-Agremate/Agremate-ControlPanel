import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/constants/constants.dart';
import 'package:agremate_admin/modules/services/controller/services_controller.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<ServicesController>();
    final nav = Get.find<NavigationController>();

    return Obx(() {
      if (nav.searchQuery.value.isNotEmpty) {
        sc.search(nav.searchQuery.value);
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service Categories', style: AppTheme.heading2),
            const SizedBox(height: 4),
            Text('Click on a service to view property requests', style: AppTheme.caption),
            const SizedBox(height: 24),
            // Service cards grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: AppConstants.serviceTypes.map((type) {
                final color = AppConstants.serviceColors[type] ?? AppTheme.accentCyan;
                final icon = AppConstants.serviceIcons[type] ?? Icons.build;
                final count = sc.serviceCounts[type] ?? 0;
                final pending = sc.pendingCounts[type] ?? 0;
                final isSelected = sc.selectedServiceType.value == type;

                return SizedBox(
                  width: 220,
                  child: GlassCard(
                    glowColor: isSelected ? color : color.withValues(alpha: 0.5),
                    onTap: () {
                      sc.selectServiceType(type);
                      _showRequestsDialog(context, sc, type, color);
                    },
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 20),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(type, style: AppTheme.heading3),
                        const SizedBox(height: 6),
                        Text('$count requests', style: AppTheme.bodyText),
                        if (pending > 0) ...[
                          const SizedBox(height: 4),
                          Text('$pending pending', style: TextStyle(color: AppTheme.accentYellow, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  void _showRequestsDialog(BuildContext context, ServicesController sc, String type, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text('$type Requests', style: const TextStyle(color: AppTheme.textPrimary)),
            const Spacer(),
            Obx(() => StatusBadge(
              label: '${sc.filteredRequests.length} total',
              color: color,
            )),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Obx(() {
            if (sc.filteredRequests.isEmpty) {
              return const Center(child: Text('No requests found', style: TextStyle(color: AppTheme.textMuted)));
            }
            return ListView.builder(
              itemCount: sc.filteredRequests.length,
              itemBuilder: (context, index) {
                final req = sc.filteredRequests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.solidCardDecoration(),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(
                          color: req.status == 'completed' ? AppTheme.accentGreen : (req.status == 'pending' ? AppTheme.accentYellow : AppTheme.accentBlue),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req.propertyName, style: AppTheme.heading3),
                            const SizedBox(height: 4),
                            Text(req.description, style: AppTheme.bodyText),
                            const SizedBox(height: 4),
                            Text('Requested by ${req.tenantName}', style: AppTheme.caption),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge(
                            label: req.status.replaceAll('_', ' ').capitalizeFirst ?? req.status,
                            color: req.status == 'completed' ? AppTheme.accentGreen : (req.status == 'pending' ? AppTheme.accentYellow : AppTheme.accentBlue),
                          ),
                          const SizedBox(height: 6),
                          StatusBadge(label: req.priority, color: req.priority == 'high' ? AppTheme.accentRed : (req.priority == 'medium' ? AppTheme.accentOrange : AppTheme.textMuted)),
                          const SizedBox(height: 6),
                          Text('${req.requestDate.day}/${req.requestDate.month}/${req.requestDate.year}', style: AppTheme.caption),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: AppTheme.textMuted))),
        ],
      ),
    );
  }
}
