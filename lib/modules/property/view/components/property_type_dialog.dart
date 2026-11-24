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
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
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
                const SizedBox(height: 20),
                _OptionsLayout(
                  children: [
                    Expanded(
                      child: _TypeOption(
                        icon: Icons.home_rounded,
                        title: 'Residential',
                        description:
                        'Villa, flat or house rented to a single tenant.',
                        onTap: () => Navigator.of(context)
                            .pop(PropertyAddType.individual),
                        isMobile: isMobile,
                      ),
                    ),
                    SizedBox(width: isMobile ? 10 : 16),
                    Expanded(
                      child: _TypeOption(
                        icon: Icons.bed_rounded,
                        title: 'PG',
                        description:
                        'Paying guest with floors, rooms and beds.',
                        onTap: () =>
                            Navigator.of(context).pop(PropertyAddType.pg),
                        isMobile: isMobile,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
  final bool isMobile;

  const _TypeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isMobile = false,
  });

  @override
  State<_TypeOption> createState() => _TypeOptionState();
}

class _TypeOptionState extends State<_TypeOption> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2F6BFF);
    final isMobile = widget.isMobile;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: isMobile ? 150 : 190),
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          decoration: BoxDecoration(
            color: _hovering ? const Color(0xFFEEF4FF) : Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
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
                width: isMobile ? 40 : 48,
                height: isMobile ? 40 : 48,
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
                ),
                child: Icon(widget.icon, color: blue, size: isMobile ? 20 : 24),
              ),
              SizedBox(height: isMobile ? 10 : 16),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: isMobile ? 14.5 : 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                widget.description,
                style: AppTheme.caption.copyWith(
                  fontSize: isMobile ? 11 : 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Always side by side using IntrinsicHeight and Row.
class _OptionsLayout extends StatelessWidget {
  final List<Widget> children;
  const _OptionsLayout({required this.children});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}