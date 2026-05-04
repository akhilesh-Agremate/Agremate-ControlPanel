import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';

import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';

class SubscriptionDetailPanel extends StatelessWidget {
  final Map<String, dynamic> item;

  const SubscriptionDetailPanel({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.brandPaleSky,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
                  onPressed: () => controller.selectedSubscription.value = null,
                ),
                const SizedBox(width: 8),
                Text('Subscription Details', style: AppTheme.heading2),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
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
                              const SizedBox(height: 12),
                              _buildUsageIndicator(item),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.border),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.contact_mail_outlined, size: 20, color: AppTheme.accentBlue),
                            const SizedBox(width: 12),
                            Text('Landlord Details', style: AppTheme.bodyText.copyWith(color: AppTheme.accentBlue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            item['landlordDetails'] ?? '',
                            style: AppTheme.bodyText.copyWith(
                              color: Colors.black,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Properties Overview', style: AppTheme.heading2),
                    const SizedBox(height: 16),
                    if (item['properties'] != null)
                      ...(item['properties'] as List).map((prop) {
                        final isBooked = prop['status'] == 'Booked';
                        return InkWell(
                          onTap: () {
                            final pc = Get.find<PropertyController>();
                            final nav = Get.find<NavigationController>();
                            
                            final details = (item['landlordDetails'] as String?)?.split('\n') ?? [];
                            final emailStr = details.isNotEmpty ? details[0].replaceAll('Email: ', '') : 'N/A';
                            final phoneStr = details.length > 1 ? details[1].replaceAll('Phone: ', '') : 'N/A';

                            pc.selectedProperty.value = PropertyModel(
                              id: prop['name'] ?? 'P1',
                              name: prop['name'] ?? '',
                              address: prop['location'] ?? '',
                              landlordId: 'L1',
                              landlordName: item['landlordName'] ?? '',
                              landlordEmail: emailStr,
                              landlordPhone: phoneStr,
                              status: prop['status'] == 'Booked' ? PropertyStatus.booked : PropertyStatus.available,
                              primaryTenantName: prop['tenantName'],
                              primaryTenantPhone: prop['tenantPhone'],
                              primaryTenantEmail: prop['tenantEmail'],
                              tenantJoinedDate: DateTime(2024, 1, 15),
                              rentAmount: 25000,
                              advanceAmount: 75000,
                              createdAt: DateTime.now(),
                            );
                            pc.returnTabIndex.value = 0;
                            nav.currentIndex.value = 1;
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: Property Name
                                Row(
                                  children: [
                                    const Icon(Icons.apartment_rounded, color: AppTheme.accentBlue, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        prop['name'] ?? '', 
                                        style: AppTheme.heading3.copyWith(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Row 2: Tenant | Status | Location
                                Row(
                                  children: [
                                    // Tenant
                                    Expanded(
                                      flex: 3,
                                      child: isBooked 
                                        ? Row(
                                            children: [
                                              const Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 14),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Tenant: ${prop['tenantName'] ?? ''}', 
                                                  style: AppTheme.bodyText.copyWith(
                                                    fontSize: 12, 
                                                    fontWeight: FontWeight.w600, 
                                                    color: AppTheme.textPrimary
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                    ),
                                    // Middle: Status Chip (Filled)
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isBooked ? Colors.red : AppTheme.accentBlue,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            prop['status'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Right: Location Icon + Name
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Icon(Icons.location_on_outlined, color: AppTheme.textMuted, size: 14),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              prop['location'] ?? '', 
                                              style: AppTheme.caption.copyWith(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    if (item['properties'] == null || (item['properties'] as List).isEmpty)
                      Text('No properties listed.', style: const TextStyle(color: AppTheme.textMuted)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.selectedSubscription.value = null,
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
          ),
        ],
      ),
    );
  }

  Widget _buildUsageIndicator(Map<String, dynamic> item) {
    final int count = item['propertyCount'] ?? 0;
    final int max = item['maxProperties'] ?? 0;
    final int remaining = max - count;

    if (max <= 10) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(max, (index) {
              final isUsed = index < count;
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: isUsed ? AppTheme.landlordFill : Colors.transparent,
                  border: Border.all(
                    color: isUsed ? AppTheme.landlordFill : AppTheme.textMuted.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '$count Slots filled · $remaining Free',
            style: AppTheme.caption.copyWith(fontSize: 10, color: AppTheme.textMuted),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.landlordFill.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.landlordFill.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 12, color: AppTheme.landlordFill),
            const SizedBox(width: 6),
            Text(
              '$count Used Properties',
              style: AppTheme.caption.copyWith(color: AppTheme.landlordFill, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }
}
