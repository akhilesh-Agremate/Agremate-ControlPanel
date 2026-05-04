import 'package:flutter/material.dart';
import 'package:agremate_admin/core/theme/theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double borderRadius;
  final VoidCallback? onTap;

  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.glowColor,
    this.borderRadius = 16,
    this.onTap,
    this.color,
    this.borderColor,
    this.topBarColor,
  });

  final Color? borderColor;
  final Color? topBarColor;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: widget.margin ?? const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: widget.color ?? (_hovering ? AppTheme.bgCardLight : AppTheme.bgCard),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.borderColor ?? (widget.glowColor?.withValues(alpha: _hovering ? 0.5 : 0.25) ?? AppTheme.border),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.topBarColor != null)
                  Container(
                    height: 4,
                    width: double.infinity,
                    color: widget.topBarColor,
                  ),
                Padding(
                  padding: widget.padding ?? const EdgeInsets.all(20),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
