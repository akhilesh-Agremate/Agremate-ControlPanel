import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/account/repository/account_repository.dart';
import '../../auth/controller/auth_controller.dart';
import '../model/account_model.dart';

class AccountController extends GetxController {
  AccountController();

  final AuthController _auth = Get.find<AuthController>();
  final AccountRepository _repo = AccountRepository();
  final user = Rxn<AccountModel>();

  final isEditing = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final emailPhoneError = Rxn<String>();
  final passwordError = Rxn<String>();
  final roleError = Rxn<String>();

  Worker? _authWorker;
  bool _syncScheduled = false;

  @override
  void onInit() {
    super.onInit();
    _syncWithAuth();
    _authWorker = everAll(
      [
        _auth.isLoggedIn,
        _auth.userId,
        _auth.userName,
        _auth.userEmail,
        _auth.userPhone,
        _auth.role,
      ],
          (_) => _scheduleSync(),
    );
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    super.onClose();
  }

  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    Future.microtask(() {
      _syncScheduled = false;
      _syncWithAuth();
    });
  }

  void _syncWithAuth() {
    if (!_auth.isLoggedIn.value) {
      user.value = null;
      isEditing.value = false;
      errorMessage.value = '';
      clearRegisterErrors();
      return;
    }

    final previous = user.value;
    final sameUser = previous != null && previous.id == _auth.userId.value;

    user.value = AccountModel(
      id: _auth.userId.value,
      name: _auth.userName.value.trim(),
      email: _auth.userEmail.value.trim(),
      phone: _auth.userPhone.value.trim(),
      role: _auth.roleLabel,
      createdAt: sameUser ? previous.createdAt : null,
    );
    _loadRemote();
  }

  Future<void> fetchProfile() => _loadRemote();

  Future<void> _loadRemote() async {
    final expectedId = _auth.userId.value;
    try {
      final remote = await _repo.getProfile();
      final current = user.value;
      if (current == null || !_auth.isLoggedIn.value) return;
      if (_auth.userId.value != expectedId) return;
      if (remote.id.isNotEmpty &&
          current.id.isNotEmpty &&
          remote.id != current.id) {
        return;
      }
      user.value = current.copyWith(
        name: remote.name.isNotEmpty ? remote.name : null,
        email: remote.email.isNotEmpty ? remote.email : null,
        phone: remote.phone.isNotEmpty ? remote.phone : null,
        createdAt: remote.createdAt,
      );
    } catch (_) {

    }
  }

  void toggleEdit() => isEditing.value = !isEditing.value;

  Future<void> updateProfile(String name, String email, String phone) async {
    try {
      errorMessage.value = '';
      isLoading.value = true;
      await _repo.updateProfile(name: name, email: email, phone: phone);
      _auth.userName.value = name;
      _auth.userEmail.value = email;
      _auth.userPhone.value = phone;
      isEditing.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _isValidPhone(String phone) => RegExp(r'^\d{10}$').hasMatch(phone);

  bool _isPasswordComplex(String pw) =>
      pw.contains(RegExp(r'[A-Z]')) &&
          pw.contains(RegExp(r'[a-z]')) &&
          pw.contains(RegExp(r'[0-9]')) &&
          pw.contains(RegExp(r'[@#$%&]'));

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
      await _repo.registerAccount(
        emailPhone: emailPhone,
        password: password,
        role: selectedRole!,
      );
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