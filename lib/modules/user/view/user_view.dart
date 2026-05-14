import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();
    final nav = Get.find<NavigationController>();

    return Obx(() {
      if (pc.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Management', style: AppTheme.heading1),
            const SizedBox(height: 8),
            Text('Manage landlords and tenants across your properties.', style: AppTheme.bodyText),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Landlord Card
                Expanded(
                  child: GlassCard(
                    color: Colors.white,
                    borderColor: AppTheme.landlordBorder,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.landlordFill,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.real_estate_agent_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Landlords',
                              style: TextStyle(
                                color: AppTheme.landlordText,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.landlordFill,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${pc.landlords.length}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pc.landlords.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final landlord = pc.landlords[index];
                            final landlordProps = pc.properties.where((p) => p.landlordId == landlord.id).toList();
                            final propNames = landlordProps.map((p) => p.name).join(', ');

                            return GlassCard(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              onTap: () {
                                if (landlordProps.isNotEmpty) {
                                  pc.selectedProperty.value = landlordProps.first;
                                  nav.currentIndex.value = 1; // Nav to Property tab
                                } else {
                                  Get.snackbar('Info', 'No properties currently assigned to this landlord');
                                }
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme.landlordFill,
                                    child: Text(
                                      landlord.name.isNotEmpty ? landlord.name[0].toUpperCase() : 'L',
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          landlord.name,
                                          style: AppTheme.heading3.copyWith(color: AppTheme.landlordText),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          landlordProps.isNotEmpty 
                                            ? '${landlordProps.length} Properties: $propNames'
                                            : 'Phone: ${landlord.phone}',
                                          style: AppTheme.caption.copyWith(color: AppTheme.landlordText.withValues(alpha: 0.7)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Tenant Card
                Expanded(
                  child: GlassCard(
                    color: Colors.white,
                    borderColor: AppTheme.tenantBorder,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.tenantFill,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Tenants',
                              style: TextStyle(
                                color: AppTheme.tenantText,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.tenantFill,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${pc.tenants.length}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pc.tenants.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final tenant = pc.tenants[index];
                            final prop = pc.properties.firstWhereOrNull(
                              (p) => p.id == tenant.propertyId || p.primaryTenantName == tenant.name,
                            );

                            return GlassCard(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              onTap: () {
                                pc.viewTenantDetails(tenant.id);
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme.tenantFill,
                                    child: Text(
                                      tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : 'T',
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tenant.name,
                                          style: AppTheme.heading3.copyWith(color: AppTheme.tenantText),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          prop != null ? 'Property: ${prop.name}' : 'Phone: ${tenant.phone}',
                                          style: AppTheme.caption.copyWith(color: AppTheme.tenantText.withValues(alpha: 0.7)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showLandlordDetailDialog(BuildContext context, dynamic landlord, List<dynamic> properties) {
    final String formattedRevenue = '₹${(landlord.totalRevenue / 100000).toStringAsFixed(2)}L';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(landlord.name, style: AppTheme.heading2.copyWith(color: Colors.black)),
                      const SizedBox(height: 4),
                      Text('Landlord Profile', style: AppTheme.caption.copyWith(color: AppTheme.textMuted)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  _buildStatItem('REVENUE', formattedRevenue, AppTheme.accentGreen),
                  const SizedBox(width: 48),
                  _buildStatItem('PROPERTIES', '${properties.length}', AppTheme.accentCyan),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'PROPERTY PORTFOLIO',
                style: AppTheme.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: properties.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final prop = properties[index];
                    return Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: prop.imageUrl != null
                                ? Image.network(
                                    prop.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (c, e, s) => Container(
                                      color: AppTheme.bgCardLight,
                                      child: const Icon(
                                        Icons.image_not_supported_rounded,
                                        color: AppTheme.textMuted,
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: AppTheme.bgCardLight,
                                    child: const Icon(
                                      Icons.image_not_supported_rounded,
                                      color: AppTheme.textMuted,
                                      size: 24,
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              prop.name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final pc = Get.find<PropertyController>();
                    final nav = Get.find<NavigationController>();
                    pc.returnTabIndex.value = 6; // User Tab
                    pc.selectedProperty.value = properties.first;
                    nav.currentIndex.value = 1;
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('View Full Management Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.caption.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
