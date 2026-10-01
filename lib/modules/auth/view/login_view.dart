import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 900)
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: Image.asset(
                  'assets/images/login_bg_v3.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 30,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        padding: const EdgeInsets.fromLTRB(26, 32, 26, 36),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 40,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Obx(() {
                          final isOtpSent = auth.isOtpSent.value;
                          final loading = auth.isLoading.value;
                          final errMsg = auth.errorMessage.value;
                          final phoneErr = auth.phoneError.value.isNotEmpty ? auth.phoneError.value : null;
                          final otpErr = auth.otpError.value.isNotEmpty ? auth.otpError.value : null;
                          final secondsRemaining = auth.secondsRemaining.value;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOtpSent ? 'Verify OTP' : 'Login',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isOtpSent
                                    ? 'Enter the ${AuthController.otpLength}-digit code sent to ${auth.phoneNumber.value}'
                                    : 'Enter your phone number to continue',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 32),

                              if (!isOtpSent) ...[
                                _label('Phone Number'),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF1E293B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: _inputDecor(
                                    hint: '',
                                    icon: Icons.phone_outlined,
                                    errorText: phoneErr,
                                    prefix: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 16),
                                        const Icon(Icons.phone_outlined, color: Color(0xFF4A90D9), size: 20),
                                        const SizedBox(width: 8),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 3),
                                          child: Text(
                                            '+91',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF1E293B),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 1),
                                      ],
                                    ),
                                  ),
                                  onChanged: (val) => auth.onPhoneChanged(val),
                                ),
                                const SizedBox(height: 32),

                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: loading
                                        ? null
                                        : () => auth.onSendOtpPressed(_phoneController.text.trim()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A90D9),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                      const Color(0xFF4A90D9).withValues(alpha: 0.6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: loading
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                        : Text(
                                      'Send OTP',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                _label('Verification Code'),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(AuthController.otpLength),
                                  ],
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF1E293B),
                                    fontSize: 14,
                                  ),
                                  decoration: _inputDecor(
                                    hint: 'Enter ${AuthController.otpLength}-digit OTP',
                                    icon: Icons.lock_outline,
                                    errorText: otpErr,
                                  ),
                                  onChanged: (val) => auth.onOtpChanged(val),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: loading || secondsRemaining > 0
                                          ? null
                                          : () => auth.onResendOtpPressed(),
                                      child: Text(
                                        secondsRemaining > 0
                                            ? 'Resend OTP in ${auth.formatTime(secondsRemaining)}'
                                            : 'Resend OTP',
                                        style: GoogleFonts.inter(
                                          color: secondsRemaining > 0
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF4A90D9),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: loading
                                          ? null
                                          : () {
                                        auth.onChangeNumberPressed();
                                        _otpController.clear();
                                      },
                                      child: Text(
                                        'Change Number',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: loading
                                        ? null
                                        : () => auth.onVerifyOtpPressed(_otpController.text.trim()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A90D9),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                      const Color(0xFF4A90D9).withValues(alpha: 0.6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: loading
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                        : Text(
                                      'Verify & Login',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              if (errMsg.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: Color(0xFFEF4444),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          errMsg,
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFFEF4444),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF374151),
    ),
  );

  InputDecoration _inputDecor({
    required String hint,
    required IconData icon,
    String? errorText,
    Widget? suffix,
    Widget? prefix,
    String? prefixText,
    TextStyle? prefixStyle,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
        GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: prefix ?? Icon(icon, color: const Color(0xFF4A90D9), size: 20),
        prefixText: prefixText,
        prefixStyle: prefixStyle,
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        errorText: errorText,
        errorStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFEF4444)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
      );
}