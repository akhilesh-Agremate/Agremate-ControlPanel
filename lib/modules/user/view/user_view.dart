import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/property/model/landlord_model.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_model.dart';
import '../../../core/widgets/app_toast.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  final _landlordSearch = TextEditingController();
  final _tenantSearch = TextEditingController();

  @override
  void dispose() {
    _landlordSearch.dispose();
    _tenantSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<PropertyController>();

    return Obx(() {
      if (pc.isLoading.value) {
        return const ColoredBox(
          color: Color(0xFFF8FAFD),
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.accentCyan),
          ),
        );
      }

      final lq = _landlordSearch.text.trim().toLowerCase();
      final tq = _tenantSearch.text.trim().toLowerCase();
      final landlords = pc.landlords
          .where((l) => lq.isEmpty || l.name.toLowerCase().contains(lq))
          .toList();
      final tenants = pc.tenants
          .where((t) =>
      tq.isEmpty ||
          t.name.toLowerCase().contains(tq) ||
          (t.property?.name.toLowerCase().contains(tq) ?? false))
          .toList();

      return ColoredBox(
        color: const Color(0xFFF8FAFD),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FD),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.groups_rounded,
                        color: Color(0xFF2083D5), size: 26),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Management', style: AppTheme.heading1),
                      const SizedBox(height: 4),
                      Text(
                        'Landlords and tenants linked to properties in the dashboard.',
                        style: AppTheme.bodyText,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _UserListCard(
                      title: 'Landlords',
                      subtitle: 'Manage landlords and their properties',
                      total: pc.landlords.length,
                      icon: Icons.real_estate_agent_rounded,
                      fill: AppTheme.landlordFill,
                      searchHint: 'Search landlords...',
                      searchController: _landlordSearch,
                      onSearch: (_) => setState(() {}),
                      emptyText: 'No landlords to display.',
                      isEmpty: landlords.isEmpty,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: landlords.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final landlord = landlords[index];
                          return _UserTile(
                            name: landlord.name,
                            subtitle:
                            '${landlord.totalProperties} ${landlord.totalProperties == 1 ? 'property' : 'properties'}',
                            color: AppTheme.landlordFill,
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
                      subtitle: 'Manage tenants and their rented properties',
                      total: pc.tenants.length,
                      icon: Icons.groups_rounded,
                      fill: AppTheme.tenantFill,
                      searchHint: 'Search tenants...',
                      searchController: _tenantSearch,
                      onSearch: (_) => setState(() {}),
                      emptyText: 'No tenants to display.',
                      isEmpty: tenants.isEmpty,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tenants.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tenant = tenants[index];
                          return _UserTile(
                            name: tenant.name,
                            subtitle: tenant.property != null
                                ? tenant.property!.name
                                : 'No property',
                            color: AppTheme.tenantFill,
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
      AppToast.warning('Full property details not found');
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
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
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
    required this.subtitle,
    required this.total,
    required this.icon,
    required this.fill,
    required this.searchHint,
    required this.searchController,
    required this.onSearch,
    required this.emptyText,
    required this.isEmpty,
    required this.child,
  });

  final String title;
  final String subtitle;
  final int total;
  final IconData icon;
  final Color fill;
  final String searchHint;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final String emptyText;
  final bool isEmpty;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3ECF7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: fill.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: fill, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F2A5C),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.caption.copyWith(color: AppTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$total Total',
                  style: const TextStyle(
                    color: Color(0xFF2083D5),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 44,
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: searchHint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE3ECF7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2083D5)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isEmpty)
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
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE3ECF7)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color,
                child: Text(
                  name.isNotEmpty && !name.startsWith('+')
                      ? name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F2A5C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.home_outlined,
                            size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.caption.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }
}

