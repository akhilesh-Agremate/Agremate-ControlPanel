import 'package:get/get.dart';
import 'package:agremate_admin/modules/services/controller/services_controller.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServicesController>(() => ServicesController());
  }
}
