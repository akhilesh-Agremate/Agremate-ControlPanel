import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';

class ExpiredSubscriptionDetailView extends StatelessWidget {
  const ExpiredSubscriptionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final amountFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return ColoredBox(
      color: const Color(0xFFF8FAFD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                  onPressed: controller.closeExpiredSubscriptionDetails,
                ),
                const SizedBox(width: 8),
                Text('Expired Subscriptions', style: AppTheme.heading2),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isExpiredSubscriptionsLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGreen),
                );
              }

              if (controller.expiredSubscriptionsError.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.expiredSubscriptionsError.value,
                        style: AppTheme.bodyText,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchExpiredSubscriptions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final items = controller.expiredSubscriptions;
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No expired subscriptions found.',
                    style: AppTheme.bodyText,
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD6E8FA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.landlordName.isEmpty ? '—' : item.landlordName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Plan: ${item.planName.isEmpty ? '—' : item.planName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${item.status.isEmpty ? '—' : item.status}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Start: ${_formatDate(item.startDate)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'End: ${_formatDate(item.endDate)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                            Text(
                              amountFormat.format(item.amount),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE5484D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy').format(parsed);
  }
}
