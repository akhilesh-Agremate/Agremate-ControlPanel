import 'package:flutter/material.dart';
import 'package:agremate_admin/core/theme/theme.dart';

enum PropertyAddType { individual, pg }

Future<PropertyAddType?> showPropertyTypeDialog(BuildContext context) {
  return showDialog<PropertyAddType>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => const _PropertyTypeDialog(),
  );
}

class _PropertyTypeDialog extends StatelessWidget {
  const _PropertyTypeDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Add Property', style: AppTheme.heading2),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Choose the type of property you want to add.',
                  style: AppTheme.caption),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _TypeOption(
                      icon: Icons.home_rounded,
                      title: 'Individual',
                      description:
                      'Villa, flat or house rented to a single tenant.',
                      onTap: () => Navigator.of(context)
                          .pop(PropertyAddType.individual),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TypeOption(
                      icon: Icons.bed_rounded,
                      title: 'PG',
                      description:
                      'Paying guest with floors, rooms and beds.',
                      onTap: () =>
                          Navigator.of(context).pop(PropertyAddType.pg),
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

class _TypeOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_TypeOption> createState() => _TypeOptionState();
}

class _TypeOptionState extends State<_TypeOption> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2F6BFF);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 190,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovering ? const Color(0xFFEEF4FF) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovering ? blue : const Color(0xFFD6E8FA),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: blue.withValues(alpha: _hovering ? 0.14 : 0.05),
                blurRadius: _hovering ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: blue, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.description,
                style: AppTheme.caption.copyWith(fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}