import 'package:flutter/material.dart';
import 'package:agremate_admin/core/theme/theme.dart';

class KpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final List<double>? sparkData;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    this.sparkData,
  });

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> with SingleTickerProviderStateMixin {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovering ? AppTheme.bgCardLight : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: _hovering ? 0.5 : 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withValues(alpha: _hovering ? 0.12 : 0.05),
              blurRadius: _hovering ? 28 : 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    style: AppTheme.kpiLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(widget.icon, color: widget.accentColor, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.value, style: AppTheme.kpiValue.copyWith(color: widget.accentColor)),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(widget.subtitle!, style: AppTheme.caption.copyWith(color: widget.accentColor.withValues(alpha: 0.7))),
            ],
            if (widget.sparkData != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 30,
                child: CustomPaint(
                  size: const Size(double.infinity, 30),
                  painter: _SparklinePainter(widget.sparkData!, widget.accentColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;
    final barWidth = size.width / data.length - 2;
    for (int i = 0; i < data.length; i++) {
      final h = range > 0 ? ((data[i] - minVal) / range) * size.height * 0.8 + size.height * 0.2 : size.height * 0.5;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * (barWidth + 2), size.height - h, barWidth, h),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, Paint()..color = color.withValues(alpha: 0.6 + (i / data.length) * 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
