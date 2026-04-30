import 'package:get/get.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';

class LayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
  }
}

