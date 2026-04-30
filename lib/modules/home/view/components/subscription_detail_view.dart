import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';

class SubscriptionDetailView extends StatelessWidget {
  final Map<String, dynamic> item;

  const SubscriptionDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('Subscription Details', style: TextStyle(color: AppTheme.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
            glowColor: AppTheme.accentPurple,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.star_rounded, color: AppTheme.accentPurple, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['landlordName'] ?? '', style: AppTheme.heading2),
                          const SizedBox(height: 4),
                          Text(item['subscriptionPlan'] ?? '', style: AppTheme.bodyText.copyWith(color: AppTheme.accentPurple)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.contact_mail_outlined, size: 20, color: AppTheme.textMuted),
                        const SizedBox(width: 12),
                        Text('Landlord Details', style: AppTheme.bodyText.copyWith(color: AppTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCardLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['landlordDetails'] ?? '',
                        style: AppTheme.bodyText.copyWith(height: 1.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Properties Overview', style: AppTheme.heading2),
                const SizedBox(height: 16),
                if (item['properties'] != null)
                  ...List<Widget>.from((item['properties'] as List).map((prop) {
                    final isBooked = prop['status'] == 'Booked';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.solidCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.apartment_rounded, color: AppTheme.accentPurple, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(prop['name'] ?? '', style: AppTheme.heading3)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isBooked ? AppTheme.accentRed.withValues(alpha: 0.1) : AppTheme.accentGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isBooked ? AppTheme.accentRed.withValues(alpha: 0.3) : AppTheme.accentGreen.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  prop['status'] ?? '',
                                  style: TextStyle(
                                    color: isBooked ? AppTheme.accentRed : AppTheme.accentGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: AppTheme.textMuted, size: 16),
                              const SizedBox(width: 6),
                              Text(prop['location'] ?? '', style: AppTheme.caption),
                            ],
                          ),
                          if (isBooked) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, color: AppTheme.accentCyan, size: 16),
                                const SizedBox(width: 6),
                                Text('Tenant: ${prop['tenantName']}', style: AppTheme.caption.copyWith(color: AppTheme.textPrimary)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  })),
                if (item['properties'] == null || (item['properties'] as List).isEmpty)
                  const Text('No properties listed.', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.bgCardLight,
                      foregroundColor: AppTheme.textPrimary,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

}
