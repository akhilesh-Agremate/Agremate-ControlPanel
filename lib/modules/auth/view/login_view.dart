import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Background gradient circles
          Positioned(top: -100, left: -100, child: _glowCircle(300, AppTheme.accentGreen.withValues(alpha: 0.08))),
          Positioned(bottom: -150, right: -100, child: _glowCircle(400, AppTheme.accentPurple.withValues(alpha: 0.06))),
          Positioned(top: size.height * 0.3, right: size.width * 0.1, child: _glowCircle(200, AppTheme.accentCyan.withValues(alpha: 0.05))),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentGreen.withValues(alpha: 0.1),
                      border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.apartment_rounded, size: 48, color: AppTheme.accentGreen),
                  ),
                  const SizedBox(height: 20),
                  Text('AGREMATE', style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: 4)),
                  const SizedBox(height: 8),
                  Text('Super Admin Dashboard', style: AppTheme.bodyText),
                  const SizedBox(height: 40),
                  // Login card
                  Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    decoration: AppTheme.solidCardDecoration(glowColor: AppTheme.accentGreen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sign In', style: AppTheme.heading2),
                        const SizedBox(height: 6),
                        Text('Enter your credentials to continue', style: AppTheme.caption),
                        const SizedBox(height: 28),
                        Text('Email', style: AppTheme.heading3.copyWith(fontSize: 13)),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (v) => auth.email.value = v,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(hintText: 'admin@agremate.com', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20)),
                        ),
                        const SizedBox(height: 20),
                        Text('Password', style: AppTheme.heading3.copyWith(fontSize: 13)),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (v) => auth.password.value = v,
                          obscureText: true,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(hintText: '••••••••', prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.textMuted, size: 20)),
                        ),
                        Obx(() {
                          final error = auth.errorMessage.value;
                          if (error.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(error, style: const TextStyle(color: AppTheme.accentRed, fontSize: 13)),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        const SizedBox(height: 28),
                        Obx(() {
                          final loading = auth.isLoading.value;
                          return SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: loading ? null : auth.login,
                              child: loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bgDark))
                                : const Text('Sign In'),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
