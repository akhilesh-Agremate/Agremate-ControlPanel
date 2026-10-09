import 'package:get/get.dart';

class AdminControlController extends GetxController {
  final isContactMaskEnabled = false.obs;

  void toggleContactMask(bool value) {
    isContactMaskEnabled.value = value;
  }
}
