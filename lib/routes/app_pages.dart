import 'package:get/get.dart';
import 'package:agremate_admin/modules/auth/binding/auth_binding.dart';
import 'package:agremate_admin/modules/auth/view/login_view.dart';
import 'package:agremate_admin/modules/dashboard/binding/dashboard_binding.dart';
import 'package:agremate_admin/modules/dashboard/view/dashboard_view.dart';

import 'app_routes.dart';

class AppPages {
  static List<GetPage> get pages => [
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: AppRoutes.dashboard,
          page: () => const DashboardView(),
          binding: DashboardBinding(),
        ),
      ];
}

