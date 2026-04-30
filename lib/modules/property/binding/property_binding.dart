import 'package:get/get.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';

class PropertyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PropertyController>(() => PropertyController());
  }
}

