import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/account/controller/account_controller.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../layout/view/components/app_footer.dart';
import '../model/account_model.dart';
import '../model/role_model.dart';

String _na(String v) => v.trim().isEmpty ? AppStrings.notAvailable : v.trim();

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = Get.find<AccountController>();
    final auth = Get.find<AuthController>();

    return Obx(() {

      final user = ac.user.value;
      if (user == null) return const SizedBox.shrink();
      final editing = ac.isEditing.value;

      return SingleChildScrollView(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 600
              ? 14
              : (MediaQuery.sizeOf(context).width < 850 ? 20 : 28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileBanner(
              user: user,
              isEditing: editing,
              onToggleEdit: ac.toggleEdit,
            ),
            const SizedBox(height: 24),
            if (editing) _EditForm(ac: ac) else _ProfileDetails(user: user),
            if (auth.isSuperAdmin) ...[
              const SizedBox(height: 32),
              const _RegisterNewAccount(),
            ],
            const SizedBox(height: 24),
            _LogoutCard(onTap: () => _showLogoutDialog(context, auth)),
            const SizedBox(height: 24),
            const AppFooter(),
          ],
        ),
      );
    });
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
              AppStrings.logout,
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: const Text(
              AppStrings.logoutConfirmation,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  AppStrings.cancel,
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
                  AppStrings.logout,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

const _cardBorder = Color(0xFFD6E6FA);

BoxDecoration _whiteCard({Color border = _cardBorder}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: border),
);

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      runSpacing: 8,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Account', style: AppTheme.heading1.copyWith(fontSize: 26)),
            const SizedBox(height: 4),
            Text('Manage your profile and account details',
                style: AppTheme.caption),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_outlined,
                size: 18, color: AppTheme.accentBlue),
            const SizedBox(width: 8),
            Text('Dashboard', style: AppTheme.caption),
            const SizedBox(width: 6),
            Text('>', style: AppTheme.caption),
            const SizedBox(width: 6),
            Text('My Account',
                style: AppTheme.caption
                    .copyWith(color: AppTheme.accentBlue)),
          ],
        ),
      ],
    );
  }
}

/// Light-blue banner with avatar, name, role chip and edit button.
class _ProfileBanner extends StatelessWidget {
  final AccountModel user;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  const _ProfileBanner({
    required this.user,
    required this.isEditing,
    required this.onToggleEdit,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.all(phone ? 16 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFEAF3FF), Color(0xFFF4F8FF)],
        ),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final narrow = c.maxWidth < 560;

        final avatar = Container(
          width: narrow ? 64 : 80,
          height: narrow ? 64 : 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD3E6FB),
            border: Border.all(
                color: AppTheme.accentBlue.withValues(alpha: 0.35), width: 2),
          ),
          child: Icon(Icons.person_rounded,
              color: AppTheme.accentBlue, size: narrow ? 32 : 40),
        );

        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_na(user.name),
                style: AppTheme.heading1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_rounded,
                      size: 14, color: AppTheme.accentBlue),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _na(user.role),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final button = ElevatedButton.icon(
          onPressed: onToggleEdit,
          icon: Icon(isEditing ? Icons.close : Icons.edit, size: 16),
          label: Text(isEditing ? AppStrings.cancel : AppStrings.editProfile),
          style: ElevatedButton.styleFrom(
            backgroundColor:
            isEditing ? AppTheme.accentRed : AppTheme.accentBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );

        if (narrow) {
          return Column(
            children: [
              Row(children: [
                avatar,
                const SizedBox(width: 16),
                Expanded(child: info),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: button),
            ],
          );
        }

        return Row(children: [
          avatar,
          const SizedBox(width: 24),
          Expanded(child: info),
          const SizedBox(width: 16),
          button,
        ]);
      }),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final AccountModel user;
  const _ProfileDetails({required this.user});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _InfoTile(
        icon: Icons.email_rounded,
        label: AppStrings.email,
        value: _na(user.email),
        color: AppTheme.accentBlue,
      ),
      _InfoTile(
        icon: Icons.phone_rounded,
        label: AppStrings.phone,
        value: _na(user.phone),
        color: AppTheme.accentGreen,
      ),
      _InfoTile(
        icon: Icons.manage_accounts_rounded,
        label: AppStrings.role,
        value: _na(user.role),
        color: AppTheme.accentPurple,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentBlue.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.person_rounded,
                    size: 18, color: AppTheme.accentBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Information',
                        style: AppTheme.heading3.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Your registered details and contact information',
                        style: AppTheme.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, c) {
            if (c.maxWidth >= 760) {
              return Row(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: tiles[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  tiles[i],
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.caption),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.heading3.copyWith(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutCard({required this.onTap});

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.25)),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final narrow = c.maxWidth < 520;

        final icon = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.logout_rounded,
              color: AppTheme.accentRed, size: 24),
        );

        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.logout,
                style: AppTheme.heading3
                    .copyWith(color: AppTheme.accentRed, fontSize: 16)),
            const SizedBox(height: 2),
            Text(AppStrings.logoutSubtitle, style: AppTheme.caption),
          ],
        );

        final button = OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text(AppStrings.logout),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.accentRed,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppTheme.accentRed),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );

        if (narrow) {
          return Column(
            children: [
              Row(children: [
                icon,
                const SizedBox(width: 16),
                Expanded(child: text),
              ]),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: button),
            ],
          );
        }

        return Row(children: [
          icon,
          const SizedBox(width: 16),
          Expanded(child: text),
          const SizedBox(width: 12),
          button,
        ]);
      }),
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
    nameC = TextEditingController(text: widget.ac.user.value?.name ?? '');
    emailC = TextEditingController(text: widget.ac.user.value?.email ?? '');
    phoneC = TextEditingController(text: widget.ac.user.value?.phone ?? '');
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
          Text(AppStrings.editProfile, style: AppTheme.heading3),
          const SizedBox(height: 20),
          TextField(
            controller: nameC,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: AppStrings.fullName),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emailC,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: AppStrings.email),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneC,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: AppStrings.phone),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () => widget.ac.updateProfile(
                  nameC.text,
                  emailC.text,
                  phoneC.text,
                ),
            child: const Text(AppStrings.saveChanges),
          ),
        ],
      ),
    );
  }
}

class _RegisterNewAccount extends StatefulWidget {
  const _RegisterNewAccount();

  @override
  State<_RegisterNewAccount> createState() => _RegisterNewAccountState();
}

class _RegisterNewAccountState extends State<_RegisterNewAccount> {
  final _phoneController = TextEditingController();
  final _roleDropdownController = TextEditingController();
  RoleModel? _selectedRole;

  String? _phoneError;
  String? _roleError;

  @override
  void initState() {
    super.initState();
    final ac = Get.find<AccountController>();
    if (ac.roles.isEmpty && !ac.isLoadingRoles.value) {
      ac.fetchRoles();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _roleDropdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ac = Get.find<AccountController>();

    return GlassCard(
      glowColor: AppTheme.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.registerNewAccount, style: AppTheme.heading2),
          const SizedBox(height: 24),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: AppStrings.phoneNumber,
              prefixText: AppStrings.phonePrefix,
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) {
              if (_phoneError != null) setState(() => _phoneError = null);
            },
          ),
          if (_phoneError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                _phoneError!,
                style: const TextStyle(color: AppTheme.accentRed, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          Obx(() {
            final isLoading = ac.isLoadingRoles.value;
            final roles = ac.roles;
            final rolesError = ac.rolesError.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<RoleModel>(
                      controller: _roleDropdownController,
                      width: constraints.maxWidth,
                      initialSelection: _selectedRole,
                      hintText: isLoading ? AppStrings.loadingRoles : AppStrings.selectRole,
                      enabled: !isLoading,
                      textStyle: const TextStyle(color: AppTheme.textPrimary),
                      inputDecorationTheme: Theme.of(context)
                          .inputDecorationTheme
                          .copyWith(
                            filled: true,
                            fillColor: Colors.white,
                            suffixIconColor: AppTheme.textSecondary,
                          ),
                      menuStyle: const MenuStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          AppTheme.bgCard,
                        ),
                        elevation: WidgetStatePropertyAll(4.0),
                      ),
                      dropdownMenuEntries: roles.map((role) {
                        return DropdownMenuEntry<RoleModel>(
                          value: role,
                          label: role.name,
                          style: MenuItemButton.styleFrom(
                            foregroundColor: AppTheme.textPrimary,
                          ),
                        );
                      }).toList(),
                      onSelected: (val) {
                        setState(() {
                          _selectedRole = val;
                          if (val != null) {
                            _roleError = null;
                          }
                        });
                      },
                    );
                  },
                ),
                if (rolesError.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(AppStrings.failedToLoadRoles(rolesError),
                          style: const TextStyle(
                            color: AppTheme.accentRed,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: ac.fetchRoles,
                        child: const Text(AppStrings.retry, style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ],
            );
          }),
          if (_roleError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                _roleError!,
                style: const TextStyle(color: AppTheme.accentRed, fontSize: 12),
              ),
            ),
          const SizedBox(height: 24),
          Obx(() {
            final isCreating = ac.isCreatingUser.value;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCreating
                    ? null
                    : () async {
                        final phone = _phoneController.text.trim();
                        String? phoneErr;
                        String? roleErr;

                        if (phone.isEmpty) {
                          phoneErr = AppStrings.phoneRequired;
                        } else if (phone.length != 10) {
                          phoneErr = AppStrings.phoneInvalid;
                        }
                        if (_selectedRole == null) {
                          roleErr = AppStrings.roleRequired;
                        }

                        if (phoneErr != null || roleErr != null) {
                          setState(() {
                            _phoneError = phoneErr;
                            _roleError = roleErr;
                          });
                          return;
                        }

                        setState(() {
                          _phoneError = null;
                          _roleError = null;
                        });

                        final success = await ac.createUser(
                          phoneNumber: phone,
                          roleId: _selectedRole!.id,
                        );

                        if (success) {
                          _phoneController.clear();
                          _roleDropdownController.clear();
                          setState(() => _selectedRole = null);
                        }
                      },
                child: isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(AppStrings.register),
              ),
            );
          }),
        ],
      ),
    );
  }
}
