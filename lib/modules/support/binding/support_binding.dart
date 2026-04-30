import 'package:get/get.dart';
import 'package:agremate_admin/modules/support/controller/support_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(() => SupportController());
  }
}

