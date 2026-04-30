import 'package:get/get.dart';
import 'package:agremate_admin/modules/user/model/user_model.dart';

class AccountController extends GetxController {
  final user = UserModel(
    id: 'SA1',
    name: 'Admin User',
    email: 'admin@agremate.com',
    phone: '+91 9876543210',
    role: 'Super Admin',
    createdAt: DateTime(2024, 1, 1),
  ).obs;
  final isEditing = false.obs;

  void toggleEdit() => isEditing.value = !isEditing.value;

  void updateProfile(String name, String email, String phone) {
    user.value = user.value.copyWith(name: name, email: email, phone: phone);
    isEditing.value = false;
  }
}
