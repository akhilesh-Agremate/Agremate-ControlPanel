import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/account/controller/account_controller.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = Get.find<AccountController>();
    final auth = Get.find<AuthController>();

    return Obx(() {
      final user = ac.user.value;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            GlassCard(
              glowColor: AppTheme.accentGreen,
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.accentGreen.withValues(alpha: 0.3), AppTheme.accentCyan.withValues(alpha: 0.3)],
                      ),
                      border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.5), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, color: AppTheme.accentGreen, size: 40),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: AppTheme.heading1),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
                          ),
                          child: Text(user.role, style: const TextStyle(color: AppTheme.accentPurple, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        Text('Member since ${user.createdAt.year}', style: AppTheme.caption),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: ac.toggleEdit,
                    icon: Icon(ac.isEditing.value ? Icons.close : Icons.edit, size: 16),
                    label: Text(ac.isEditing.value ? 'Cancel' : 'Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ac.isEditing.value ? AppTheme.accentRed : AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Profile details or edit form
            if (ac.isEditing.value)
              _EditForm(ac: ac)
            else
              _ProfileDetails(user: user),

            const SizedBox(height: 32),

            // Logout
            GlassCard(
              glowColor: AppTheme.accentRed,
              onTap: () => _showLogoutDialog(context, auth),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded, color: AppTheme.accentRed, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Logout', style: AppTheme.heading3.copyWith(color: AppTheme.accentRed)),
                      Text('Sign out of your account', style: AppTheme.caption),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppTheme.accentRed),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showLogoutDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppTheme.textSecondary)),
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

class _ProfileDetails extends StatelessWidget {
  final dynamic user;
  const _ProfileDetails({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DetailRow(icon: Icons.email_rounded, label: 'Email', value: user.email, color: AppTheme.accentCyan),
        const SizedBox(height: 12),
        _DetailRow(icon: Icons.phone_rounded, label: 'Phone', value: user.phone, color: AppTheme.accentGreen),
        const SizedBox(height: 12),
        _DetailRow(icon: Icons.badge_rounded, label: 'Role', value: user.role, color: AppTheme.accentPurple),
        const SizedBox(height: 12),
        _DetailRow(icon: Icons.calendar_today_rounded, label: 'Joined', value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}', color: AppTheme.accentOrange),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Text(label, style: AppTheme.bodyText),
          const Spacer(),
          Text(value, style: AppTheme.heading3.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _EditForm extends StatefulWidget {
  final AccountController ac;
  const _EditForm({required this.ac});

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController phoneC;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.ac.user.value.name);
    emailC = TextEditingController(text: widget.ac.user.value.email);
    phoneC = TextEditingController(text: widget.ac.user.value.phone);
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: AppTheme.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Profile', style: AppTheme.heading3),
          const SizedBox(height: 20),
          TextField(controller: nameC, style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 16),
          TextField(controller: emailC, style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 16),
          TextField(controller: phoneC, style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => widget.ac.updateProfile(nameC.text, emailC.text, phoneC.text),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
