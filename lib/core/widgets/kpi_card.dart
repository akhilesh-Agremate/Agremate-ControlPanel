import 'package:flutter/material.dart';
import 'package:agremate_admin/core/theme/theme.dart';

class KpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final List<double>? sparkData;
  final List<String>? sparkLabels;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    this.sparkData,
    this.sparkLabels,
  });

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  bool _hovering = false;
  int? _selectedIndex;

  Widget _buildInteractiveSparkline(List<double> data) {
    if (data.isEmpty) return const SizedBox();
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (i) {
        final val = data[i];
        final hFactor = range > 0 ? ((val - minVal) / range) * 0.7 + 0.3 : 0.5;
        final isSelected = _selectedIndex == i;
        const baseBlue = Color(0xFF2083D5);
        final barColor = isSelected
            ? baseBlue
            : baseBlue.withValues(alpha: 0.35 + (i / data.length) * 0.4);

        return Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _selectedIndex = i),
            onExit: (_) => setState(() => _selectedIndex = null),
            child: Tooltip(
              message: (widget.sparkLabels != null &&
                      i < widget.sparkLabels!.length)
                  ? '${widget.sparkLabels![i]}: ${val.toStringAsFixed(0)}'
                  : val.toStringAsFixed(0),
              child: Container(
                margin: EdgeInsets.only(right: i == data.length - 1 ? 0 : 3),
                height: 28 * hFactor,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) {
        setState(() {
          _hovering = false;
          _selectedIndex = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovering
                ? const Color(0xFF2F6BFF).withValues(alpha: 0.45)
                : const Color(0xFFD6E8FA),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0)
                  .withValues(alpha: _hovering ? 0.14 : 0.07),
              blurRadius: _hovering ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F6BFF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon,
                      color: const Color(0xFF2F6BFF),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTheme.kpiLabel.copyWith(
                        fontSize: 12,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5B6B8C),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.value,
                style: AppTheme.kpiValue.copyWith(
                  color: const Color(0xFF1B4FD8),
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 16,
                child: Text(
                  widget.subtitle ?? '',
                  style: AppTheme.caption.copyWith(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              if (widget.sparkData != null)
                SizedBox(
                  height: 28,
                  child: _buildInteractiveSparkline(widget.sparkData!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
