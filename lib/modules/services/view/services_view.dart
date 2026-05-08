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
                    color: Colors.white,
                    glowColor: isSelected ? color : color.withValues(alpha: 0.5),
                    onTap: () => sc.selectServiceType(type),
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
                        Text(type, style: AppTheme.heading3.copyWith(color: AppTheme.textPrimary)),
                        const SizedBox(height: 6),
                        Text('$count requests', style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondary)),
                        if (pending > 0) ...[
                          const SizedBox(height: 4),
                          Text('$pending pending', style: TextStyle(color: AppTheme.accentYellow, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Inline request list
            if (sc.selectedServiceType.value.isNotEmpty) ...[
              Row(
                children: [
                  Text('${sc.selectedServiceType.value} Requests', style: AppTheme.heading2),
                  const Spacer(),
                  StatusBadge(
                    label: '${sc.filteredRequests.length} total',
                    color: AppConstants.serviceColors[sc.selectedServiceType.value] ?? AppTheme.accentCyan,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (sc.filteredRequests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No requests found', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sc.filteredRequests.length,
                  itemBuilder: (context, index) {
                    final req = sc.filteredRequests[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 5,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2083D5), // Uniform Agremate Blue
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(req.propertyName, style: AppTheme.heading3),
                                const SizedBox(height: 6),
                                Text(req.description, style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondary)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textMuted),
                                    const SizedBox(width: 4),
                                    Text('By ${req.tenantName}', style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatusBadge(
                                label: req.status.replaceAll('_', ' ').toUpperCase(),
                                color: req.status == 'completed' ? AppTheme.accentGreen : (req.status == 'pending' ? AppTheme.accentYellow : AppTheme.accentBlue),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Requested on ${req.requestDate.day}/${req.requestDate.month}/${req.requestDate.year}',
                                style: AppTheme.caption.copyWith(fontSize: 11),
                              ),
                              if (req.status == 'completed') ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Completed on ${req.requestDate.add(const Duration(days: 2)).day}/${req.requestDate.add(const Duration(days: 2)).month}/${req.requestDate.year}', // Simulated completion date
                                  style: AppTheme.caption.copyWith(fontSize: 11, color: AppTheme.accentGreen, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(Icons.touch_app_rounded, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text('Select a category to view requests', style: AppTheme.bodyText.copyWith(color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
