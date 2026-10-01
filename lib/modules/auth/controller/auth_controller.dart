import 'dart:async';
import 'package:get/get.dart';
import 'package:agremate_admin/routes/app_routes.dart';

import '../model/model.dart';
import 'auth_service.dart';

class AuthController extends GetxController {
  final AuthService _service = AuthService();

  static const int phoneLength = 10;
  static const int otpLength = 4;
  static const int otpTimeoutSeconds = 120;
  static const String countryCode = '+91';

  final accessToken = ''.obs;
  final idToken = ''.obs;
  final refreshToken = ''.obs;
  final userId = ''.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final role = ''.obs;

  String get _normalizedRole =>
      role.value.replaceAll(' ', '').replaceAll('-', '').replaceAll('_', '').toLowerCase();

  bool get isSuperAdmin =>
      _normalizedRole == 'superadmin' || _normalizedRole.contains('superadmin');
  bool get isLandlord => _normalizedRole == 'landlord';
  bool get isTenant => _normalizedRole == 'tenant';
  bool get isRestrictedRole => isLandlord || isTenant;

  final phoneNumber = ''.obs;
  final session = ''.obs;
  final isOtpSent = false.obs;
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final errorMessage = ''.obs;
  final phoneError = ''.obs;
  final otpError = ''.obs;
  final secondsRemaining = 0.obs;

  AccessCheckResult? _pendingAccess;

  Timer? _timer;
  String get headingText => isOtpSent.value ? 'Verify OTP' : 'Login';

  String get subtitleText => isOtpSent.value
      ? 'Enter the $otpLength-digit code sent to ${phoneNumber.value}'
      : 'Enter your phone number to continue';

  String get otpHint => 'Enter $otpLength-digit OTP';

  String get resendLabel => secondsRemaining.value > 0
      ? 'Resend OTP in ${formatTime(secondsRemaining.value)}'
      : 'Resend OTP';

  bool get canResend => !isLoading.value && secondsRemaining.value == 0;

  String? get phoneErrorText =>
      phoneError.value.isEmpty ? null : phoneError.value;

  String? get otpErrorText => otpError.value.isEmpty ? null : otpError.value;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void onPhoneChanged(String _) {
    if (phoneError.value.isNotEmpty) phoneError.value = '';
  }

  void onOtpChanged(String _) {
    if (otpError.value.isNotEmpty) otpError.value = '';
  }

  void _startTimer() {
    _timer?.cancel();
    secondsRemaining.value = otpTimeoutSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        t.cancel();
      }
    });
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> onSendOtpPressed(String phone) async {
    phoneError.value = '';
    errorMessage.value = '';

    phone = phone.trim();
    if (phone.isEmpty) {
      phoneError.value = 'Phone number is required.';
      return;
    }
    if (phone.length != phoneLength) {
      phoneError.value = 'Phone number must be exactly $phoneLength digits.';
      return;
    }

    isLoading.value = true;
    try {
      final fullPhone = '$countryCode$phone';
      final access = await _service.checkAccess(fullPhone);
      final result = access.data;
      final roleOk = result != null && _isAllowedDashboardRole(result.role);

      if (!access.status || result == null || result.canAccess != true || !roleOk) {
        errorMessage.value = access.message.isNotEmpty
            ? access.message
            : 'This phone number is not authorized as Super Admin, Landlord, or Tenant.';
        return;
      }

      _pendingAccess = result;
      _applyAccess(result);
      await _sendOtp(fullPhone);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onResendOtpPressed() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _sendOtp(phoneNumber.value);
    } finally {
      isLoading.value = false;
    }
  }

  void onChangeNumberPressed() {
    isOtpSent.value = false;
    phoneError.value = '';
    otpError.value = '';
    errorMessage.value = '';
    _timer?.cancel();
    secondsRemaining.value = 0;
    session.value = '';
    _pendingAccess = null;
  }

  Future<void> onVerifyOtpPressed(String otp) async {
    otpError.value = '';
    errorMessage.value = '';

    otp = otp.trim();
    if (otp.isEmpty) {
      otpError.value = 'OTP is required.';
      return;
    }
    if (otp.length != otpLength) {
      otpError.value = 'Verification code must be $otpLength digits.';
      return;
    }
    if (secondsRemaining.value <= 0) {
      otpError.value = 'Invalid OTP. Code has expired.';
      return;
    }

    isLoading.value = true;
    try {
      final res =
      await _service.confirmOtp(phoneNumber.value, otp, session.value);
      final authSession = res.data;
      if (!res.status || authSession == null || !authSession.isSuccess) {
        errorMessage.value =
        res.message.isNotEmpty ? res.message : 'OTP verification failed';
        return;
      }

      _applySession(authSession);
      if (_pendingAccess != null) {
        _applyAccess(_pendingAccess!);
      }

      isLoggedIn.value = true;
      Get.offAllNamed(AppRoutes.dashboard);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _clearSession();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> _sendOtp(String fullPhone) async {
    final res = await _service.sendOtp(fullPhone);
    if (res.status) {
      phoneNumber.value = fullPhone;
      session.value = res.data ?? '';
      isOtpSent.value = true;
      _startTimer();
    } else {
      errorMessage.value =
      res.message.isNotEmpty ? res.message : 'Failed to send OTP';
    }
  }

  bool _isAllowedDashboardRole(String role) {
    final normalized = role
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('_', '')
        .toLowerCase();
    return normalized == 'superadmin' ||
        normalized.contains('superadmin') ||
        normalized == 'landlord' ||
        normalized == 'tenant';
  }

  void _applySession(AuthSession authSession) {
    accessToken.value = authSession.accessToken;
    idToken.value = authSession.idToken;
    refreshToken.value = authSession.refreshToken;
    _service.setAuthToken(authSession.tokenType, authSession.accessToken);

    final user = authSession.userInfo;
    if (user != null) {
      userId.value = user.id;
      userName.value = user.fullName;
      userEmail.value = user.email;
      userPhone.value = user.phoneNumber;
      if (user.role.isNotEmpty) role.value = user.role;
    }
  }

  void _applyAccess(AccessCheckResult access) {
    if (access.role.isNotEmpty) role.value = access.role;
    if (access.userId.isNotEmpty) userId.value = access.userId;
    if (access.fullName.isNotEmpty) userName.value = access.fullName;
    if (access.email.isNotEmpty) userEmail.value = access.email;
    if (access.phoneNumber.isNotEmpty) userPhone.value = access.phoneNumber;
  }

  void _clearSession() {
    _timer?.cancel();
    secondsRemaining.value = 0;
    isLoggedIn.value = false;
    isOtpSent.value = false;
    session.value = '';
    phoneNumber.value = '';
    accessToken.value = '';
    idToken.value = '';
    refreshToken.value = '';
    userId.value = '';
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
    role.value = '';
    _pendingAccess = null;
    _service.clearAuthToken();
  }
}