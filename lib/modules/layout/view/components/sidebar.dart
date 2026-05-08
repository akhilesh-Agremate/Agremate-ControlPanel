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
        gradient: AppTheme.sidebarGradient,
        border: Border(right: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4A90D9).withValues(alpha: 0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/agremate_logo.jpg',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AGREMATE', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: 2)),
                    Text('Super Admin', style: AppTheme.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppTheme.border.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: 12),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final item in AppConstants.navItems)
                  Obx(() => _NavItem(
                    icon: item['icon'] as IconData,
                    label: item['label'] as String,
                    isActive: nav.currentIndex.value == item['index'],
                    onTap: () => nav.changePage(item['index'] as int),
                  )),
              ],
            ),
          ),
          // Account & Logout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Obx(() => _NavItem(
                  icon: Icons.person_rounded,
                  label: 'My Account',
                  isActive: nav.currentIndex.value == 7,
                  onTap: () => nav.changePage(7),
                )),
                Obx(() => _NavItem(
                  icon: Icons.support_agent_rounded,
                  label: 'Support',
                  isActive: nav.currentIndex.value == 5,
                  onTap: () => nav.changePage(5),
                )),
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

  void _showLogoutDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: AppTheme.textPrimary), textAlign: TextAlign.center),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () { Navigator.pop(ctx); auth.logout(); },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
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

  const _NavItem({required this.icon, required this.label, required this.isActive, this.isLogout = false, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isLogout ? AppTheme.accentRed : (widget.isActive ? AppTheme.accentGreen : AppTheme.textMuted);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.white
                : (_hovering ? AppTheme.bgCardLight : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: widget.isActive
                ? Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.5), width: 1)
                : null,
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppTheme.accentBlue.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: color, size: 20),
              const SizedBox(width: 14),
              Expanded(child: Text(widget.label, style: TextStyle(color: widget.isActive ? AppTheme.textPrimary : color, fontSize: 14, fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400))),
              if (widget.isActive)
                Container(width: 6, height: 6, decoration: BoxDecoration(color: AppTheme.accentGreen, shape: BoxShape.circle)),
            ],
          ),
        ),
      ),
    );
  }
}
