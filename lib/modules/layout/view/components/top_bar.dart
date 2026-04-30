import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/constants/constants.dart';
import 'package:agremate_admin/core/widgets/search_field.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavigationController>();
    
    return Obx(() {
      final index = nav.currentIndex.value;
      final showSearch = nav.showSearch;
      
      // Get title from AppConstants.navItems to be safe and dynamic
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
              SearchField(
                hint: 'Search ${title.toLowerCase()}...',
                onChanged: (q) => nav.searchQuery.value = q,
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
