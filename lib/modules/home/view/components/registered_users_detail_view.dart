import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/app_colors.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';
import 'package:agremate_admin/modules/home/model/registered_user_models.dart';

class RegisteredUsersDetailView extends StatelessWidget {
  const RegisteredUsersDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return ColoredBox(
      color: AppColors.scaffoldLight,
      child: Obx(() {
        if (controller.isRegisteredUsersLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentGreen),
          );
        }
        if (controller.registeredUsersError.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.registeredUsersError.value,
                  style: AppTheme.bodyText,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchRegisteredUsers,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(controller),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final pad = w < 600 ? 14.0 : 28.0;

                  return Obx(() {
                    final tab = controller.registeredUsersTab.value;
                    final switching = controller.isTabSwitching.value;
                    final moreLoading = tab == 1
                        ? controller.isLoadingMoreLandlords.value
                        : controller.isLoadingMoreTenants.value;

                    final landlords = controller.registeredLandlords;
                    final tenants = controller.registeredTenants;
                    final count =
                    tab == 1 ? landlords.length : tab == 2 ? tenants.length : 0;
                    final columns = _columnsFor(w, maxColumns: tab == 1 ? 5 : 2);
                    final rowCount = (count / columns).ceil();

                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(pad, 0, pad, 16),
                          sliver: SliverToBoxAdapter(
                            child: _countCards(controller, w),
                          ),
                        ),
                        if (switching)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.accentGreen,
                                ),
                              ),
                            ),
                          )
                        else if (tab != 0 && count == 0)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: moreLoading
                                    ? const CircularProgressIndicator(
                                  color: AppTheme.accentGreen,
                                )
                                    : Text(
                                  tab == 1
                                      ? 'No landlords found.'
                                      : 'No tenants found.',
                                  style: AppTheme.bodyText,
                                ),
                              ),
                            ),
                          )
                        else if (tab != 0)
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: pad),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                      (context, r) {
                                    final start = r * columns;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          for (var c = 0; c < columns; c++) ...[
                                            if (c > 0) const SizedBox(width: 12),
                                            Expanded(
                                              child: start + c < count
                                                  ? (tab == 1
                                                  ? _landlordCard(
                                                  landlords[start + c])
                                                  : _tenantCard(
                                                  tenants[start + c]))
                                                  : const SizedBox.shrink(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                  childCount: rowCount,
                                ),
                              ),
                            ),
                        if (!switching && tab != 0 && moreLoading && count > 0)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppTheme.accentGreen,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 28)),
                      ],
                    );
                  });
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  int _columnsFor(double width, {int maxColumns = 2}) {
    if (width < 600) return 1;
    if (width < 800) return maxColumns >= 2 ? 2 : maxColumns;
    if (width < 1100) return maxColumns >= 3 ? 3 : maxColumns;
    return maxColumns;
  }

  Widget _header(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            onPressed: controller.closeRegisteredUsersDetails,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registered Users', style: AppTheme.heading2),
                Text(
                  'Overview of registered users on the platform',
                  style: AppTheme.bodyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countCards(HomeController controller, double width) {
    final landlords = controller.registeredLandlordCount;
    final tenants = controller.registeredTenantCount;
    final total = controller.registeredUsersTotalCount;
    final tab = controller.registeredUsersTab.value;
    final cards = [
      _countCard(
        title: 'Landlords',
        value: landlords,
        icon: Icons.groups_outlined,
        selected: tab == 1,
        onTap: () => controller.switchRegisteredUsersTab(1),
      ),
      _countCard(
        title: 'Tenants',
        value: tenants,
        icon: Icons.person_outline,
        selected: tab == 2,
        onTap: () => controller.switchRegisteredUsersTab(2),
      ),
      _countCard(
        title: 'Total Registered Users',
        value: total,
        icon: Icons.pie_chart_outline,
        selected: tab == 0,
        onTap: () => controller.switchRegisteredUsersTab(0),
      ),
    ];
    if (width < 800) {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 12),
          cards[1],
          const SizedBox(height: 12),
          cards[2],
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 16),
        Expanded(child: cards[1]),
        const SizedBox(width: 16),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _countCard({
    required String title,
    required int value,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: selected ? AppTheme.landlordBg : AppTheme.brandWhite,
      borderColor: selected ? AppTheme.brandSteelBlue : AppTheme.border,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.brandPaleSky,
            child: Icon(icon, color: AppTheme.brandSteelBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyText),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.decimalPattern('en_IN').format(value),
                  style: AppTheme.kpiValue.copyWith(
                    fontSize: 28,
                    color: AppTheme.landlordText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _landlordCard(RegisteredLandlordItem item) {
    return GlassCard(
      color: AppTheme.brandWhite,
      borderColor: AppTheme.border,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.brandPaleSky,
                child: Text(
                  _initials(item.name),
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.brandSteelBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTheme.heading3.copyWith(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.phone.isNotEmpty)
                      Text(
                        item.phone,
                        style: AppTheme.caption.copyWith(fontSize: 10.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.home_work_outlined,
                  size: 13, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Properties',
                  style: AppTheme.caption.copyWith(fontSize: 11),
                ),
              ),
              Text(
                '${item.propertyCount}',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts[0];
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _tenantCard(RegisteredTenantItem item) {
    final start = item.startDate == null
        ? ''
        : DateFormat('MMM d, yyyy').format(item.startDate!.toLocal());
    final location = item.propertyAddress.split(',').first.trim();
    return GlassCard(
      color: AppTheme.brandWhite,
      borderColor: AppTheme.border,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(item.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTheme.heading3),
                    if (item.phone.isNotEmpty)
                      Text(item.phone, style: AppTheme.caption),
                  ],
                ),
              ),
              _statusChip(item.isActive),
            ],
          ),
            if (item.email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.email, style: AppTheme.caption),
            ],
            if (item.propertyName.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location.isEmpty
                          ? item.propertyName
                          : '${item.propertyName} · $location',
                      style: AppTheme.bodyText,
                    ),
                  ),
                ],
              ),
            ],
            if (start.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text('Tenancy since $start', style: AppTheme.bodyText),
                ],
              ),
            ],
            if (item.userId.isEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.person_off_outlined,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'No app account shows for users without a userId',
                      style: AppTheme.caption,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
  }

  Widget _avatar(String name) {
    final trimmed = name.trim();
    String text = '?';
    if (trimmed.isNotEmpty) {
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length == 1) {
        text = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      } else {
        text = (parts[0][0] + parts[1][0]).toUpperCase();
      }
    }
    return CircleAvatar(
      backgroundColor: AppTheme.brandPaleSky,
      child: Text(
        text,
        style: AppTheme.heading3.copyWith(color: AppTheme.brandSteelBlue),
      ),
    );
  }

  Widget _statusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.statusActiveBg : AppTheme.brandRedLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: AppTheme.caption.copyWith(
          color: isActive ? AppTheme.statusActiveText : AppTheme.brandRed,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
