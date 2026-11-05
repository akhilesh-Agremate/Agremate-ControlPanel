import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/admin_control/controller/admin_control_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class AdminControlView extends StatelessWidget {
  const AdminControlView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminControlController>();

    return ColoredBox(
      color: AppColors.scaffoldLight,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 600
              ? 14
              : (MediaQuery.sizeOf(context).width < 850 ? 20 : 28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.adminControl, style: AppTheme.heading2),
            const SizedBox(height: 4),
            Text(
              AppStrings.adminControlSubtitle,
              style: AppTheme.caption,
            ),
            const SizedBox(height: 28),
            Text(AppStrings.tenantVisibilitySettings, style: AppTheme.heading3),
            const SizedBox(height: 16),
            Obx(() => _SettingCard(
              title: AppStrings.landlordContactMask,
              description: AppStrings.landlordContactMaskDescription,
              icon: Icons.contacts_outlined,
              iconColor: AppColors.primaryBlue,
              isEnabled: controller.isContactMaskEnabled.value,
              onToggle: controller.toggleContactMask,
            )),
          ],
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isEnabled;
  final void Function(bool) onToggle;

  const _SettingCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < 600;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnabled
              ? AppColors.primaryBlue.withValues(alpha: 0.3)
              : AppColors.borderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(phone ? 16 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: phone ? 12 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTheme.caption.copyWith(
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppTheme.textMuted.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEnabled ? AppStrings.enabled : AppStrings.disabled,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isEnabled
                          ? AppColors.success
                          : AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: phone ? 8 : 16),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeThumbColor: AppColors.primaryBlue,
            activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.25),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.textMuted.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}