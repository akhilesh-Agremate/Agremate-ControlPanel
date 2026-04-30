import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';

class RentCollectionDetailView extends StatelessWidget {
  final Map<String, dynamic> item;

  const RentCollectionDetailView({super.key, required this.item});

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
        title: const Text('Rent Collection Details', style: TextStyle(color: AppTheme.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: GlassCard(
            glowColor: AppTheme.accentGreen,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item['propertyImage'] != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['propertyImage']!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 200,
                        width: double.infinity,
                        color: AppTheme.bgCardLight,
                        child: const Icon(Icons.image_not_supported_rounded, color: AppTheme.textMuted, size: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.monetization_on_rounded, color: AppTheme.accentGreen, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['propertyName'] ?? '', style: AppTheme.heading2),
                          const SizedBox(height: 4),
                          Text(item['location'] ?? '', style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: AppTheme.textMuted),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: Text('Status', style: AppTheme.bodyText.copyWith(color: AppTheme.textMuted)),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: StatusBadge(
                          label: item['propertyStatus'] ?? 'Unknown',
                          color: item['propertyStatus'] == 'Available' ? AppTheme.accentGreen : AppTheme.accentPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Tenant Name', item['tenantName'] ?? '', Icons.person_outline),
                const SizedBox(height: 16),
                _buildDetailRow('Landlord Name', item['landlordName'] ?? '', Icons.person),
                const SizedBox(height: 16),
                _buildDetailRow('Rent Amount', item['rentAmount'] ?? '', Icons.payments_outlined, color: AppTheme.accentGreen),
                const SizedBox(height: 16),
                _buildDetailRow('Advance Amount', item['advanceAmount'] ?? '', Icons.account_balance_wallet_outlined, color: AppTheme.accentBlue),
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

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppTheme.textMuted),
        const SizedBox(width: 12),
        SizedBox(
          width: 140,
          child: Text(label, style: AppTheme.bodyText.copyWith(color: AppTheme.textMuted)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.heading3.copyWith(color: color ?? AppTheme.textPrimary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
