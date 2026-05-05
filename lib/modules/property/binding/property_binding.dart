import 'package:get/get.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/property/repository/property_repository.dart';

class PropertyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PropertyRepository>(() => PropertyRepository());
    Get.lazyPut<PropertyController>(() => PropertyController(Get.find<PropertyRepository>()));
  }
}
