import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/theme/theme.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'modules/auth/controller/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final auth = Get.put(AuthController(), permanent: true);

  runApp(AgremateAdmin(
    initialRoute: auth.isLoggedIn.value ? AppRoutes.dashboard : AppRoutes.login,
  ));
}

class AgremateAdmin extends StatelessWidget {
  final String initialRoute;
  const AgremateAdmin({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Agremate Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
    );
  }
}
