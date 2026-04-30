import 'package:flutter/material.dart';
import 'package:agremate_admin/core/theme/theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.glowColor,
    this.borderRadius = 16,
    this.onTap,
  });

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
          padding: widget.padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovering ? AppTheme.bgCardLight : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.glowColor?.withValues(alpha: _hovering ? 0.5 : 0.25) ?? AppTheme.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              if (widget.glowColor != null)
                BoxShadow(
                  color: widget.glowColor!.withValues(alpha: _hovering ? 0.15 : 0.06),
                  blurRadius: _hovering ? 30 : 20,
                  spreadRadius: -5,
                ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
