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
  int? _selectedIndex;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  Widget _buildInteractiveSparkline(List<double> data, Color color) {
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
        
        // Using a consistent professional blue for all charts
        const baseBlue = Color(0xFF2083D5); 
        final barColor = isSelected ? baseBlue : baseBlue.withValues(alpha: 0.4 + (i / data.length) * 0.4);
        
        return Expanded(
          child: GestureDetector(
            onTapDown: (_) => setState(() => _selectedIndex = i),
            onTapCancel: () => setState(() => _selectedIndex = null),
            child: MouseRegion(
              onEnter: (_) => setState(() => _selectedIndex = i),
              onExit: (_) => setState(() => _selectedIndex = null),
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Tooltip(
                    message: i < _months.length ? '${_months[i]}: ${val.toStringAsFixed(0)}' : val.toStringAsFixed(0),
                    child: Container(
                      margin: EdgeInsets.only(right: i == data.length - 1 ? 0 : 2),
                      height: 18 * hFactor,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: (18 * hFactor) + 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2083D5),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: _hovering ? 1.0 : 0.15),
            width: _hovering ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    style: AppTheme.kpiLabel.copyWith(fontSize: 10, letterSpacing: 0.5, color: AppTheme.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(widget.icon, color: widget.accentColor, size: 16),
              ],
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.value, style: AppTheme.kpiValue.copyWith(color: widget.accentColor, fontSize: 22, height: 1.0)),
                if (widget.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      widget.subtitle!,
                      style: AppTheme.caption.copyWith(
                        fontSize: 10,
                        color: AppTheme.textMuted.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            if (widget.sparkData != null)
              SizedBox(
                height: 20, // Fixed height for bars; badges float above
                child: _buildInteractiveSparkline(widget.sparkData!, widget.accentColor),
              ),
          ],
        ),
      ),
    );
  }
}
