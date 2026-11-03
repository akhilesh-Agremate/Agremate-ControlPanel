import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/constants/constants.dart';
import 'package:agremate_admin/core/widgets/search_field.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../documents/view/documents_view.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final nav = Get.find<NavigationController>();
  static const double _compactBreakpoint = 600;

  void _showOverlay() {
    _hideOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final double screenW = MediaQuery.sizeOf(context).width;
        final double overlayWidth =
        screenW < _compactBreakpoint ? screenW - 32 : 320;

        return Positioned(
          width: overlayWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 48),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.bgDark,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                  color: AppTheme.bgDark,
                ),
                child: Obx(() {
                  if (nav.searchResults.isEmpty) return const SizedBox.shrink();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: nav.searchResults.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                    itemBuilder: (context, index) {
                      final result = nav.searchResults[index];
                      IconData icon;
                      Color iconColor;

                      switch (result.type) {
                        case SearchResultType.property:
                          icon = Icons.home_work_outlined;
                          iconColor = AppTheme.accentBlue;
                          break;
                        case SearchResultType.landlord:
                          icon = Icons.person_outline;
                          iconColor = AppTheme.accentGreen;
                          break;
                        case SearchResultType.tenant:
                          icon = Icons.people_outline;
                          iconColor = AppTheme.accentOrange;
                          break;
                        case SearchResultType.location:
                          icon = Icons.location_on_outlined;
                          iconColor = AppTheme.accentRed;
                          break;
                        case SearchResultType.service:
                          icon = Icons.handyman_outlined;
                          iconColor = AppTheme.accentCyan;
                          break;
                      }

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: iconColor, size: 20),
                        ),
                        title: Text(
                          result.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          result.subtitle,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          nav.onResultSelected(result);
                          _hideOverlay();
                        },
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void initState() {
    super.initState();
    ever(nav.searchResults, (results) {
      if (results.isNotEmpty && _overlayEntry == null) {
        _showOverlay();
      } else if (results.isEmpty && _overlayEntry != null) {
        _hideOverlay();
      }
    });
    ever(Get.find<PropertyController>().selectedProperty, (_) {
      if (_overlayEntry != null) {
        nav.searchResults.clear();
        nav.searchQuery.value = '';
        _hideOverlay();
      }
    });
    ever(nav.currentIndex, (_) {
      if (_overlayEntry != null) {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = nav.currentIndex.value;
      final showSearch = nav.showSearch;
      final double screenWidth = MediaQuery.sizeOf(context).width;
      final bool compact = screenWidth < _compactBreakpoint;

      String title = 'Dashboard';
      try {
        final item = AppConstants.navItems.firstWhere((element) => element['index'] == index);
        title = item['label'] as String;
        if (title == 'User') title = 'User Management';
        if (title == 'My Account') title = 'My Account';
      } catch (e) {
        title = 'Agremate Admin';
      }

      final Widget menuButton = Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      );

      final Widget searchWidget = CompositedTransformTarget(
        link: _layerLink,
        child: SearchField(
          hint: index == 0 ? 'Search tenant, property, location...' : 'Search ${title.toLowerCase()}...',
          initialValue: nav.searchQuery.value,
          onChanged: (q) {
            nav.searchQuery.value = q;
            if (index != 0) {
              nav.updateSearchResults(q);
            } else {
              nav.searchResults.clear();
            }
          },
          onSubmitted: (q) => nav.performGlobalSearch(q),
          onClear: () => nav.searchResults.clear(),
        ),
      );

      final Widget bell = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Icon(Icons.notifications_outlined, color: AppTheme.textMuted, size: 20),
      );

      final bool showCreateDoc = title == 'Documents' &&
          Get.isRegistered<AuthController>() &&
          !Get.find<AuthController>().isRestrictedRole;

      final Widget createDocButton = ElevatedButton.icon(
        onPressed: () => showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.45),
          builder: (_) => const CreateDocumentDialog(),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Create Document'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2083D5),
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      if (compact) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: AppTheme.bgDark,
            border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (screenWidth < 800) menuButton,
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.heading2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  bell,
                ],
              ),
              if (showCreateDoc) ...[
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: createDocButton),
              ],
              if (showSearch) ...[
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: searchWidget),
              ],
            ],
          ),
        );
      }

      return Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: screenWidth < 1100 ? 20 : 28),
        decoration: const BoxDecoration(
          color: AppTheme.bgDark,
          border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: Row(
          children: [
            if (screenWidth < 800) menuButton,
            Text(title, style: AppTheme.heading2),
            const Spacer(),

            if (showCreateDoc) ...[
              createDocButton,
              const SizedBox(width: 12),
            ],

            if (showSearch)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.4),
                child: searchWidget,
              ),
            const SizedBox(width: 16),
            bell,
          ],
        ),
      );
    });
  }
}