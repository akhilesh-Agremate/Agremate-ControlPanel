import 'package:flutter/material.dart';
import 'package:agremate_admin/core/theme/theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fixedWidth;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize = 11,
    this.fixedWidth,
  });

  // Payment status factories
  factory StatusBadge.landlord() => const StatusBadge(
    label: 'Landlord',
    color: AppTheme.landlordFill,
    backgroundColor: AppTheme.landlordBg,
    textColor: AppTheme.landlordText,
  );
  factory StatusBadge.tenant() => const StatusBadge(
    label: 'Tenant',
    color: AppTheme.tenantFill,
    backgroundColor: AppTheme.tenantBg,
    textColor: AppTheme.tenantText,
  );
  factory StatusBadge.paid() => const StatusBadge(
    label: 'Paid',
    color: AppTheme.statusRentedText,
    backgroundColor: AppTheme.statusRentedBg,
    textColor: AppTheme.statusRentedText,
  );
  factory StatusBadge.pending() => const StatusBadge(
    label: 'Pending',
    color: AppTheme.statusRequestedText,
    backgroundColor: AppTheme.statusRequestedBg,
    textColor: AppTheme.statusRequestedText,
  );
  factory StatusBadge.overdue() => const StatusBadge(
    label: 'Overdue',
    color: AppTheme.brandRed,
    backgroundColor: AppTheme.brandRedLight,
    textColor: AppTheme.brandRed,
  );

  // Property status factories
  factory StatusBadge.rented() => const StatusBadge(
    label: 'Rented',
    color: AppTheme.statusRentedText,
    backgroundColor: AppTheme.statusRentedBg,
    textColor: AppTheme.statusRentedText,
  );
  factory StatusBadge.available() => const StatusBadge(
    label: 'Available',
    color: AppTheme.statusAvailableText,
    backgroundColor: AppTheme.statusAvailableBg,
    textColor: AppTheme.statusAvailableText,
  );
  factory StatusBadge.requested() => const StatusBadge(
    label: 'Requested',
    color: AppTheme.statusRequestedText,
    backgroundColor: AppTheme.statusRequestedBg,
    textColor: AppTheme.statusRequestedText,
  );
  factory StatusBadge.maintenance() => const StatusBadge(
    label: 'Maintenance',
    color: AppTheme.brandRed,
    backgroundColor: AppTheme.brandRedLight,
    textColor: AppTheme.brandRed,
  );
  factory StatusBadge.booked() => const StatusBadge(
    label: 'Booked',
    color: AppTheme.brandSteelBlue,
    backgroundColor: AppTheme.brandPaleSky,
    textColor: AppTheme.brandSteelBlue,
  );
  factory StatusBadge.unknown() => const StatusBadge(
    label: 'Unknown',
    color: Color(0xFF9E9E9E),
    backgroundColor: Color(0xFFF5F5F5),
    textColor: Color(0xFF757575),
  );

  // Subscription status factories
  factory StatusBadge.active() => const StatusBadge(
    label: 'Active',
    color: AppTheme.accentBlue,
    backgroundColor: Colors.white,
    textColor: AppTheme.accentBlue,
    borderColor: AppTheme.accentBlue,
  );
  factory StatusBadge.expired() => const StatusBadge(
    label: 'Expired',
    color: AppTheme.brandRed,
    backgroundColor: Colors.white,
    textColor: AppTheme.brandRed,
    borderColor: AppTheme.brandRed,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fixedWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              borderColor ??
              (textColor?.withValues(alpha: 0.3) ??
                  color.withValues(alpha: 0.4)),
        ),
      ),
      child: Center(
        widthFactor: fixedWidth == null ? 1.0 : null,
        heightFactor: 1.0,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor ?? color,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
