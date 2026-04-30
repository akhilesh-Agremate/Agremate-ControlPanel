import 'package:flutter/material.dart';
import 'package:agremate_admin/core/theme/theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 11,
  });

  factory StatusBadge.landlord() => const StatusBadge(label: 'Landlord', color: AppTheme.accentOrange);
  factory StatusBadge.tenant() => const StatusBadge(label: 'Tenant', color: AppTheme.accentCyan);
  factory StatusBadge.paid() => const StatusBadge(label: 'Paid', color: AppTheme.accentGreen);
  factory StatusBadge.pending() => const StatusBadge(label: 'Pending', color: AppTheme.accentYellow);
  factory StatusBadge.overdue() => const StatusBadge(label: 'Overdue', color: AppTheme.accentRed);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
