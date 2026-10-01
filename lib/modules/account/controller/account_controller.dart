import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/user/model/user_model.dart';

class AccountController extends GetxController {
  AccountController();

  final user = UserModel(
    id: 'SA1',
    name: 'Admin User',
    email: 'admin@agremate.com',
    phone: '+91 9876543210',
    role: 'Super Admin',
    createdAt: DateTime(2024, 1, 1),
  ).obs;

  final isEditing = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final emailPhoneError = Rxn<String>();
  final passwordError = Rxn<String>();
  final roleError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }
  Future<void> fetchProfile() async {
    try {
      errorMessage.value = '';
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 300));
      user.value = UserModel(
        id: 'SA1',
        name: 'Admin User',
        email: 'admin@agremate.com',
        phone: '+91 9876543210',
        role: 'Super Admin',
        createdAt: DateTime(2024, 1, 1),
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  void toggleEdit() => isEditing.value = !isEditing.value;

  Future<void> updateProfile(String name, String email, String phone) async {
    try {
      errorMessage.value = '';
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 300));
      user.value = user.value.copyWith(
        name: name,
        email: email,
        phone: phone,
      );
      isEditing.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  bool _isPasswordComplex(String pw) {
    final hasUpper = pw.contains(RegExp(r'[A-Z]'));
    final hasLower = pw.contains(RegExp(r'[a-z]'));
    final hasDigit = pw.contains(RegExp(r'[0-9]'));
    final hasSpecial = pw.contains(RegExp(r'[@#$%&]'));
    return hasUpper && hasLower && hasDigit && hasSpecial;
  }

  void clearRegisterErrors() {
    emailPhoneError.value = null;
    passwordError.value = null;
    roleError.value = null;
  }

  void clearEmailPhoneError() => emailPhoneError.value = null;
  void clearPasswordError() => passwordError.value = null;

  Future<bool> registerAccount({
    required String emailPhone,
    required String password,
    required String? selectedRole,
  }) async {
    clearRegisterErrors();
    bool hasError = false;

    if (emailPhone.isEmpty) {
      emailPhoneError.value = 'Phone number or Email is required.';
      hasError = true;
    } else if (!_isValidEmail(emailPhone) && !_isValidPhone(emailPhone)) {
      emailPhoneError.value = 'Enter a valid Email or 10-digit Phone number.';
      hasError = true;
    }

    if (password.isEmpty) {
      passwordError.value = 'Password is required.';
      hasError = true;
    } else if (password.length < 6 || !_isPasswordComplex(password)) {
      passwordError.value =
          r'Must be at least 6 chars and include uppercase, lowercase, number, and special char (@#$%&).';
      hasError = true;
    }

    if (selectedRole == null) {
      roleError.value = 'Please select a role.';
      hasError = true;
    }

    if (hasError) return false;

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        'Success',
        'Account registered successfully!',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }
}
