import 'package:get/get.dart';
import 'package:agremate_admin/routes/app_routes.dart';

class AuthController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final errorMessage = ''.obs;

  void login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }
    errorMessage.value = '';
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;
    isLoggedIn.value = true;
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void logout() {
    isLoggedIn.value = false;
    email.value = '';
    password.value = '';
    Get.offAllNamed(AppRoutes.login);
  }
}
