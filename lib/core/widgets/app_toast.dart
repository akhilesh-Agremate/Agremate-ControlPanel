import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ToastType { success, error, warning }

class AppToast {
  static void show(String message, {ToastType type = ToastType.success}) {
    final style = _styleFor(type);

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        maxWidth: 420,
        margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        backgroundColor: style.background,
        borderColor: style.color,
        borderWidth: 1.5,
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        animationDuration: const Duration(milliseconds: 300),
        boxShadows: [
          BoxShadow(
            color: style.color.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        messageText: Row(
          children: [
            Icon(style.icon, color: style.color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => Get.closeCurrentSnackbar(),
              child: Icon(Icons.close_rounded, color: style.color, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  static void success(String message) => show(message);
  static void error(String message) => show(message, type: ToastType.error);
  static void warning(String message) =>
      show(message, type: ToastType.warning);

  static _ToastStyle _styleFor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const _ToastStyle(
          color: Color(0xFF16A34A),
          background: Color(0xFFE8F8EE),
          textColor: Color(0xFF166534),
          icon: Icons.check_circle_rounded,
        );
      case ToastType.error:
        return const _ToastStyle(
          color: Color(0xFFDC2626),
          background: Color(0xFFFEECEC),
          textColor: Color(0xFF991B1B),
          icon: Icons.cancel_rounded,
        );
      case ToastType.warning:
        return const _ToastStyle(
          color: Color(0xFFF97316),
          background: Color(0xFFFFF1E6),
          textColor: Color(0xFF9A3412),
          icon: Icons.warning_rounded,
        );
    }
  }
}

class _ToastStyle {
  const _ToastStyle({
    required this.color,
    required this.background,
    required this.textColor,
    required this.icon,
  });

  final Color color;
  final Color background;
  final Color textColor;
  final IconData icon;
}