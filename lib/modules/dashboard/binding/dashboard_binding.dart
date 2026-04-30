import 'package:get/get.dart';
import 'package:agremate_admin/modules/auth/binding/auth_binding.dart';
import 'package:agremate_admin/modules/layout/binding/layout_binding.dart';
import 'package:agremate_admin/modules/home/binding/home_binding.dart';
import 'package:agremate_admin/modules/property/binding/property_binding.dart';
import 'package:agremate_admin/modules/services/binding/services_binding.dart';
import 'package:agremate_admin/modules/finance/binding/finance_binding.dart';
import 'package:agremate_admin/modules/documents/binding/documents_binding.dart';
import 'package:agremate_admin/modules/support/binding/support_binding.dart';
import 'package:agremate_admin/modules/account/binding/account_binding.dart';
import 'package:agremate_admin/modules/user/binding/user_binding.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure auth exists for Sidebar logout logic.
    AuthBinding().dependencies();

    LayoutBinding().dependencies();
    HomeBinding().dependencies();
    PropertyBinding().dependencies();
    ServicesBinding().dependencies();
    FinanceBinding().dependencies();
    DocumentsBinding().dependencies();
    SupportBinding().dependencies();
    AccountBinding().dependencies();
    UserBinding().dependencies();
  }
}

