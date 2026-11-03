import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/constants/constants.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key,this.collapsed = false});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavigationController>();
    final auth = Get.find<AuthController>();
    return Container(
        color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 20),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
            ),
        child: collapsed
            ? Image.asset(
          'assets/images/agremate_icon.jpg',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_agremate.jpg',
              width: 170,
              fit: BoxFit.contain,
            ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12),
              children: [
                for (final item in AppConstants.navItems)
                  Obx(
                        () => _NavItem(
                          collapsed: collapsed,
                          icon: _outlinedIcon(item['label'] as String, item['icon'] as IconData),
                      label: item['label'] as String,
                      isActive: nav.currentIndex.value == item['index'],
                      onTap: () => nav.changePage(item['index'] as int),
                    ),
                  ),
                Obx(() {
                  if (!auth.isSuperAdmin) return const SizedBox.shrink();
                  return _NavItem(
                    collapsed: collapsed,
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
                    collapsed: collapsed,
                    icon: Icons.person_rounded,
                    label: 'My Account',
                    isActive: nav.currentIndex.value == 7,
                    onTap: () => nav.changePage(7),
                  ),
                ),
                Obx(
                  () => _NavItem(
                    collapsed: collapsed,
                    icon: Icons.support_agent_rounded,
                    label: 'Support',
                    isActive: nav.currentIndex.value == 5,
                    onTap: () => nav.changePage(5),
                  ),
                ),
                _NavItem(
                  collapsed: collapsed,
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
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 12,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 68,
                    width: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFE34D4D),
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Logout Confirmation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17243A),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Are you sure you want to log out?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFF718096),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFD94B4B),
                          size: 19,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'You will need to sign in again to access your account.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFA83C3C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF43536B),
                            side: const BorderSide(
                              color: Color(0xFFE1E6EF),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            auth.logout();
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 17,
                          ),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE34D4D),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isLogout;
  final bool collapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isLogout = false,
    required this.onTap,
    this.collapsed = false,
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

    final item = GestureDetector(
      onTap: () {
        if (widget.isLogout) {
          widget.onTap();
          return;
        }

        final scaffold = Scaffold.maybeOf(context);
        final drawerOpen =
            scaffold != null && scaffold.hasDrawer && scaffold.isDrawerOpen;

        widget.onTap();
        if (drawerOpen) Navigator.of(context).pop();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(
          horizontal: widget.collapsed ? 0 : 18,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: widget.isActive ? _blue : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: widget.isActive
              ? [BoxShadow(
            color: _blue.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )]
              : null,
        ),
        child: Row(
          mainAxisAlignment: widget.collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(widget.icon, color: fg, size: 20),
            if (!widget.collapsed) ...[
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return widget.collapsed
        ? Tooltip(message: widget.label, child: item)
        : item;
  }
}
