import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/modules/home/view/components/subscription_detail_panel.dart';
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
      final nav = Get.find<NavigationController>();
      final query = nav.searchQuery.value;

      // Update home controller search when query changes
      controller.search(query);

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
                    final title = list['title'] as String;
                    final isService = title == 'Recent Service Requests';
                    final isRent = title == 'Recent Rent Collections';
                    final isSubs = title == 'Recent Subscriptions';

                    return Obx(() {
                      // Explicitly read from the matching RxList so GetX
                      // always has a registered observable dependency.
                      final List<Map<String, dynamic>> rawData;
                      if (isRent) {
                        rawData = List<Map<String, dynamic>>.from(
                          controller.recentRent,
                        );
                      } else if (isService) {
                        rawData = List<Map<String, dynamic>>.from(
                          controller.recentServices,
                        );
                      } else if (isSubs) {
                        rawData = List<Map<String, dynamic>>.from(
                          controller.recentSubs,
                        );
                      } else if (title == 'Property') {
                        rawData = List<Map<String, dynamic>>.from(
                          controller.propertyList,
                        );
                      } else if (title == 'Document') {
                        rawData = List<Map<String, dynamic>>.from(
                          controller.documentList,
                        );
                      } else {
                        rawData = List<Map<String, dynamic>>.from(
                          controller.supportList,
                        );
                      }

                      final List<Map<String, dynamic>> data =
                          controller.getFilteredData(rawData, query);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _ActivityListCard(
                          title: title,
                          data: data,
                          color: list['color'] as Color,
                          controller: controller,
                          isService: isService,
                          emptyMessage:
                              isService
                                  ? 'No recent service requests found.'
                                  : isRent && data.isEmpty
                                  ? 'Loading rent collections...'
                                  : null,
                        ),
                      );
                    });
                  }).toList(),
                ],
              ),
            ),
          if (selectedSub != null) ...[
            GestureDetector(
              onTap: () => controller.selectedSubscription.value = null,
              child: Container(
                color: AppTheme.brandSteelBlue.withValues(alpha: 0.12),
              ),
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
  final String? emptyMessage;
  final bool isService;

  const _ActivityListCard({
    required this.title,
    required this.data,
    required this.color,
    required this.controller,
    this.emptyMessage,
    this.isService = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Accessing length ensures GetX registers this as an observable dependency
      // even if the specific key doesn't exist yet in the RxMap.
      controller.expandedLists.length;
      final isExpanded = controller.expandedLists[title] ?? false;
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.white : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpanded ? const Color(0xFF2196F3) : AppTheme.border,
            width: isExpanded ? 1.5 : 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => controller.toggleList(title),
                borderRadius: BorderRadius.circular(20),
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
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
                          style: AppTheme.heading3.copyWith(
                            color: Colors.black,
                            fontSize: 16,
                          ),
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
              ),
              if (isExpanded) ...[
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: AppTheme.border.withValues(alpha: 0.5),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                        (isService && controller.isLoading.value)
                            ? [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              ),
                            ]
                            : data.isEmpty
                            ? [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Text(
                                  emptyMessage ?? 'No records found.',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.bodyText.copyWith(
                                    color: AppTheme.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ]
                            : isService
                            ? [
                              Column(
                                children:
                                    data.take(10).map((item) {
                                      final raw = item['rawModel'];
                                      return _HomeServiceRequestCard(
                                        item: item,
                                        rawModel: raw,
                                      );
                                    }).toList(),
                              ),
                            ]
                            : data
                                .take(10)
                                .map(
                                  (item) => _ActivityItemCard(
                                    key: ValueKey(
                                      item['title'] ?? item.hashCode,
                                    ),
                                    item: item,
                                    title: title,
                                    controller: controller,
                                    onNavigateToProperty: _navigateToProperty,
                                    buildMetadataRow: _buildMetadataRow,
                                    buildLabelValue: _buildLabelValue,
                                    buildFilledChip: _buildFilledChip,
                                    buildOutlinedChip: _buildOutlinedChip,
                                    buildUsageIndicator: _buildUsageIndicator,
                                  ),
                                )
                                .cast<Widget>()
                                .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMetadataRow(IconData icon, String text) {
    final bool isDate =
        text.startsWith('Joined:') ||
        text.startsWith('Raised:') ||
        text.startsWith('Solved:') ||
        text.startsWith('Added:');

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        if (isDate)
          Text(text, style: AppTheme.caption.copyWith(fontSize: 11))
        else
          Flexible(
            child: Text(
              text,
              style: AppTheme.caption.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildLabelValue(String label, String value, Color color) {
    return Row(
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 1.2),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildUsageIndicator(Map<String, dynamic> item) {
    final int used = item['usedProperties'] ?? 0;
    final int total = item['totalProperties'] ?? 10;
    final bool isCustom = item['detail']?.contains('Custom') ?? false;

    if (isCustom) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 12,
              color: AppTheme.accentBlue,
            ),
            const SizedBox(width: 6),
            Text(
              '$used Used Properties',
              style: AppTheme.caption.copyWith(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.generate(total, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color:
                    index < used
                        ? AppTheme.accentBlue
                        : AppTheme.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          '$used Slots filled',
          style: AppTheme.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _navigateToProperty(Map<String, dynamic> item) {
    final nav = Get.find<NavigationController>();
    final pc = Get.find<PropertyController>();

    final propName = item['propertyName'] ?? item['title'] ?? '';
    PropertyModel? property = pc.properties.firstWhereOrNull(
      (p) => p.name.toLowerCase() == propName.toLowerCase(),
    );

    if (property == null) {
      final parts = propName.split(' ');
      property = pc.properties.firstWhereOrNull((p) {
        final pName = p.name.toLowerCase();
        return parts.every((part) => pName.contains(part));
      });
    }

    // If still not found (common for dashboard mock data), create a synthetic property model
    // as a base instead of falling back to the first available property.
    property ??= PropertyModel(
      id: 'synth-${propName.hashCode}',
      name: propName,
      address: PropertyAddress(
        address: item['location'] ?? 'Unknown Location',
        latitude: 0,
        longitude: 0,
      ),
      status: PropertyStatus.rented,
      createdAt: DateTime.now(),
      landlordName: item['landlordName'] ?? 'N/A',
      primaryTenantName: item['tenantName'] ?? 'N/A',
      imageUrl:
          item['propertyImage'] ??
          'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=600&h=300&auto=format&fit=crop',
      images: const <String>[],
      tenantIds: const <String>[],
    );

    if (property != null) {
      final newCounts = Map<String, int>.from(property.serviceRequestCounts);
      final newMessages = Map<String, String>.from(
        property.serviceRequestMessages,
      );

      final detail = item['detail'] as String?;
      if (detail != null &&
          detail.startsWith('Issue: ') &&
          item['status'] == 'Pending') {
        final issueFull = detail.replaceFirst('Issue: ', '').trim();
        final issueType = issueFull.split(' ').first;

        if (newCounts.containsKey(issueType)) {
          newCounts[issueType] = (newCounts[issueType] ?? 0) + 1;
          newMessages[issueType] =
              'Tenant reported: $issueFull. Request raised on ${item['raisedDate']}.';
        }
      }

      final matchedProperty = PropertyModel(
        id: property.id,
        name: property.name,
        address:
            item['location'] != null
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
        images: property.images,
        createdAt: property.createdAt,
      );

      pc.returnTabIndex.value = 0;
      pc.selectedProperty.value = matchedProperty;
      nav.searchQuery.value = '';
      nav.currentIndex.value = 1;
    }
  }

  Widget _buildPropertyImageSlots(Map<String, dynamic> item) {
    final List<String> images =
        (item['propertyImages'] as List<dynamic>?)?.cast<String>() ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    const int maxVisible = 4;
    final displayImages = images.take(maxVisible).toList();
    final bool hasMore = images.length > maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayImages.map((url) {
          return InkWell(
            onTap: () => _navigateToProperty(item),
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.5),
                ),
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
        if (hasMore)
          InkWell(
            onTap: () => _navigateToProperty(item),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 10,
                color: AppTheme.accentBlue,
              ),
            ),
          ),
      ],
    );
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

// ── Individual Activity Item Card with selected-state ─────────────────────────
class _ActivityItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final String title;
  final HomeController controller;
  final void Function(Map<String, dynamic>) onNavigateToProperty;
  final Widget Function(IconData, String) buildMetadataRow;
  final Widget Function(String, String, Color) buildLabelValue;
  final Widget Function(String, Color) buildFilledChip;
  final Widget Function(String, Color) buildOutlinedChip;
  final Widget Function(Map<String, dynamic>) buildUsageIndicator;

  const _ActivityItemCard({
    super.key,
    required this.item,
    required this.title,
    required this.controller,
    required this.onNavigateToProperty,
    required this.buildMetadataRow,
    required this.buildLabelValue,
    required this.buildFilledChip,
    required this.buildOutlinedChip,
    required this.buildUsageIndicator,
  });

  @override
  State<_ActivityItemCard> createState() => _ActivityItemCardState();
}

class _ActivityItemCardState extends State<_ActivityItemCard> {
  bool _isSelected = false;
  bool _isHovering = false;
  int _imagePage = 0;
  final Set<String> _brokenImages = {};

  Future<void> _handleTap() async {
    // Show blue highlight immediately
    setState(() => _isSelected = true);

    final title = widget.title;
    final item = widget.item;

    // Short delay so the blue border is visibly seen before any transition
    await Future.delayed(const Duration(milliseconds: 180));

    if (!mounted) return;

    if (title == 'Recent Rent Collections') {
      widget.onNavigateToProperty(item);
      if (mounted) setState(() => _isSelected = false);
    } else if (title == 'Property') {
      widget.onNavigateToProperty(item);
      if (mounted) setState(() => _isSelected = false);
    } else if (title == 'Recent Subscriptions') {
      widget.controller.selectedSubscription.value = item;
    } else if (title == 'Recent Service Requests') {
      if (mounted) setState(() => _isSelected = false);
      _showServiceChatDialog(context, item);
    }
  }

  void _showServiceChatDialog(BuildContext context, Map<String, dynamic> item) {
    final messages =
        (item['chatMessages'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
    final String propertyName = item['propertyName'] ?? item['title'] ?? '';
    final String issue = (item['detail'] as String? ?? '').replaceAll(
      'Issue: ',
      '',
    );
    final String status = item['status'] ?? 'Pending';
    final String tenantName = item['tenantName'] ?? '';
    final String landlordName = item['landlordName'] ?? '';
    final String location = item['location'] ?? '';

    showDialog(
      context: context,
      barrierColor: const Color(0xFF1565C0).withValues(alpha: 0.15),
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 60,
              vertical: 40,
            ),
            child: Container(
              width: 520,
              constraints: const BoxConstraints(maxHeight: 680),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Chat Header ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.home_work_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                propertyName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                issue,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    status == 'Solved'
                                        ? const Color(0xFF43A047)
                                        : const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              location,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Participants Bar ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        _chatParticipantChip(
                          Icons.person_outlined,
                          'Tenant',
                          tenantName,
                          const Color(0xFF1E88E5),
                        ),
                        const SizedBox(width: 12),
                        _chatParticipantChip(
                          Icons.business_center_outlined,
                          'Landlord',
                          landlordName,
                          const Color(0xFF43A047),
                        ),
                      ],
                    ),
                  ),

                  Container(height: 1, color: const Color(0xFFE0E0E0)),

                  // ── Chat Messages ────────────────────────────────────────
                  Expanded(
                    child:
                        messages.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF1E88E5,
                                      ).withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 40,
                                      color: Color(0xFF1E88E5),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No messages yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'The tenant and landlord haven\'t\nchatted about this issue yet.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF757575),
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              itemCount: messages.length,
                              itemBuilder: (ctx, idx) {
                                final msg = messages[idx];
                                final isTenant = msg['sender'] == 'tenant';
                                return _buildChatBubble(
                                  message: msg['message'] as String,
                                  senderName: msg['senderName'] as String,
                                  time: msg['time'] as String,
                                  isTenant: isTenant,
                                  isRead: msg['isRead'] as bool? ?? true,
                                );
                              },
                            ),
                  ),

                  // ── Footer ───────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Chat is read-only. Admin can view conversation history.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            backgroundColor: const Color(
                              0xFF1E88E5,
                            ).withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              color: Color(0xFF1E88E5),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _chatParticipantChip(
    IconData icon,
    String role,
    String name,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF212121),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble({
    required String message,
    required String senderName,
    required String time,
    required bool isTenant,
    required bool isRead,
  }) {
    // Tenant bubbles on LEFT (blue), Landlord bubbles on RIGHT (green)
    final Color bubbleColor =
        isTenant ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9);
    final Color nameColor =
        isTenant ? const Color(0xFF1565C0) : const Color(0xFF2E7D32);
    final CrossAxisAlignment crossAlign =
        isTenant ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final MainAxisAlignment rowAlign =
        isTenant ? MainAxisAlignment.start : MainAxisAlignment.end;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: rowAlign,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isTenant) ...[_avatarCircle(isTenant), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: crossAlign,
              children: [
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: nameColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isTenant ? 4 : 16),
                      bottomRight: Radius.circular(isTenant ? 16 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF212121),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    if (!isTenant) ...[
                      // Show read status for landlord msgs
                      const SizedBox(width: 4),
                      Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: 12,
                        color:
                            isRead
                                ? const Color(0xFF1E88E5)
                                : const Color(0xFF9E9E9E),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!isTenant) ...[const SizedBox(width: 8), _avatarCircle(isTenant)],
        ],
      ),
    );
  }

  Widget _avatarCircle(bool isTenant) {
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          isTenant
              ? const Color(0xFF1E88E5).withValues(alpha: 0.15)
              : const Color(0xFF43A047).withValues(alpha: 0.15),
      child: Icon(
        isTenant ? Icons.person : Icons.business_center,
        size: 16,
        color: isTenant ? const Color(0xFF1E88E5) : const Color(0xFF43A047),
      ),
    );
  }

  Widget _buildPropertyThumbnails(Map<String, dynamic> item) {
    final List<String> images =
        (item['propertyImages'] as List<dynamic>?)
            ?.cast<String>()
            .where((url) => !_brokenImages.contains(url))
            .toList() ??
        [];

    Widget container(Widget child) {
      return Container(
        width: 152,
        alignment: Alignment.centerLeft,
        child: child,
      );
    }

    if (images.isEmpty) return container(const SizedBox.shrink());

    int maxSlots = 4;
    int slotsLeft = maxSlots;
    int startIndex = _imagePage == 0 ? 0 : 3 + (_imagePage - 1) * 2;
    List<Widget> children = [];

    if (startIndex > 0) {
      children.add(
        InkWell(
          onTap: () => setState(() => _imagePage--),
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
      slotsLeft--;
    }

    int maxImagesAllowed = slotsLeft == 4 ? 3 : slotsLeft;
    bool needsForward = startIndex + maxImagesAllowed < images.length;
    if (needsForward) slotsLeft--;

    for (int i = 0; i < slotsLeft && startIndex + i < images.length; i++) {
      children.add(_buildThumbnail(images, startIndex + i));
    }

    if (needsForward) {
      children.add(
        InkWell(
          onTap: () => setState(() => _imagePage++),
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return container(Row(mainAxisSize: MainAxisSize.min, children: children));
  }

  Widget _buildThumbnail(List<String> images, int index) {
    return InkWell(
      onTap: () => _showImagePreviewDialog(context, images, index),
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_brokenImages.contains(images[index])) {
                  setState(() {
                    _brokenImages.add(images[index]);
                  });
                }
              });
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showImagePreviewDialog(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    int currentIndex = initialIndex;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      InteractiveViewer(
                        key: ValueKey(currentIndex),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            images[currentIndex],
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.transparent,
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 64,
                                      color: Colors.white54,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Image not found',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (currentIndex > 0)
                        Positioned(
                          left: 12,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  currentIndex--;
                                });
                              },
                            ),
                          ),
                        ),
                      if (currentIndex < images.length - 1)
                        Positioned(
                          right: 12,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  currentIndex++;
                                });
                              },
                            ),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDocumentPreview(
    BuildContext context,
    Map<String, dynamic> item,
    String type,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Document Preview',
                        style: AppTheme.heading3.copyWith(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${type.toUpperCase()} Document',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 12),
                _buildPreviewRow(
                  'Property',
                  item['propertyName'] ?? 'Green Villa',
                ),
                const SizedBox(height: 8),
                _buildPreviewRow(
                  'Landlord',
                  item['landlordName'] ?? 'John Doe',
                ),
                const SizedBox(height: 8),
                _buildPreviewRow('Status', 'Verified'),
                const SizedBox(height: 8),
                _buildPreviewRow('Uploaded', item['date'] ?? 'Oct 10, 2023'),
                const SizedBox(height: 20),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getFileIcon(type),
                          size: 40,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text('Preview not available', style: AppTheme.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Downloading',
                    'Downloading ${item['title']}...',
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Download File',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.caption),
        Text(
          value,
          style: AppTheme.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
        return Icons.description;
      case 'svg':
        return Icons.code;
      case 'jpg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildDocumentThumbnails(Map<String, dynamic> item) {
    final List<String> types =
        (item['fileTypes'] as List<dynamic>?)?.cast<String>() ?? [];
    if (types.isEmpty) return const SizedBox(width: 152);

    return Container(
      width: 152,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            types.map((type) {
              IconData iconData;
              Color color;
              switch (type.toLowerCase()) {
                case 'pdf':
                  iconData = Icons.picture_as_pdf;
                  color = Colors.red.shade400;
                  break;
                case 'doc':
                  iconData = Icons.description;
                  color = Colors.blue.shade400;
                  break;
                case 'svg':
                  iconData = Icons.code;
                  color = Colors.orange.shade400;
                  break;
                case 'jpg':
                  iconData = Icons.image;
                  color = Colors.blue.shade400;
                  break;
                default:
                  iconData = Icons.insert_drive_file;
                  color = Colors.grey;
              }
              return InkWell(
                onTap: () => _showDocumentPreview(context, item, type),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(iconData, size: 16, color: color),
                ),
              );
            }).toList(),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Solved':
        return AppTheme.accentBlue;
      case 'In Progress':
        return const Color(0xFF2196F3); // Blue
      case 'Pending':
        return const Color(0xFFF44336); // Red
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final title =
        (widget.title == 'Search Results')
            ? (item['type'] == 'property'
                ? 'Property'
                : item['type'] == 'rent'
                ? 'Recent Rent Collections'
                : item['type'] == 'subscription'
                ? 'Recent Subscriptions'
                : item['type'] == 'service'
                ? 'Recent Service Requests'
                : item['type'] == 'document'
                ? 'Document'
                : item['type'] == 'support'
                ? 'Support'
                : widget.title)
            : widget.title;

    return Obx(() {
      // Accessing the value first ensures GetX registers the dependency even if the
      // title check would otherwise short-circuit the expression.
      final currentSub = widget.controller.selectedSubscription.value;
      final isSubSelected =
          title == 'Recent Subscriptions' && currentSub == item;
      final isSelected = _isSelected || isSubSelected;

      return MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: (isSelected || _isHovering) ? Colors.white : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  (isSelected || _isHovering)
                      ? const Color(0xFF2196F3)
                      : AppTheme.border,
              width: (isSelected || _isHovering) ? 1.5 : 1.0,
            ),
            boxShadow:
                (_isSelected || _isHovering)
                    ? [
                      BoxShadow(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(12),
              hoverColor: Colors.transparent,
              splashColor: const Color(0xFF2196F3).withValues(alpha: 0.08),
              highlightColor: const Color(0xFF2196F3).withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Left: Main Info ──────────────────────────────────────────
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title == 'Recent Rent Collections') ...[
                            Text(
                              item['title']!,
                              style: AppTheme.bodyText.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            widget.buildLabelValue(
                              'Landlord',
                              item['landlordName'] ?? '',
                              Colors.black,
                            ),
                            const SizedBox(height: 2),
                            widget.buildLabelValue(
                              'Tenant',
                              item['tenantName'] ?? '',
                              Colors.black,
                            ),
                          ] else if (title == 'Recent Service Requests') ...[
                            Text(
                              item['propertyName'] ?? '',
                              style: AppTheme.bodyText.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            widget.buildLabelValue(
                              'Landlord: ',
                              item['landlordName'] ?? '',
                              AppTheme.landlordFill,
                            ),
                            const SizedBox(height: 2),
                            widget.buildLabelValue(
                              'Tenant: ',
                              item['tenantName'] ?? '',
                              AppTheme.tenantFill,
                            ),
                          ] else if (title == 'Recent Subscriptions') ...[
                            Text(
                              item['title']!,
                              style: AppTheme.bodyText.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Plan: ${item['detail']!.replaceAll('Subscription', '').replaceAll('Plan:', '').trim()}',
                              style: AppTheme.bodyText.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ] else if (title == 'Property') ...[
                            Text(
                              item['title']!,
                              style: AppTheme.bodyText.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            widget.buildLabelValue(
                              'Landlord',
                              item['landlordName'] ?? '',
                              AppTheme.landlordFill,
                            ),
                            if (item['status'] == 'Rented') ...[
                              const SizedBox(height: 2),
                              widget.buildLabelValue(
                                'Tenant',
                                item['tenantName'] ?? 'Akash Roy',
                                AppTheme.tenantFill,
                              ),
                            ],
                          ] else if (title == 'Document') ...[
                            Text(
                              item['propertyName'] ?? 'Green Villa',
                              style: AppTheme.bodyText.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            widget.buildLabelValue(
                              'Landlord',
                              item['landlordName'] ?? 'John Doe',
                              AppTheme.landlordFill,
                            ),
                          ] else if (title == 'Support') ...[
                            Text(
                              item['title']!,
                              style: AppTheme.bodyText.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            widget.buildLabelValue(
                              'Category',
                              item['category'] ?? '',
                              AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 2),
                            widget.buildLabelValue(
                              'Message',
                              item['message'] ?? '',
                              AppTheme.textSecondary,
                            ),
                          ] else ...[
                            Text(
                              item['title'] ?? title,
                              style: AppTheme.bodyText.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['detail'] ?? '',
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

                    const SizedBox(width: 16),

                    // ── Right: Metadata + Chips ──────────────────────────────────
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (title == 'Recent Rent Collections') ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.accentBlue
                                                .withValues(alpha: 0.8),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Text(
                                          'Advance: ${item['advanceAmount']}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 140,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.accentBlue
                                                .withValues(alpha: 0.8),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Text(
                                          'Rent: ${item['rentAmount']}',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 180,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      widget.buildMetadataRow(
                                        Icons.location_on_outlined,
                                        item['location'] ?? '',
                                      ),
                                      const SizedBox(height: 6),
                                      widget.buildMetadataRow(
                                        Icons.calendar_today_outlined,
                                        'Joined: ${item['joinedDate']}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ] else if (title == 'Recent Service Requests') ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      child: widget.buildOutlinedChip(
                                        item['detail']!.replaceAll(
                                          'Issue: ',
                                          '',
                                        ),
                                        AppTheme.accentCyan,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 170,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              item['location'] ?? '',
                                              style: AppTheme.caption.copyWith(
                                                fontSize: 10.5,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      child: widget.buildOutlinedChip(
                                        item['status'] ?? 'Pending',
                                        item['status'] == 'Solved'
                                            ? AppTheme.accentBlue
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 170,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Raised: ${item['raisedDate']}',
                                              style: AppTheme.caption.copyWith(
                                                fontSize: 10.5,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (item['status'] == 'Solved' &&
                                    item['resolvedDate'] != null) ...[
                                  const SizedBox(
                                    height: 2,
                                  ), // Further reduced vertical gap
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const SizedBox(
                                        width: 140,
                                      ), // Spacer for chip column
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 170,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle_outline,
                                              size: 14,
                                              color:
                                                  Colors
                                                      .black, // Changed to black
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                'Solved: ${item['resolvedDate']}',
                                                style: AppTheme.caption.copyWith(
                                                  fontSize: 10.5,
                                                  color:
                                                      Colors
                                                          .black, // Changed to black
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ] else if (title == 'Recent Subscriptions') ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (item['status'] != null) ...[
                                  item['status'] == 'Active'
                                      ? StatusBadge.active()
                                      : StatusBadge.expired(),
                                  const SizedBox(width: 12),
                                ],
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Joined: ${item['joinedDate'] ?? 'Jan 2024'}',
                                  style: AppTheme.caption.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            widget.buildUsageIndicator(item),
                          ] else if (title == 'Property') ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Chip + Location Row (Ensures horizontal alignment)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 152,
                                        ),
                                        child: _buildPropertyThumbnails(item),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width: 100,
                                      child: widget.buildOutlinedChip(
                                        item['status'] ?? 'Available',
                                        (item['status']
                                                    ?.toString()
                                                    .toLowerCase()
                                                    .contains('maintenance') ==
                                                true)
                                            ? AppTheme.brandRed
                                            : (item['status']
                                                    ?.toString()
                                                    .toLowerCase()
                                                    .contains('unknown') ==
                                                true)
                                            ? AppTheme.accentBlue
                                            : (item['status']
                                                    ?.toString()
                                                    .toLowerCase()
                                                    .contains('available') ==
                                                true)
                                            ? AppTheme.statusAvailableText
                                            : const Color(0xFF27AE60),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      flex: 3,
                                      child: SizedBox(
                                        width: 120,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['location'] ?? '',
                                                style: AppTheme.caption
                                                    .copyWith(
                                                      fontSize: 10,
                                                      color: Colors.black,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () {
                                                // Placeholder for more options
                                              },
                                              child: const Icon(
                                                Icons.more_vert,
                                                size: 18,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                // Joined Date Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Joined: ${item['joinedDate'] ?? 'Jan 2024'}',
                                      style: AppTheme.caption.copyWith(
                                        fontSize: 10.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ] else if (title == 'Support') ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      child: widget.buildOutlinedChip(
                                        item['status'] ?? 'Pending',
                                        _getStatusColor(item['status']),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 170,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          widget.buildMetadataRow(
                                            Icons.calendar_today_outlined,
                                            'Raised: ${item['date'] ?? ''}',
                                          ),
                                          if (item['status'] == 'Solved') ...[
                                            const SizedBox(height: 6),
                                            widget.buildMetadataRow(
                                              Icons.check_circle_outline,
                                              'Solved: ${item['resolvedDate'] ?? ''}',
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ] else if (title == 'Document') ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 152,
                                        ),
                                        child: _buildDocumentThumbnails(item),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const SizedBox(
                                      width: 100,
                                    ), // Spacer for alignment
                                    const SizedBox(width: 8),
                                    Flexible(
                                      flex: 3,
                                      child: SizedBox(
                                        width: 120,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['location'] ??
                                                    'Not specified',
                                                style: AppTheme.caption
                                                    .copyWith(
                                                      fontSize: 10,
                                                      color: Colors.black,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () {},
                                              child: const Icon(
                                                Icons.more_vert,
                                                size: 18,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                // Date Row
                                SizedBox(
                                  width: 120,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Added: ${item['date'] ?? 'Jan 2024'}',
                                          style: AppTheme.caption.copyWith(
                                            fontSize: 10.5,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            if (item['date'] != null)
                              widget.buildMetadataRow(
                                Icons.calendar_today_outlined,
                                item['date']!,
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
        ),
      );
    });
  }
}

class _HomeServiceRequestCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final dynamic rawModel;

  const _HomeServiceRequestCard({required this.item, this.rawModel});

  @override
  Widget build(BuildContext context) {
    final status = item['status']?.toString().toLowerCase() ?? 'pending';
    final dateStr = item['raisedDate'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            if (rawModel != null) {
              _showServiceChatDialog(context, rawModel);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2083D5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['propertyName'] ?? 'Unknown Property',
                        style: AppTheme.heading3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['tenantName'] != null &&
                                    item['tenantName'] != 'N/A'
                                ? 'By ${item['tenantName']}'
                                : 'No Tenant',
                            style: AppTheme.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildSmallChip(
                          item['detail']?.toString().replaceFirst(
                                'Issue: ',
                                '',
                              ) ??
                              'No Description',
                          AppTheme.accentCyan,
                        ),
                        const SizedBox(width: 10),
                        _buildDateRow(
                          Icons.calendar_today_outlined,
                          'Requested: $dateStr',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildSmallChip(
                          (item['status']?.toString() ?? 'PENDING')
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          _getStatusColor(status),
                        ),
                        const SizedBox(width: 10),
                        if (item['resolvedDate'] != null)
                          _buildDateRow(
                            Icons.check_circle_outline,
                            'Solved: ${item['resolvedDate']}',
                          )
                        else
                          const SizedBox(width: 170), // Maintain alignment
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallChip(String label, Color color) {
    return SizedBox(
      width: 140,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDateRow(IconData icon, String text) {
    return SizedBox(
      width: 170,
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.black),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: AppTheme.caption.copyWith(
                fontSize: 10.5,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status == 'solved' || status == 'completed') return AppTheme.accentBlue;
    if (status == 'pending') return AppTheme.brandRed;
    if (status == 'in_progress') return AppTheme.accentGreen;
    return AppTheme.accentCyan;
  }

  void _showServiceChatDialog(BuildContext context, dynamic req) {
    final String propertyName = req.propertyName;
    final String issue = req.description;
    final String status =
        (req.status ?? 'Pending')
            .toString()
            .replaceAll('_', ' ')
            .capitalizeFirst ??
        req.status.toString();
    final List<dynamic> messages = req.chatMessages;
    final String tenantName = req.tenantName;
    final String landlordName = req.landlordName;
    final String location = req.location;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final dialogWidth = constraints.maxWidth.clamp(320.0, 560.0);
                return Container(
                  width: dialogWidth,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.80,
                    maxWidth: dialogWidth,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chat Header
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                18,
                                56,
                                18,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.home_work_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          propertyName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          issue,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.85,
                                            ),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                status == 'Solved'
                                                    ? const Color(0xFF43A047)
                                                    : const Color(0xFFE53935),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          location,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.75,
                                            ),
                                            fontSize: 10,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Participants Bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            _chatParticipantChip(
                              Icons.person_outlined,
                              'Tenant',
                              tenantName,
                              const Color(0xFF1E88E5),
                            ),
                            const SizedBox(width: 12),
                            _chatParticipantChip(
                              Icons.business_center_outlined,
                              'Landlord',
                              landlordName,
                              const Color(0xFF43A047),
                            ),
                          ],
                        ),
                      ),

                      Container(height: 1, color: const Color(0xFFE0E0E0)),

                      // Chat Messages
                      Expanded(
                        child:
                            messages.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF1E88E5,
                                          ).withValues(alpha: 0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 40,
                                          color: Color(0xFF1E88E5),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No messages yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'The tenant and landlord haven\'t\nchatted about this issue yet.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF757575),
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    8,
                                  ),
                                  itemCount: messages.length,
                                  itemBuilder: (ctx, idx) {
                                    final msg = messages[idx];
                                    final isTenant = msg['sender'] == 'tenant';
                                    return _buildChatBubble(
                                      message: msg['message'] as String,
                                      senderName: msg['senderName'] as String,
                                      time: msg['time'] as String,
                                      isTenant: isTenant,
                                      isRead: msg['isRead'] as bool? ?? true,
                                    );
                                  },
                                ),
                      ),

                      // Footer
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Color(0xFF9E9E9E),
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                'Chat is read-only. Admin can view conversation history.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                backgroundColor: const Color(
                                  0xFF1E88E5,
                                ).withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }

  Widget _chatParticipantChip(
    IconData icon,
    String role,
    String name,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF212121),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble({
    required String message,
    required String senderName,
    required String time,
    required bool isTenant,
    required bool isRead,
  }) {
    final Color bubbleColor =
        isTenant ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9);
    final Color nameColor =
        isTenant ? const Color(0xFF1565C0) : const Color(0xFF2E7D32);
    final CrossAxisAlignment crossAlign =
        isTenant ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final MainAxisAlignment rowAlign =
        isTenant ? MainAxisAlignment.start : MainAxisAlignment.end;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: rowAlign,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isTenant) ...[_avatarCircle(isTenant), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: crossAlign,
              children: [
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: nameColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isTenant ? 4 : 16),
                      bottomRight: Radius.circular(isTenant ? 16 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF212121),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    if (!isTenant) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: 12,
                        color:
                            isRead
                                ? const Color(0xFF1E88E5)
                                : const Color(0xFF9E9E9E),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!isTenant) ...[const SizedBox(width: 8), _avatarCircle(isTenant)],
        ],
      ),
    );
  }

  Widget _avatarCircle(bool isTenant) {
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          isTenant
              ? const Color(0xFF1E88E5).withValues(alpha: 0.15)
              : const Color(0xFF43A047).withValues(alpha: 0.15),
      child: Icon(
        isTenant ? Icons.person : Icons.business_center,
        size: 16,
        color: isTenant ? const Color(0xFF1E88E5) : const Color(0xFF43A047),
      ),
    );
  }
}
