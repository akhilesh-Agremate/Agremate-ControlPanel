import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'components/rent_collection_detail_view.dart';
import 'components/subscription_detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    final metricCards = [
      {'label': 'Total Rent Collections', 'color': AppTheme.accentGreen},
      {'label': 'Pending Payments', 'color': AppTheme.accentOrange},
      {'label': 'Total Subscriptions', 'color': AppTheme.accentPurple},
      {'label': 'Subscription Expired', 'color': AppTheme.accentRed},
    ];

    final listData = [
      {'title': 'Recent Rent Collections', 'data': controller.recentRent, 'color': AppTheme.accentGreen},
      {'title': 'Recent Subscriptions', 'data': controller.recentSubs, 'color': AppTheme.accentPurple},
      {'title': 'Recent Service Requests', 'data': controller.recentServices, 'color': AppTheme.accentCyan},
      {'title': 'Property', 'data': controller.propertyList, 'color': AppTheme.accentOrange},
      {'title': 'Document', 'data': controller.documentList, 'color': AppTheme.accentBlue},
      {'title': 'Support', 'data': controller.supportList, 'color': AppTheme.accentPink},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Overview', style: AppTheme.heading1),
          const SizedBox(height: 8),
          Text('Real-time analytics and performance metrics.', style: AppTheme.bodyText),
          const SizedBox(height: 32),
          // Use a Row for four cards in one row
          Row(
            children: metricCards.map((c) {
              final label = c['label'] as String;
              final color = c['color'] as Color;
              final periodVar = controller.getPeriodVar(label);
              final isLast = metricCards.indexOf(c) == metricCards.length - 1;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 20),
                  child: SizedBox(
                    height: 220,
                    child: GlassCard(
                      glowColor: color,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() => Text(
                                controller.getAmount(label, periodVar.value),
                                style: AppTheme.kpiValue.copyWith(fontSize: 32, color: Colors.black),
                              )),
                          const SizedBox(height: 24),
                          _buildThisSelector(context, controller, label, periodVar),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          Text('Recent Activity', style: AppTheme.heading2),
          const SizedBox(height: 20),
          ...listData.map((list) => _ActivityListCard(
            title: list['title'] as String,
            data: list['data'] as List<Map<String, dynamic>>,
            color: list['color'] as Color,
            controller: controller,
          )),
        ],
      ),
    );
  }

  Widget _buildThisSelector(BuildContext context, HomeController controller, String label, RxString periodVar) {
    // ... rest of the code remains the same ...
    return InkWell(
      onTap: () {},
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
              final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(
                  button.localToGlobal(Offset.zero, ancestor: overlay),
                  button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                ),
                Offset.zero & overlay.size,
              );

              showMenu<String>(
                context: context,
                position: position,
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                items: controller.periods.map((String period) {
                  return PopupMenuItem<String>(
                    value: period,
                    child: Text(period, style: AppTheme.bodyText),
                  );
                }).toList(),
              ).then((String? newValue) {
                if (newValue != null) {
                  controller.updatePeriod(label, newValue);
                }
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This', 
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.accentBlue, 
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.accentBlue),
              ],
            ),
          );
        }
      ),
    );
  }
}

class _ActivityListCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final Color color;
  final HomeController controller;

  const _ActivityListCard({
    required this.title,
    required this.data,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.expandedLists[title] ?? false;
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          glowColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              InkWell(
                onTap: () => controller.toggleList(title),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(title, style: AppTheme.heading3.copyWith(color: Colors.black)),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_right_rounded,
                      color: AppTheme.textMuted,
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                ...data.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: title == 'Recent Subscriptions' 
                        ? () => Get.to(() => SubscriptionDetailView(item: item))
                        : (title == 'Recent Rent Collections'
                            ? () => Get.to(() => RentCollectionDetailView(item: item))
                            : null),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: CircleAvatar(
                              radius: 4,
                              backgroundColor: color.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']!, 
                                  style: AppTheme.bodyText.copyWith(
                                    color: Colors.black, 
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['detail']!, 
                                  style: AppTheme.caption.copyWith(
                                    color: AppTheme.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).take(10),
              ],
            ],
          ),
        ),
      );
    });
  }

}
