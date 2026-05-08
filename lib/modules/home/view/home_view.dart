import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'components/subscription_detail_panel.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import 'package:agremate_admin/modules/services/controller/services_controller.dart';
import 'package:agremate_admin/core/constants/constants.dart';

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
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => controller.toggleList(title),
                  borderRadius: BorderRadius.circular(20),
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
                          data
                              .take(10)
                              .map(
                                (item) => _ActivityItemCard(
                                  key: ValueKey(item['title'] ?? item.hashCode),
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
        ),
      );
    });
  }

  Widget _buildMetadataRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 4),
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
        createdAt: property.createdAt,
      );

      pc.returnTabIndex.value = 0;
      pc.selectedProperty.value = matchedProperty;
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
  int _imagePage = 0;

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
      // Keep highlighted while panel is open; reset when closed
      ever(widget.controller.selectedSubscription, (val) {
        if (val == null && mounted) setState(() => _isSelected = false);
      });
    } else if (title == 'Recent Service Requests') {
      final nav = Get.find<NavigationController>();
      try {
        final sc = Get.find<ServicesController>();
        final detail = (item['detail'] as String? ?? '').toLowerCase();
        String? matchedType;
        for (final type in AppConstants.serviceTypes) {
          if (detail.contains(type.toLowerCase()) ||
              (type == 'Electricity' && detail.contains('electrical'))) {
            matchedType = type;
            break;
          }
        }
        sc.selectServiceType(matchedType ?? 'Others');
      } catch (_) {}
      nav.currentIndex.value = 2;
      if (mounted) setState(() => _isSelected = false);
    }
  }

  Widget _buildPropertyThumbnails(Map<String, dynamic> item) {
    final List<String> images =
        (item['propertyImages'] as List<dynamic>?)?.cast<String>() ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    const int pageSize = 4;
    final int totalPages = (images.length / pageSize).ceil();
    final int startIdx = _imagePage * pageSize;
    final displayImages = images.skip(startIdx).take(pageSize).toList();
    final bool hasMore = images.length > pageSize;

    return SizedBox(
      width: 180, // Fixed width for the entire gallery area
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Arrow Slot
          SizedBox(
            width: 20,
            height: 24,
            child: (hasMore && _imagePage > 0)
                ? InkWell(
                  onTap: () {
                    setState(() {
                      _imagePage = (_imagePage - 1 + totalPages) % totalPages;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 10,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                )
                : null,
          ),

          const SizedBox(width: 8),

          // Image Set
          Row(
            mainAxisSize: MainAxisSize.min,
            children:
                displayImages.map((url) {
                  return Container(
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
                  );
                }).toList(),
          ),

          const Spacer(),

          // Right Arrow Slot
          SizedBox(
            width: 20,
            height: 24,
            child:
                hasMore
                    ? InkWell(
                      onTap: () {
                        setState(() {
                          _imagePage = (_imagePage + 1) % totalPages;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          _imagePage == totalPages - 1
                              ? Icons.refresh
                              : Icons.arrow_forward_ios,
                          size: 10,
                          color: AppTheme.accentBlue,
                        ),
                      ),
                    )
                    : null,
          ),
        ],
      ),
    );
  }

  void _showDocumentPreview(BuildContext context, Map<String, dynamic> item, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description, color: AppTheme.accentBlue),
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
            _buildPreviewRow('Property', item['propertyName'] ?? 'Green Villa'),
            const SizedBox(height: 8),
            _buildPreviewRow('Landlord', item['landlordName'] ?? 'John Doe'),
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
                    Text(
                      'Preview not available',
                      style: AppTheme.caption,
                    ),
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
              style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondary),
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
            child: const Text('Download File', style: TextStyle(color: Colors.white)),
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
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': return Icons.description;
      case 'svg': return Icons.code;
      case 'jpg': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }

  Widget _buildDocumentThumbnails(Map<String, dynamic> item) {
    final List<String> types =
        (item['fileTypes'] as List<dynamic>?)?.cast<String>() ?? [];
    if (types.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 26), // Match property gallery start position (20+6)
          ...types.map((type) {
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
                color = Colors.green.shade400;
                break;
              default:
                iconData = Icons.insert_drive_file;
                color = Colors.grey;
            }
            return InkWell(
              onTap: () => _showDocumentPreview(context, item, type),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(iconData, size: 14, color: color),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Solved':
        return const Color(0xFF4CAF50); // Green
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
    final title = widget.title;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _isSelected ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _isSelected
                  ? const Color(0xFF2196F3) // blue border when selected
                  : AppTheme.border.withValues(alpha: 0.5),
          width: _isSelected ? 1.8 : 1.0,
        ),
        boxShadow:
            _isSelected
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
          splashColor: const Color(0xFF2196F3).withValues(alpha: 0.08),
          highlightColor: const Color(0xFF2196F3).withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Left: Main Info ──────────────────────────────────────────
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title == 'Recent Rent Collections') ...[
                        Text(
                          item['title']!,
                          style: AppTheme.bodyText.copyWith(
                            color: Colors.black,
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
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Plan: ${item['detail']!.replaceAll('Subscription', '').trim()}',
                          style: AppTheme.bodyText.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ] else if (title == 'Property') ...[
                        Row(
                          children: [
                            SizedBox(
                              width: 140, // Fixed width for name to ensure alignment
                              child: Text(
                                item['title']!,
                                style: AppTheme.bodyText.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 80),
                            _buildPropertyThumbnails(item),
                          ],
                        ),
                        const SizedBox(height: 4),
                        widget.buildLabelValue(
                          'Landlord',
                          item['landlordName'] ?? '',
                          AppTheme.landlordFill,
                        ),
                      ] else if (title == 'Document') ...[
                        Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                item['propertyName'] ?? 'Green Villa',
                                style: AppTheme.bodyText.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 80),
                            _buildDocumentThumbnails(item),
                          ],
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
                            color: Colors.black,
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
                            color: Colors.black,
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

                // ── Right: Metadata + Chips (aligned to end) ─────────────────
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (title == 'Recent Rent Collections') ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Advance + Rent chips on the left
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 175,
                                  child: widget.buildOutlinedChip(
                                    'Advance: ${item['advanceAmount']}',
                                    AppTheme.accentBlue,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 175,
                                  child: widget.buildOutlinedChip(
                                    'Rent: ${item['rentAmount']}',
                                    AppTheme.accentBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            // Location + Joined on the right
                            Expanded(
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
                                  width: 140, // Reduced chip width
                                  child: widget.buildOutlinedChip(
                                    item['detail']!.replaceAll('Issue: ', ''),
                                    AppTheme.accentCyan,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 170, // Slightly reduced metadata width
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: Colors.black, // Changed to black
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item['location'] ?? '',
                                          style: AppTheme.caption.copyWith(
                                            fontSize: 10.5,
                                            color:
                                                Colors
                                                    .black, // Changed to black
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1), // Minimal vertical gap
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 140, // Reduced chip width
                                  child: widget.buildOutlinedChip(
                                    item['status'] ?? 'Pending',
                                    item['status'] == 'Solved'
                                        ? AppTheme.accentBlue
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 170, // Slightly reduced metadata width
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Colors.black, // Changed to black
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Raised: ${item['raisedDate']}',
                                          style: AppTheme.caption.copyWith(
                                            fontSize: 10.5,
                                            color:
                                                Colors
                                                    .black, // Changed to black
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
                                              Colors.black, // Changed to black
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
                              style: AppTheme.caption.copyWith(fontSize: 11),
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
                                SizedBox(
                                  width: 140,
                                  child: widget.buildOutlinedChip(
                                    item['status'] ?? 'Available',
                                    AppTheme.accentBlue,
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
                                      const SizedBox(width: 8),
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
                              ],
                            ),
                            const SizedBox(height: 1),
                            // Joined Date Row
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
                                      'Joined: ${item['joinedDate'] ?? 'Jan 2024'}',
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  /// Wraps a chip widget in a right-aligned, width-constrained box.
  Widget _buildRightAlignedChip(Widget chip) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(width: 160, child: chip),
    );
  }
}
