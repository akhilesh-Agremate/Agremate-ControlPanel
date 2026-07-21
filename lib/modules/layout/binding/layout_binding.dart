import 'package:get/get.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/property/repository/property_repository.dart';
import 'package:agremate_admin/modules/services/controller/services_controller.dart';
import 'package:agremate_admin/modules/finance/controller/finance_controller.dart';
import 'package:agremate_admin/modules/documents/controller/document_controller.dart';
import 'package:agremate_admin/modules/support/controller/support_controller.dart';
import 'package:agremate_admin/modules/account/controller/account_controller.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';

class LayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<PropertyRepository>(() => PropertyRepository());
    Get.lazyPut<PropertyController>(
      () => PropertyController(Get.find<PropertyRepository>()),
    );
    Get.lazyPut<ServicesController>(() => ServicesController());
    Get.lazyPut<FinanceController>(() => FinanceController());
    Get.lazyPut<DocumentController>(() => DocumentController());
    Get.lazyPut<SupportController>(() => SupportController());
    Get.lazyPut<AccountController>(() => AccountController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
