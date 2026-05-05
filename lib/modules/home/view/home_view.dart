import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'components/rent_collection_detail_view.dart';
import 'components/subscription_detail_panel.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    final metricCards = [
      {
        'label': 'Total Rent Collections',
        'topColor': AppTheme.kpiRentBorder,
        'numberColor': AppTheme.kpiRentNumber,
      },
      {
        'label': 'Pending Payments',
        'topColor': AppTheme.kpiPendingBorder,
        'numberColor': AppTheme.kpiPendingNumber,
      },
      {
        'label': 'Total Subscriptions',
        'topColor': AppTheme.kpiSubsBorder,
        'numberColor': AppTheme.kpiSubsNumber,
      },
      {
        'label': 'Subscription Expired',
        'topColor': AppTheme.kpiExpiredBorder,
        'numberColor': AppTheme.kpiExpiredNumber,
      },
    ];

    final listData = [
      {
        'title': 'Recent Rent Collections',
        'data': controller.recentRent,
        'color': AppTheme.accentGreen,
      },
      {
        'title': 'Recent Subscriptions',
        'data': controller.recentSubs,
        'color': AppTheme.accentPurple,
      },
      {
        'title': 'Recent Service Requests',
        'data': controller.recentServices,
        'color': AppTheme.accentCyan,
      },
      {
        'title': 'Property',
        'data': controller.propertyList,
        'color': AppTheme.accentOrange,
      },
      {
        'title': 'Document',
        'data': controller.documentList,
        'color': AppTheme.accentBlue,
      },
      {
        'title': 'Support',
        'data': controller.supportList,
        'color': AppTheme.accentPink,
      },
    ];

    return Obx(() {
      final selectedSub = controller.selectedSubscription.value;

      return Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard Overview', style: AppTheme.heading1),
                        const SizedBox(height: 8),
                        Text(
                          'Real-time analytics and performance metrics.',
                          style: AppTheme.bodyText,
                        ),
                      ],
                    ),
                    _buildGlobalSelector(context, controller),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...metricCards.map((c) {
                      final label = c['label'] as String;
                      final topColor = c['topColor'] as Color;
                      final numberColor = c['numberColor'] as Color;
                      final periodVar = controller.getPeriodVar(label);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SizedBox(
                            height: 150,
                            child: GlassCard(
                              topBarColor: null,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Obx(
                                    () => Text(
                                      controller.getAmount(
                                        label,
                                        periodVar.value,
                                      ),
                                      style: AppTheme.kpiValue.copyWith(
                                        fontSize: 32,
                                        color: numberColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 48),
                // Recent Activities
                Text('Recent Activity', style: AppTheme.heading2),
                const SizedBox(height: 24),
                ...listData.map((list) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _ActivityListCard(
                      title: list['title'] as String,
                      data: list['data'] as List<Map<String, dynamic>>,
                      color: list['color'] as Color,
                      controller: controller,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          if (selectedSub != null) ...[
            GestureDetector(
              onTap: () => controller.selectedSubscription.value = null,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 550,
              child: Container(
                child: SubscriptionDetailPanel(item: selectedSub),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildGlobalSelector(BuildContext context, HomeController controller) {
    return InkWell(
      onTap: () {},
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(
                  button.localToGlobal(
                    Offset(button.size.width - 120, button.size.height + 8),
                    ancestor: overlay,
                  ),
                  button.localToGlobal(
                    button.size.bottomRight(const Offset(0, 8)),
                    ancestor: overlay,
                  ),
                ),
                Offset.zero & overlay.size,
              );

              showMenu<String>(
                context: context,
                position: position,
                color: Colors.white,
                elevation: 8,
                constraints: const BoxConstraints(minWidth: 120, maxWidth: 140),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                items:
                    controller.periods.map((String period) {
                      return PopupMenuItem<String>(
                        value: period,
                        height: 38,
                        child: Text(
                          period,
                          style: AppTheme.bodyText.copyWith(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
              ).then((String? newValue) {
                if (newValue != null) {
                  controller.updateGlobalPeriod(newValue);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => Text(
                      controller.globalPeriod.value,
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppTheme.textPrimary,
                  ),
                ],
              ),
            ),
          );
        },
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
          borderRadius: 20,
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
                      child: Text(
                        title,
                        style: AppTheme.heading3.copyWith(color: Colors.black),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textMuted,
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                ...data
                    .map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (title == 'Recent Rent Collections' ||
                                title == 'Property') {
                              _navigateToProperty(item);
                            } else if (title == 'Recent Subscriptions') {
                              controller.selectedSubscription.value = item;
                            } else if (title == 'Recent Service Requests') {
                              _showServiceDetailsDialog(context, item);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (title ==
                                          'Recent Rent Collections') ...[
                                        Text(
                                          item['title']!,
                                          style: AppTheme.bodyText.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Column 1: Names
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildLabelValue(
                                                    'Landlord',
                                                    item['landlordName'] ?? '',
                                                    Colors.black,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _buildLabelValue(
                                                    'Tenant',
                                                    item['tenantName'] ?? '',
                                                    Colors.black,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Column 2: Financial Chips (Middle)
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  _buildOutlinedChip(
                                                    'Advance: ${item['advanceAmount']}',
                                                    AppTheme.accentBlue,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _buildOutlinedChip(
                                                    'Rent: ${item['rentAmount']}',
                                                    AppTheme.accentBlue,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Column 3: Location & Date (Right Corner)
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        size: 14,
                                                        color:
                                                            AppTheme.textMuted,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        item['location'] ?? '',
                                                        style: AppTheme.caption
                                                            .copyWith(
                                                              fontSize: 11,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .calendar_today_outlined,
                                                        size: 14,
                                                        color:
                                                            AppTheme.textMuted,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Joined: ${item['joinedDate']}',
                                                        style: AppTheme.caption
                                                            .copyWith(
                                                              fontSize: 11,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (title ==
                                          'Recent Service Requests') ...[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Column 1: Entities
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['propertyName'] ?? '',
                                                    style: AppTheme.bodyText
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 14,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  _buildLabelValue(
                                                    'Landlord: ',
                                                    item['landlordName'] ?? '',
                                                    AppTheme.landlordFill,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  _buildLabelValue(
                                                    'Tenant: ',
                                                    item['tenantName'] ?? '',
                                                    AppTheme.tenantFill,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Column 2: Issue & Status
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                children: [
                                                  _buildFilledChip(
                                                    item['detail']!.replaceAll(
                                                      'Issue: ',
                                                      '',
                                                    ),
                                                    AppTheme.accentCyan,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _buildFilledChip(
                                                    item['status'] ?? 'Pending',
                                                    item['status'] == 'Solved'
                                                        ? AppTheme.accentBlue
                                                        : Colors.red,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Column 3: Location & Date
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        size: 14,
                                                        color:
                                                            AppTheme.textMuted,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        item['location'] ?? '',
                                                        style: AppTheme.caption
                                                            .copyWith(
                                                              fontSize: 11,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .calendar_today_outlined,
                                                        size: 14,
                                                        color:
                                                            AppTheme.textMuted,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Raised: ${item['raisedDate']}',
                                                        style: AppTheme.caption
                                                            .copyWith(
                                                              fontSize: 11,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (item['status'] ==
                                                          'Solved' &&
                                                      item['resolvedDate'] !=
                                                          null) ...[
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .check_circle_outline_rounded,
                                                          size: 14,
                                                          color:
                                                              AppTheme
                                                                  .accentBlue,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Solved: ${item['resolvedDate']}',
                                                          style: AppTheme
                                                              .caption
                                                              .copyWith(
                                                                fontSize: 11,
                                                                color:
                                                                    AppTheme
                                                                        .accentBlue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (title ==
                                          'Recent Subscriptions') ...[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Column 1: Identity
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['title']!,
                                                    style: AppTheme.bodyText
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 15,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    item['detail']!
                                                        .replaceAll(
                                                          'Subscription',
                                                          '',
                                                        )
                                                        .trim(),
                                                    style: AppTheme.bodyText
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Column 2: Status (Perfectly Centered)
                                            if (item['status'] != null)
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child:
                                                      item['status'] == 'Active'
                                                          ? StatusBadge.active()
                                                          : StatusBadge.expired(),
                                                ),
                                              ),
                                            // Column 3: Metadata & Usage
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .calendar_today_outlined,
                                                        size: 14,
                                                        color:
                                                            AppTheme.textMuted,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Joined: ${item['joinedDate'] ?? 'Jan 2024'}',
                                                        style: AppTheme.caption
                                                            .copyWith(
                                                              fontSize: 11,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildUsageIndicator(item),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (title == 'Property') ...[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Column 1: Identity
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['title']!,
                                                    style: AppTheme.bodyText
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 15,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  _buildLabelValue(
                                                    'Landlord',
                                                    item['landlordName'] ?? '',
                                                    AppTheme.landlordFill,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Column 2: Status
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: _buildFilledChip(
                                                  item['status'] ?? 'Available',
                                                  item['status'] == 'Available'
                                                      ? AppTheme.accentGreen
                                                      : AppTheme.accentOrange,
                                                ),
                                              ),
                                            ),
                                            // Column 3: Location
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 14,
                                                    color: AppTheme.textMuted,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    item['location'] ?? '',
                                                    style: AppTheme.caption
                                                        .copyWith(fontSize: 11),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (title == 'Support') ...[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Column 1: Ticket
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                item['title']!,
                                                style: AppTheme.bodyText
                                                    .copyWith(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 15,
                                                    ),
                                              ),
                                            ),
                                            // Column 2: Issue (Blue Chip)
                                            Expanded(
                                              flex: 4,
                                              child: Center(
                                                child: _buildFilledChip(
                                                  item['message'] ?? 'Support',
                                                  AppTheme.accentBlue,
                                                ),
                                              ),
                                            ),
                                            // Column 3: Status Chip (Small) & Date
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          item['status'] ==
                                                                  'Resolved'
                                                              ? AppTheme
                                                                  .accentBlue
                                                              : item['status'] ==
                                                                  'In Progress'
                                                              ? AppTheme
                                                                  .accentOrange
                                                              : Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item['status'] ??
                                                          'Pending',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item['date'] ?? '',
                                                    style: AppTheme.caption
                                                        .copyWith(
                                                          fontSize: 10,
                                                          color:
                                                              AppTheme
                                                                  .textMuted,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else ...[
                                        Text(
                                          item['detail']!,
                                          style: AppTheme.caption.copyWith(
                                            color: AppTheme.textSecondary,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .take(10),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLabelValue(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTheme.caption.copyWith(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilledChip(String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildOutlinedChip(String label, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildUsageIndicator(Map<String, dynamic> item) {
    final int count = item['propertyCount'] ?? 0;
    final int max = item['maxProperties'] ?? 0;
    final int remaining = max - count;

    if (max <= 10) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(max, (index) {
              final isUsed = index < count;
              return Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: isUsed ? AppTheme.landlordFill : Colors.transparent,
                  border: Border.all(
                    color:
                        isUsed ? AppTheme.landlordFill : Colors.grey.shade400,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(width: 12),
          Text(
            '$count Slots filled',
            style: AppTheme.caption.copyWith(
              fontSize: 10,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.landlordFill.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.landlordFill.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 12,
              color: AppTheme.landlordFill,
            ),
            const SizedBox(width: 6),
            Text(
              '$count Used Properties',
              style: AppTheme.caption.copyWith(
                color: AppTheme.landlordFill,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToProperty(Map<String, dynamic> item) {
    final pc = Get.find<PropertyController>();
    final nav = Get.find<NavigationController>();

    final propName =
        (item['propertyName'] as String? ?? item['title'] as String? ?? '')
            .toLowerCase()
            .trim();

    // Try exact match first
    var property = pc.properties.firstWhereOrNull(
      (p) => p.name.toLowerCase().trim() == propName,
    );

    // If no exact match, try matching the parts (e.g. "Green" and "Villa" and "1")
    if (property == null) {
      final parts = propName.split(' ');
      property = pc.properties.firstWhereOrNull((p) {
        final pName = p.name.toLowerCase();
        return parts.every((part) => pName.contains(part));
      });
    }

    // Fallback: If still not found, pick the first one just to demonstrate navigation
    property ??= pc.properties.firstOrNull;

    if (property != null) {
      final newCounts = Map<String, int>.from(property.serviceRequestCounts);
      final newMessages = Map<String, String>.from(
        property.serviceRequestMessages,
      );

      // If coming from Recent Service Requests, update the service issue count and message
      final detail = item['detail'] as String?;
      if (detail != null &&
          detail.startsWith('Issue: ') &&
          item['status'] == 'Pending') {
        final issueFull = detail.replaceFirst('Issue: ', '').trim();
        final issueType = issueFull.split(' ').first; // e.g., 'Plumbing'

        if (newCounts.containsKey(issueType)) {
          newCounts[issueType] = (newCounts[issueType] ?? 0) + 1;
          newMessages[issueType] =
              'Tenant reported: $issueFull. Request raised on ${item['raisedDate']}.';
        }
      }

      final matchedProperty = PropertyModel(
        id: property.id,
        name: property.name,
        address: item['location'] != null
            ? PropertyAddress(
                address: item['location'] as String,
                latitude: property.address.latitude,
                longitude: property.address.longitude,
              )
            : property.address,
        landlordId: property.landlordId,
        landlordName: item['landlordName'] ?? property.landlordName,
        landlordPhone: property.landlordPhone,
        landlordEmail: property.landlordEmail,
        tenantIds: property.tenantIds,
        rentAmount: property.rentAmount,
        advanceAmount: property.advanceAmount,
        propertyType: property.propertyType,
        status: property.status,
        primaryTenantName: item['tenantName'] ?? property.primaryTenantName,
        primaryTenantPhone: property.primaryTenantPhone,
        primaryTenantEmail: property.primaryTenantEmail,
        tenantJoinedDate: property.tenantJoinedDate,
        serviceRequestCounts: newCounts,
        serviceRequestMessages: newMessages,
        createdAt: property.createdAt,
      );

      pc.returnTabIndex.value = 0; // Remember we came from Home
      pc.selectedProperty.value = matchedProperty;
      nav.currentIndex.value = 1; // Switch to Property tab
    }
  }

  void _showServiceDetailsDialog(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Service Request Details', style: AppTheme.heading2),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogRow('Property', item['propertyName'] ?? ''),
                  const SizedBox(height: 12),
                  _buildDialogRow('Landlord', item['landlordName'] ?? ''),
                  const SizedBox(height: 12),
                  _buildDialogRow('Tenant', item['tenantName'] ?? ''),
                  const SizedBox(height: 12),
                  _buildDialogRow('Location', item['location'] ?? ''),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border, height: 1),
                  const SizedBox(height: 16),
                  _buildDialogRow(
                    'Issue',
                    item['detail']?.replaceAll('Issue: ', '') ?? '',
                  ),
                  const SizedBox(height: 12),
                  _buildDialogRow('Raised Date', item['raisedDate'] ?? ''),
                  const SizedBox(height: 12),
                  if (item['status'] == 'Solved') ...[
                    _buildDialogRow(
                      'Resolved Date',
                      item['resolvedDate'] ?? '',
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildDialogRow('Status', item['status'] ?? ''),
                  const SizedBox(height: 12),
                  _buildDialogRow('Activity', item['activeStatus'] ?? ''),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _navigateToProperty(item);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Property Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.bgDark,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyText.copyWith(
              color:
                  (label == 'Status' && value == 'Solved')
                      ? AppTheme.accentGreen
                      : (label == 'Status' && value == 'Pending')
                      ? AppTheme.accentOrange
                      : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
