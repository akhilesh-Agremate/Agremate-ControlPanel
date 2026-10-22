import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/constants/constants.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavigationController>();
    final auth = Get.find<AuthController>();
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE3EEF9), width: 1)),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_agremate.jpg',
                  width: 170,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    auth.roleLabel,
                    style: AppTheme.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7B9CCB),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final item in AppConstants.navItems)
                  Obx(
                        () => _NavItem(
                      icon: _outlinedIcon(item['label'] as String, item['icon'] as IconData),
                      label: item['label'] as String,
                      isActive: nav.currentIndex.value == item['index'],
                      onTap: () => nav.changePage(item['index'] as int),
                    ),
                  ),
                Obx(() {
                  if (!auth.isSuperAdmin) return const SizedBox.shrink();
                  return _NavItem(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Control',
                    isActive: nav.currentIndex.value == 9,
                    onTap: () => nav.changePage(9),
                  );
                }),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Obx(
                  () => _NavItem(
                    icon: Icons.person_rounded,
                    label: 'My Account',
                    isActive: nav.currentIndex.value == 7,
                    onTap: () => nav.changePage(7),
                  ),
                ),
                Obx(
                  () => _NavItem(
                    icon: Icons.support_agent_rounded,
                    label: 'Support',
                    isActive: nav.currentIndex.value == 5,
                    onTap: () => nav.changePage(5),
                  ),
                ),
                _NavItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isActive: false,
                  isLogout: true,
                  onTap: () => _showLogoutDialog(context, auth),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _outlinedIcon(String label, IconData fallback) {
    switch (label) {
      case 'Home':
        return Icons.home_outlined;
      case 'Property':
        return Icons.apartment_outlined;
      case 'Services':
        return Icons.business_center_outlined;
      case 'Finance':
        return Icons.account_balance_wallet_outlined;
      case 'Documents':
        return Icons.folder_outlined;
      case 'User':
        return Icons.people_outline;
      default:
        return fallback;
    }
  }

  void _showLogoutDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  auth.logout();
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isLogout;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isLogout = false,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {

  static const _blue = Color(0xFF2F6BFF);
  static const _muted = Color(0xFF7B9CCB);

  @override
  Widget build(BuildContext context) {
    final Color fg = widget.isActive
        ? Colors.white
        : (widget.isLogout ? AppTheme.accentRed : _muted);

    return GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive ? _blue : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: widget.isActive
                ? [
              BoxShadow(
                color: _blue.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: fg, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
