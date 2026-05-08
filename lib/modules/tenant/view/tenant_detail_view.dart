import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_details_model.dart';

class TenantDetailView extends StatelessWidget {
  const TenantDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();
    final nav = Get.find<NavigationController>();
    final fmt = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return Obx(() {
      final details = pc.selectedTenantDetails.value;
      if (details == null) {
        return const Center(child: Text('No tenant selected', style: TextStyle(color: Colors.white)));
      }

      final user = details.userRole.users;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button & Header
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    pc.selectedTenantDetails.value = null;
                    nav.currentIndex.value = 6; // Back to User Management
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Text('Tenant Details', style: AppTheme.heading1),
                const Spacer(),
                if (details.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded, color: AppTheme.accentGreen, size: 16),
                        SizedBox(width: 6),
                        Text('Verified', style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Profile & Personal Info
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppTheme.tenantFill,
                              child: Text(
                                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'T',
                                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(user.fullName, style: AppTheme.heading2),
                            Text(user.agremateId, style: AppTheme.caption.copyWith(color: AppTheme.accentCyan)),
                            const SizedBox(height: 24),
                            const Divider(color: AppTheme.border),
                            const SizedBox(height: 24),
                            _buildInfoRow(Icons.email_outlined, 'Email', user.email),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.phone_outlined, 'Phone', user.phoneNumber),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.location_on_outlined, 'Address', user.fullAddress ?? 'N/A'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallStatCard('Properties', '${details.propertyCount}', AppTheme.accentCyan),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSmallStatCard('Family', '${user.familyMembers.length}', AppTheme.accentPurple),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSmallStatCard('Vehicles', '${user.vehicles.length}', AppTheme.accentGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Family Members
                      if (user.familyMembers.isNotEmpty)
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Family Members', style: AppTheme.heading3.copyWith(fontSize: 18)),
                              const SizedBox(height: 20),
                              ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: user.familyMembers.length,
                            separatorBuilder: (_, __) => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(color: AppTheme.border, height: 1),
                            ),
                            itemBuilder: (context, index) {
                              final member = user.familyMembers[index];
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
                                    child: const Icon(Icons.person_rounded, size: 16, color: AppTheme.accentPurple),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  Text('${member.age} years', style: AppTheme.caption),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                      const SizedBox(height: 24),
                      // Vehicles
                      if (user.vehicles.isNotEmpty)
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vehicles', style: AppTheme.heading3.copyWith(fontSize: 18)),
                              const SizedBox(height: 20),
                              ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: user.vehicles.length,
                            separatorBuilder: (_, __) => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(color: AppTheme.border, height: 1),
                            ),
                            itemBuilder: (context, index) {
                              final vehicle = user.vehicles[index];
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.2),
                                    child: Icon(
                                      vehicle.type.toLowerCase().contains('car') ? Icons.directions_car_rounded : Icons.moped_rounded,
                                      size: 16,
                                      color: AppTheme.accentGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${vehicle.model} (${vehicle.type})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      Text(vehicle.number, style: AppTheme.caption),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column: Properties
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assigned Properties', style: AppTheme.heading2),
                      const SizedBox(height: 16),
                      if (details.socialProperties.isEmpty)
                        GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.apartment_rounded, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                                const SizedBox(height: 16),
                                Text('No properties assigned', style: AppTheme.caption),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: details.socialProperties.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final prop = details.socialProperties[index];
                            return GlassCard(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (prop.documents.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            prop.documents.first.thumbnailUrl,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                          ),
                                        )
                                      else
                                        _buildPlaceholder(),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(prop.name, style: AppTheme.heading3),
                                                _buildStatusBadge(prop.status),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(prop.address, style: AppTheme.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                _buildPropertyFeature(Icons.bed_rounded, '${prop.bedrooms} Bed'),
                                                const SizedBox(width: 16),
                                                _buildPropertyFeature(Icons.bathroom_rounded, '${prop.bathrooms} Bath'),
                                                const SizedBox(width: 16),
                                                _buildPropertyFeature(Icons.kitchen_rounded, '${prop.kitchen} Kitchen'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Divider(color: AppTheme.border),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('MONTHLY RENT', style: AppTheme.caption.copyWith(fontSize: 10, letterSpacing: 1.1)),
                                          Text(fmt.format(prop.rent), style: const TextStyle(color: AppTheme.accentGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('ADVANCE PAYMENT', style: AppTheme.caption.copyWith(fontSize: 10, letterSpacing: 1.1)),
                                          Text(fmt.format(prop.advance), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Text('Description', style: AppTheme.caption.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(prop.description, style: AppTheme.bodyText.copyWith(fontSize: 13, height: 1.5)),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_not_supported_rounded, color: AppTheme.textMuted, size: 32),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.caption.copyWith(fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPropertyFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentCyan, size: 16),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.caption.copyWith(color: Colors.white)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppTheme.accentCyan;
    if (status.toLowerCase() == 'requested') color = AppTheme.statusRequestedText;
    if (status.toLowerCase() == 'available') color = AppTheme.statusAvailableText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
