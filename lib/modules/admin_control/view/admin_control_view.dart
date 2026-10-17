import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/admin_control/controller/admin_control_controller.dart';

class AdminControlView extends StatelessWidget {
  const AdminControlView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminControlController>();

    return ColoredBox(
      color: const Color(0xFFF8FAFD),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Control', style: AppTheme.heading2),
            const SizedBox(height: 4),
            Text(
              'Manage platform-level settings and configurations.',
              style: AppTheme.caption,
            ),
            const SizedBox(height: 28),
            Text('Tenant Visibility Settings', style: AppTheme.heading3),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD6E8FA),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2F6BFF)),
                    ),
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444), size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: controller.fetchLandlordContactAccess,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F6BFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return _SettingCard(
                title: 'Landlord Contact Mask',
                description:
                    'When enabled, tenant users will not see the landlord\'s contact details (phone number and email). Their information will be hidden across the platform.',
                icon: Icons.contacts_outlined,
                iconColor: const Color(0xFF2F6BFF),
                isEnabled: controller.isContactMaskEnabled.value,
                onToggle: controller.toggleContactMask,
              );
            }),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnabled
              ? const Color(0xFF2F6BFF).withValues(alpha: 0.3)
              : const Color(0xFFD6E8FA),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
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
          const SizedBox(width: 20),
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
                        ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                        : AppTheme.textMuted.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEnabled ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isEnabled
                          ? const Color(0xFF22C55E)
                          : AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeThumbColor: const Color(0xFF2F6BFF),
            activeTrackColor: const Color(0xFF2F6BFF).withValues(alpha: 0.25),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.textMuted.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}
