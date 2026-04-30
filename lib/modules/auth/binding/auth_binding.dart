import 'package:get/get.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Keep auth alive across route changes (login -> dashboard -> logout -> login).
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}

