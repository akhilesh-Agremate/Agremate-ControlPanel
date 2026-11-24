import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/app_colors.dart';
import 'package:agremate_admin/core/theme/theme.dart';

enum ToastType { success, error, warning }

class AppToast {
  static void show(
    String message, {
    ToastType type = ToastType.success,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final style = _styleFor(type);

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        maxWidth: 420,
        margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        backgroundColor: style.background,
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        animationDuration: const Duration(milliseconds: 300),
        isDismissible: true,
        messageText: Row(
          children: [
            Icon(style.icon, color: style.color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyText.copyWith(
                  color: style.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Get.closeCurrentSnackbar();
                  onAction?.call();
                },
                child: Text(
                  actionLabel,
                  style: AppTheme.caption.copyWith(
                    color: style.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
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

  static void success(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      show(
        message,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  static void error(String message) => show(message, type: ToastType.error);

  static void warning(String message) =>
      show(message, type: ToastType.warning);

  static _ToastStyle _styleFor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const _ToastStyle(
          color: Color(0xFF16A34A),
          background: Color(0xFFDCFCE7),
          icon: Icons.check_circle_rounded,
        );
      case ToastType.error:
        return const _ToastStyle(
          color: AppColors.error,
          background: Color(0xFFFEE2E2),
          icon: Icons.cancel_rounded,
        );
      case ToastType.warning:
        return const _ToastStyle(
          color: Color(0xFFEA580C),
          background: Color(0xFFFFEDD5),
          icon: Icons.warning_rounded,
        );
    }
  }
}

class _ToastStyle {
  const _ToastStyle({
    required this.color,
    required this.background,
    required this.icon,
  });

  final Color color;
  final Color background;
  final IconData icon;
}
