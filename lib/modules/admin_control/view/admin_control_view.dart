import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/admin_control/controller/admin_control_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';

class AdminControlView extends StatelessWidget {
  const AdminControlView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminControlController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadLandlordContactAccess();
    });

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
            const SizedBox(height: 28),
            Text('Article', style: AppTheme.heading3),
            const SizedBox(height: 16),
            const _ArticleCard(),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard();

  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < 600;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.brandPaleSky,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.article_outlined,
                color: AppTheme.brandSteelBlue, size: 24),
          ),
          SizedBox(width: phone ? 12 : 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Add an article or manage who can access it.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: phone ? 8 : 16),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _CreateArticleDialog(),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.brandSteelBlue,
                foregroundColor: AppTheme.brandWhite,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _PermissionDialog(),
              ),
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
              label: const Text('Permission'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.brandSteelBlue,
                side: const BorderSide(color: AppTheme.brandSteelBlue),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateArticleDialog extends StatefulWidget {
  const _CreateArticleDialog();

  @override
  State<_CreateArticleDialog> createState() => _CreateArticleDialogState();
}

class _CreateArticleDialogState extends State<_CreateArticleDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();
  final _sourceNameController = TextEditingController();
  final _sourceLogoUrlController = TextEditingController();

  bool trending = false;
  bool verified = false;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isSubmitting = false;

  bool get _canPublish =>
      _titleController.text.trim().isNotEmpty &&
          _descriptionController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onChanged);
    _descriptionController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onChanged);
    _descriptionController.removeListener(_onChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _sourceNameController.dispose();
    _sourceLogoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return;
      final file = files.first;
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
      });
    } catch (e) {
      AppToast.error('Failed to pick image: $e');
    }
  }

  Future<void> _publishPost() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      AppToast.error('Please enter post title');
      return;
    }
    if (description.isEmpty) {
      AppToast.error('Please enter post description');
      return;
    }

    setState(() => _isSubmitting = true);
    final controller = Get.find<AdminControlController>();
    final ok = await controller.createArticle(
      title: title,
      description: description,
      category: _categoryController.text.trim(),
      tags: _tagsController.text.trim(),
      sourceName: _sourceNameController.text.trim(),
      sourceLogoUrl: _sourceLogoUrlController.text.trim(),
      isTrending: trending,
      isSourceVerified: verified,
      imageBytes: _imageBytes,
      imageName: _imageName,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) {
      Navigator.pop(context);
    }
  }

  InputDecoration _field(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hintGrey, fontSize: 14),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      );

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorderBlue),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final details = _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Post Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label('Post Title', required: true),
          TextField(
            controller: _titleController,
            decoration: _field('Enter a compelling title for your post'),
          ),
          const SizedBox(height: 16),
          _label('Description', required: true),
          TextField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 5,
            decoration: _field(
              "What's on your mind? Share your thoughts, updates, or ask questions...",
            ),
          ),
        ],
      ),
    );
    final photo = _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add a photo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (_imageBytes != null)
                TextButton.icon(
                  onPressed: () => setState(() {
                    _imageBytes = null;
                    _imageName = null;
                  }),
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                  label: const Text('Remove', style: TextStyle(color: AppColors.error, fontSize: 13)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _imageBytes != null ? AppColors.primaryBlue : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        _imageBytes!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.primaryBlue, size: 28),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Click to upload photo',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
    final tags = _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sell_outlined, color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Category & Tags',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label('Category (Optional)'),
          TextField(
            controller: _categoryController,
            decoration: _field('e.g. Vegetables, Fruits, Dairy, Farming ...'),
          ),
          const SizedBox(height: 14),
          _label('Tags / Hashtags (Optional)'),
          TextField(
            controller: _tagsController,
            decoration: _field('Add tags to your post...'),
          ),
          const SizedBox(height: 14),
          _label('Source Name (Optional)'),
          TextField(
            controller: _sourceNameController,
            decoration: _field('e.g. Agremate News'),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mark as Trending'),
            value: trending,
            activeThumbColor: AppColors.primaryBlue,
            onChanged: (v) => setState(() => trending = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Verified Source'),
            value: verified,
            activeThumbColor: AppColors.primaryBlue,
            onChanged: (v) => setState(() => verified = v),
          ),
        ],
      ),
    );

    return Dialog(
      backgroundColor: const Color(0xFFF4F7FB),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Create Post',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Share your thoughts with the community',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  photo,
                                  const SizedBox(height: 16),
                                  details,
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: tags),
                          ],
                        )
                      : Column(
                          children: [
                            photo,
                            const SizedBox(height: 16),
                            details,
                            const SizedBox(height: 16),
                            tags,
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_canPublish && !_isSubmitting) ? _publishPost : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        _isSubmitting ? AppColors.primaryBlue : const Color(0xFFD9DEE8),
                        disabledForegroundColor:
                        _isSubmitting ? Colors.white : AppColors.textGrey,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Publish Post',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
  }
}

class _PermissionDialog extends StatefulWidget {
  const _PermissionDialog();

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog> {
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;
  bool _grant = true;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _phoneOrNull() {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('+')) {
      final clean = '+${raw.substring(1).replaceAll(RegExp(r'\D'), '')}';
      if (clean.length >= 8) return clean;
    }
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+91$digits';
    if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
    if (digits.length >= 8) return '+$digits';
    return null;
  }

  Future<void> _onToggle(bool value) async {
    final phone = _phoneOrNull();
    if (phone == null) {
      AppToast.error('Please enter a valid phone number');
      return;
    }
    final previous = _grant;
    setState(() => _grant = value);
    final ok = await Get.find<AdminControlController>().grantArticleAccess(
      phoneNumber: phone,
      grant: value,
    );
    if (!mounted) return;
    if (!ok) setState(() => _grant = previous);
  }

  Future<void> _submit() async {
    final phone = _phoneOrNull();
    if (phone == null) {
      AppToast.error('Please enter a valid phone number');
      return;
    }

    setState(() => _isSubmitting = true);
    final controller = Get.find<AdminControlController>();
    final ok = await controller.grantArticleAccess(
      phoneNumber: phone,
      grant: _grant,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration field(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hintGrey, fontSize: 14),
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
        );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Permission',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose who should be granted permission.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              const SizedBox(height: 14),
              const Text('Phone number',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: field('Enter phone number'),
                onSubmitted: (_) => _isSubmitting ? null : _submit(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Grant Permission',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: _grant,
                      onChanged: _isSubmitting ? null : _onToggle,
                      activeThumbColor: AppColors.primaryBlue,
                      activeTrackColor:
                          AppColors.primaryBlue.withValues(alpha: 0.25),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('No'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Yes'),
                  ),
                ],
              ),
            ],
          ),
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