import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'components/sidebar.dart';
import 'components/top_bar.dart';
import 'package:agremate_admin/modules/home/view/home_view.dart';
import 'package:agremate_admin/modules/property/view/property_view.dart';
import 'package:agremate_admin/modules/services/view/services_view.dart';
import 'package:agremate_admin/modules/finance/view/finance_view.dart';
import 'package:agremate_admin/modules/documents/view/documents_view.dart';
import 'package:agremate_admin/modules/support/view/support_view.dart';
import 'package:agremate_admin/modules/user/view/user_view.dart';
import 'package:agremate_admin/modules/account/view/account_view.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavigationController>();
    final pages = [
      const HomeView(),
      const PropertyView(),
      const ServicesView(),
      const FinanceView(),
      const DocumentsView(),
      const SupportView(),
      const UserView(),
      const AccountView(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(
                  child: Obx(() {
                    final index = nav.currentIndex.value;
                    // Safety check to prevent RangeError
                    if (index >= pages.length) {
                      return const Center(child: Text('Page not found'));
                    }
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(index),
                        child: pages[index],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
