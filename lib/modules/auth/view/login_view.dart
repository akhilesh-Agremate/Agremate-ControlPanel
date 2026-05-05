import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;

  // Error states for validation
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validators ──────────────────────────────────────────────────────────
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isPasswordComplex(String pw) {
    final hasUpper = pw.contains(RegExp(r'[A-Z]'));
    final hasLower = pw.contains(RegExp(r'[a-z]'));
    final hasDigit = pw.contains(RegExp(r'[0-9]'));
    final hasSpecial = pw.contains(RegExp(r'[@#$%&]'));
    return hasUpper && hasLower && hasDigit && hasSpecial;
  }

  // ── Login handler ────────────────────────────────────────────────────────
  void _handleLogin() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool hasError = false;

    // Email validation
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required.');
      hasError = true;
    } else if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email address.');
      hasError = true;
    }

    // Password validation
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required.');
      hasError = true;
    } else if (password.length < 6 || !_isPasswordComplex(password)) {
      setState(() => _passwordError = 'Password must be at least 6 characters and include uppercase, lowercase, number, and special character (@#\$%&).');
      hasError = true;
    }

    if (hasError) return;

    // Proceed with login if no errors
    final auth = Get.find<AuthController>();
    auth.email.value = email;
    auth.password.value = password;
    auth.login();
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // ─── Left Side: Branding & Logo ──────────────────────
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

          // ─── Right Side: Login Form ─────────────────────────
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading
                            Text(
                              'Login',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                          'Enter your credentials to continue',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: const Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 32),

                        // ── Email ─────────────────────────────────
                        _label('Email'),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(
                              color: const Color(0xFF1E293B), fontSize: 14),
                          decoration: _inputDecor(
                            hint: 'Enter your email',
                            icon: Icons.email_outlined,
                            errorText: _emailError,
                          ),
                          onChanged: (val) {
                            if (_emailError != null) setState(() => _emailError = null);
                          },
                        ),

                        const SizedBox(height: 20),

                        // ── Password ──────────────────────────────
                        _label('Password'),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.inter(
                              color: const Color(0xFF1E293B), fontSize: 14),
                          decoration: _inputDecor(
                            hint: 'Enter your password',
                            icon: Icons.lock_outlined,
                            errorText: _passwordError,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          onChanged: (val) {
                            if (_passwordError != null) setState(() => _passwordError = null);
                          },
                        ),

                        // Controller error (from AuthController backend)
                        Obx(() {
                          final err = auth.errorMessage.value;
                          if (err.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Color(0xFFEF4444), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    err,
                                    style: GoogleFonts.inter(
                                        color: const Color(0xFFEF4444),
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 32),

                        // ── Login button ──────────────────────────
                        Obx(() {
                          final loading = auth.isLoading.value;
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: loading ? null : _handleLogin,
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
                                          strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : Text(
                                      'Login',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                            ),
                          );
                        }),
                          ],
                        ),
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

  // ── Helpers ──────────────────────────────────────────────────────────────
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
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4A90D9), size: 20),
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
