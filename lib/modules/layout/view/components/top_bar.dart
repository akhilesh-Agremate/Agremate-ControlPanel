import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/constants/constants.dart';
import 'package:agremate_admin/core/widgets/search_field.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final nav = Get.find<NavigationController>();

  void _showOverlay() {
    _hideOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 320,
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
      ),
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
    // Hide overlay when search results change
    ever(nav.searchResults, (results) {
      if (results.isNotEmpty && _overlayEntry == null) {
        _showOverlay();
      } else if (results.isEmpty && _overlayEntry != null) {
        _hideOverlay();
      }
    });
    // Hide overlay when a property card is tapped (selectedProperty changes)
    ever(Get.find<PropertyController>().selectedProperty, (_) {
      if (_overlayEntry != null) {
        nav.searchResults.clear();
        nav.searchQuery.value = '';
        _hideOverlay();
      }
    });
    // Hide overlay when tab changes
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
      
      String title = 'Dashboard';
      try {
        final item = AppConstants.navItems.firstWhere((element) => element['index'] == index);
        title = item['label'] as String;
        if (title == 'User') title = 'User Management';
        if (title == 'My Account') title = 'My Account';
      } catch (e) {
        title = 'Agremate Admin';
      }

      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: const BoxDecoration(
          color: AppTheme.bgDark,
          border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: Row(
          children: [
            Text(title, style: AppTheme.heading2),
            const Spacer(),
            if (showSearch)
              CompositedTransformTarget(
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
              ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.notifications_outlined, color: AppTheme.textMuted, size: 20),
            ),
          ],
        ),
      );
    });
  }
}
