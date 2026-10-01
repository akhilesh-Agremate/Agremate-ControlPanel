import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/property/model/landlord_model.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_model.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();

    return Obx(() {
      if (pc.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentCyan),
        );
      }

      return ColoredBox(
        color: const Color(0xFFF8FAFD),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Management', style: AppTheme.heading1),
              const SizedBox(height: 8),
              Text(
                'Landlords and tenants linked to properties in the dashboard.',
                style: AppTheme.bodyText,
              ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _UserListCard(
                      title: 'Landlords',
                      count: pc.landlords.length,
                      icon: Icons.real_estate_agent_rounded,
                      fill: AppTheme.landlordFill,
                      textColor: AppTheme.landlordText,
                      borderColor: AppTheme.landlordBorder,
                      emptyText: 'No landlords to display.',
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pc.landlords.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final landlord = pc.landlords[index];
                          return _UserTile(
                            name: landlord.name,
                            subtitle:
                                '${landlord.totalProperties} ${landlord.totalProperties == 1 ? 'property' : 'properties'}',
                            color: AppTheme.landlordFill,
                            textColor: AppTheme.landlordText,
                            onTap: () =>
                                _showLandlordDetailDialog(context, landlord),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _UserListCard(
                      title: 'Tenants',
                      count: pc.tenants.length,
                      icon: Icons.groups_rounded,
                      fill: AppTheme.tenantFill,
                      textColor: AppTheme.tenantText,
                      borderColor: AppTheme.tenantBorder,
                      emptyText: 'No tenants to display.',
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pc.tenants.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tenant = pc.tenants[index];
                          return _UserTile(
                            name: tenant.name,
                            subtitle: tenant.property != null
                                ? tenant.property!.name
                                : 'No property',
                            color: AppTheme.tenantFill,
                            textColor: AppTheme.tenantText,
                            onTap: () =>
                                _showTenantDetailDialog(context, tenant),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _openLinkedProperty(BuildContext ctx, String? propertyId, String? propertyName) {
    final pc = Get.find<PropertyController>();
    final nav = Get.find<NavigationController>();
    final fullProperty = pc.properties.firstWhereOrNull(
      (p) =>
          (propertyId != null && propertyId.isNotEmpty && p.id == propertyId) ||
          (propertyName != null &&
              propertyName.isNotEmpty &&
              p.name.toLowerCase() == propertyName.toLowerCase()),
    );
    if (fullProperty != null) {
      pc.returnTabIndex.value = 6;
      pc.selectedProperty.value = fullProperty;
      nav.currentIndex.value = 1;
      Navigator.pop(ctx);
    } else {
      Get.snackbar('Info', 'Full property details not found');
    }
  }

  void _showLandlordDetailDialog(BuildContext context, LandlordModel landlord) {
    final pc = Get.find<PropertyController>();
    final linked = pc.properties
        .where(
          (p) =>
              (landlord.id.isNotEmpty && p.landlordId == landlord.id) ||
              p.landlordName.toLowerCase() == landlord.name.toLowerCase(),
        )
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.landlordFill,
                      child: Text(
                        landlord.name.isNotEmpty
                            ? landlord.name[0].toUpperCase()
                            : 'L',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(landlord.name, style: AppTheme.heading2),
                          Text(
                            'Landlord',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _infoCard(
                  children: [
                    _iconInfoRow(
                      Icons.phone_rounded,
                      landlord.phone.isNotEmpty ? landlord.phone : 'N/A',
                    ),
                    const SizedBox(height: 10),
                    _iconInfoRow(
                      Icons.mail_outline_rounded,
                      landlord.email.isNotEmpty ? landlord.email : 'N/A',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _countChip(
                        '${landlord.totalProperties}',
                        landlord.totalProperties == 1
                            ? 'Property'
                            : 'Properties',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _countChip(
                        '${landlord.occupiedCount}',
                        'Active',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionLabel('Linked properties'),
                const SizedBox(height: 10),
                if (linked.isEmpty)
                  _infoCard(
                    children: const [
                      Text(
                        'No linked properties found.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ],
                  )
                else
                  ...linked.map((prop) {
                    final tenantName = (prop.primaryTenantName ?? '').trim();
                    final hasTenant = tenantName.isNotEmpty;
                    final matchingTenant = pc.tenants.firstWhereOrNull(
                      (t) =>
                          t.name.toLowerCase() == tenantName.toLowerCase() ||
                          (t.property?.name.toLowerCase() ==
                              prop.name.toLowerCase()),
                    );
                    final tenantPhone =
                        (prop.primaryTenantPhone ?? matchingTenant?.phone ?? '')
                            .trim();
                    final startDate =
                        prop.tenancyStartDate ??
                        DateTime.tryParse(
                          matchingTenant?.tenancyStartDate ?? '',
                        );
                    final startLabel = startDate != null
                        ? DateFormat('dd MMM yyyy').format(startDate)
                        : '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              _openLinkedProperty(ctx, prop.id, prop.name),
                          child: _infoCard(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.home_rounded,
                                    size: 18,
                                    color: AppTheme.landlordFill,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      prop.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (hasTenant) ...[
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _inlineInfo(Icons.person_rounded, tenantName),
                                    ),
                                    if (tenantPhone.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 5,
                                        child: _inlineInfo(Icons.phone_rounded, tenantPhone),
                                      ),
                                    ],
                                    if (startLabel.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 5,
                                        child: _inlineInfo(Icons.event_rounded, startLabel),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTenantDetailDialog(BuildContext context, TenantModel tenant) {
    final pc = Get.find<PropertyController>();
    final startDate = DateTime.tryParse(tenant.tenancyStartDate);
    final startLabel = startDate != null
        ? DateFormat('dd MMM yyyy').format(startDate)
        : (tenant.tenancyStartDate.isNotEmpty ? tenant.tenancyStartDate : '');
    final linkedProp = pc.properties.firstWhereOrNull(
      (p) =>
          (tenant.propertyId.isNotEmpty && p.id == tenant.propertyId) ||
          (tenant.property != null &&
              tenant.property!.name.isNotEmpty &&
              p.name.toLowerCase() == tenant.property!.name.toLowerCase()),
    );
    final landlordName = (linkedProp?.landlordName ?? '').trim();
    final matchingLandlord = pc.landlords.firstWhereOrNull(
      (l) =>
          landlordName.isNotEmpty &&
          l.name.toLowerCase() == landlordName.toLowerCase(),
    );
    final landlordPhone =
        (linkedProp?.landlordPhone ?? matchingLandlord?.phone ?? '').trim();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.tenantFill,
                      child: Text(
                        tenant.name.isNotEmpty
                            ? tenant.name[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tenant.name, style: AppTheme.heading2),
                          Text(
                            'Tenant',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _infoCard(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _inlineInfo(
                            Icons.phone_rounded,
                            tenant.phone.isNotEmpty ? tenant.phone : 'N/A',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: _inlineInfo(
                            Icons.mail_outline_rounded,
                            tenant.email.isNotEmpty ? tenant.email : 'N/A',
                          ),
                        ),
                      ],
                    ),
                    if (startLabel.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _iconInfoRow(Icons.event_rounded, startLabel),
                    ],
                  ],
                ),
                if (landlordName.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _sectionLabel('Landlord'),
                  const SizedBox(height: 10),
                  _infoCard(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _inlineInfo(Icons.person_rounded, landlordName),
                          ),
                          if (landlordPhone.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: _inlineInfo(Icons.phone_rounded, landlordPhone),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                _sectionLabel('Rented property'),
                const SizedBox(height: 10),
                tenant.property == null
                    ? _infoCard(
                        children: const [
                          Text(
                            'No property registered for this tenant.',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        ],
                      )
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _openLinkedProperty(
                            ctx,
                            tenant.property!.id,
                            tenant.property!.name,
                          ),
                          child: _infoCard(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.home_rounded,
                                    size: 18,
                                    color: AppTheme.tenantFill,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tenant.property!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTheme.caption.copyWith(
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _iconInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.brandSteelBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _inlineInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.brandSteelBlue),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _countChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.landlordText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.caption.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _UserListCard extends StatelessWidget {
  const _UserListCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.fill,
    required this.textColor,
    required this.borderColor,
    required this.emptyText,
    required this.child,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color fill;
  final Color textColor;
  final Color borderColor;
  final String emptyText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: Colors.white,
      borderColor: borderColor,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),
          if (count == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                emptyText,
                style: AppTheme.caption.copyWith(color: AppTheme.textMuted),
              ),
            )
          else
            child,
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.name,
    required this.subtitle,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Text(
              name.isNotEmpty && !name.startsWith('+')
                  ? name[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.heading3.copyWith(color: textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.caption.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
        ],
      ),
    );
  }
}
