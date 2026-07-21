import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/finance/controller/finance_controller.dart';
import 'package:agremate_admin/modules/finance/model/finance_model.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/kpi_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final fc = Get.find<FinanceController>();
    final nav = Get.find<NavigationController>();
    final fmt = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN');
    final fmtFull = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Obx(() {
      if (fc.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGreen),
        );
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Revenue KPI
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Total Revenue',
                      value: fmt.format(fc.currentTotalRevenue),
                      icon: Icons.account_balance_wallet_rounded,
                      accentColor: AppTheme.accentGreen,
                      subtitle:
                          fc.selectedPropertyName.value.isEmpty
                              ? 'All landlords combined'
                              : fc.selectedPropertyName.value,
                      sparkData:
                          fc.currentRevenueRecords
                              .map((r) => r.amount / 1000)
                              .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Rented Properties',
                      value: '${fc.currentRentedPropertiesCount}',
                      icon: Icons.home_rounded,
                      accentColor: AppTheme.accentOrange,
                      sparkData: const [5, 6, 5, 7, 8, 7, 9, 10, 10, 9, 11, 12],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Paid This Year',
                      value: '${fc.currentPaidCount}',
                      icon: Icons.check_circle_rounded,
                      accentColor: AppTheme.accentCyan,
                      sparkData: const [
                        40,
                        45,
                        42,
                        50,
                        55,
                        52,
                        60,
                        65,
                        62,
                        70,
                        75,
                        80,
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: KpiCard(
                      title: 'Overdue',
                      value: '${fc.currentOverdueCount}',
                      icon: Icons.warning_rounded,
                      accentColor: AppTheme.accentRed,
                      sparkData: const [
                        12,
                        10,
                        15,
                        8,
                        5,
                        7,
                        10,
                        12,
                        11,
                        15,
                        13,
                        18,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Revenue trend chart
            GlassCard(
              glowColor: AppTheme.accentGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue Trend — 2025', style: AppTheme.heading3),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine:
                              (v) => FlLine(
                                color: AppTheme.border.withValues(alpha: 0.3),
                                strokeWidth: 0.5,
                              ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget:
                                  (v, m) => Text(
                                    fmt.format(v),
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (v, m) {
                                final idx = v.toInt();
                                if (idx >= 0 &&
                                    idx < fc.currentRevenueRecords.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      fc.currentRevenueRecords[idx].month,
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        lineBarsData: [
                          LineChartBarData(
                            preventCurveOverShooting: true,
                            spots:
                                fc.currentRevenueRecords
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => FlSpot(
                                        e.key.toDouble(),
                                        e.value.amount,
                                      ),
                                    )
                                    .toList(),
                            isCurved: true,
                            color: AppTheme.accentGreen,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.accentGreen.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Rented properties list or payment detail
            if (fc.selectedPropertyName.value.isNotEmpty) ...[
              // Payment detail
              Row(
                children: [
                  IconButton(
                    onPressed: fc.clearSelection,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(fc.selectedPropertyName.value, style: AppTheme.heading2),
                ],
              ),
              const SizedBox(height: 16),
              // Landlord/Tenant info
              if (fc.selectedPropertyPayments.isNotEmpty) ...[
                GlassCard(
                  color: AppTheme.landlordBg,
                  borderColor: AppTheme.landlordBorder,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: AppTheme.landlordFill,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Landlord: ${fc.selectedPropertyPayments.first.landlordName}',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.landlordText,
                        ),
                      ),
                      const SizedBox(width: 32),
                      const VerticalDivider(),
                      const SizedBox(width: 32),
                      const Icon(
                        Icons.person_outline,
                        color: AppTheme.tenantFill,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tenant: ${fc.selectedPropertyPayments.first.tenantName}',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.tenantText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Monthly payments table
              Container(
                width: double.infinity,
                decoration: AppTheme.solidCardDecoration(),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppTheme.bgCardLight,
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Month',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Villa Name',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Transaction ID',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Center(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Due Date',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Paid Date',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Delay',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  rows:
                      fc.selectedPropertyPayments.map((p) {
                        final delayDays =
                            p.paidDate != null
                                ? p.paidDate!.difference(p.dueDate).inDays
                                : 0;
                        Color delayColor = Colors.green;

                        if (p.paidDate == null) {
                          delayColor = AppTheme.textMuted;
                        } else if (delayDays > 10) {
                          delayColor = AppTheme.accentRed;
                        } else if (delayDays >= 2) {
                          delayColor = Colors.orange;
                        } else if (delayDays > 0) {
                          delayColor = Colors.orangeAccent;
                        } else {
                          delayColor = Colors.green;
                        }

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${p.month} ${p.year}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                fc.selectedPropertyName.value,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                fmtFull.format(p.amount),
                                style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(
                              p.paymentMethod == 'Cash in Hand'
                                  ? InkWell(
                                    onTap:
                                        () =>
                                            _showCashPaymentDetails(context, p),
                                    child: Text(
                                      'Cash in Hand',
                                      style: TextStyle(
                                        color: AppTheme.accentGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    p.transactionId ?? '—',
                                    style: TextStyle(
                                      color:
                                          p.transactionId != null
                                              ? AppTheme.textSecondary
                                              : AppTheme.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                            ),
                            DataCell(
                              Center(
                                child: SizedBox(
                                  width: 85,
                                  child:
                                      p.status == 'paid'
                                          ? StatusBadge.paid()
                                          : (p.status == 'overdue'
                                              ? StatusBadge.overdue()
                                              : StatusBadge.pending()),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${p.dueDate.day}/${p.dueDate.month}/${p.dueDate.year}',
                                style: const TextStyle(
                                  color: AppTheme.accentOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                p.paidDate != null
                                    ? '${p.paidDate!.day}/${p.paidDate!.month}/${p.paidDate!.year}'
                                    : '—',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p.paidDate == null
                                        ? '—'
                                        : (delayDays <= 0
                                            ? 'On Time'
                                            : '$delayDays Days'),
                                    style: TextStyle(
                                      color: delayColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (p.paidDate != null && delayDays >= 1) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.notifications_active_rounded,
                                      color: delayColor,
                                      size: 14,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ] else ...[
              Text('Rented Properties', style: AppTheme.heading2),
              const SizedBox(height: 4),
              Text(
                'Click on a property to view monthly rent payments',
                style: AppTheme.caption,
              ),
              const SizedBox(height: 16),
              ...fc.rentedProperties
                  .where((p) {
                    if (nav.searchQuery.value.isEmpty) return true;
                    final q = nav.searchQuery.value.toLowerCase();
                    return (p['propertyName'] as String).toLowerCase().contains(
                          q,
                        ) ||
                        (p['landlordName'] as String).toLowerCase().contains(
                          q,
                        ) ||
                        (p['tenantName'] as String).toLowerCase().contains(q);
                  })
                  .map(
                    (prop) => GlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      onTap:
                          () => fc.selectProperty(
                            prop['propertyId'] as String,
                            prop['propertyName'] as String,
                          ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              color: AppTheme.accentGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prop['propertyName'] as String,
                                  style: AppTheme.heading3,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    StatusBadge.landlord(),
                                    const SizedBox(width: 6),
                                    Text(
                                      prop['landlordName'] as String,
                                      style: AppTheme.caption,
                                    ),
                                    const SizedBox(width: 16),
                                    StatusBadge.tenant(),
                                    const SizedBox(width: 6),
                                    Text(
                                      prop['tenantName'] as String,
                                      style: AppTheme.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Joined: ${prop['joinedDate'] ?? 'Jan 2024'}',
                                style: AppTheme.caption.copyWith(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                fmtFull.format(prop['totalPaid']),
                                style: TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: AppTheme.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      );
    });
  }

  void _showCashPaymentDetails(BuildContext context, RentPaymentModel p) {
    final fmtFull = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    final dateStr =
        p.paidDate != null
            ? '${p.paidDate!.day}/${p.paidDate!.month}/${p.paidDate!.year}'
            : 'N/A';

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: AppTheme.accentGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text('Cash Payment Proof', style: AppTheme.heading3),
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Amount Received', fmtFull.format(p.amount)),

            const SizedBox(height: 12),

            _buildInfoRow('Payment Date', dateStr),

            const SizedBox(height: 16),

            const Text(
              'Attachment Proof:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMuted,
              ),
            ),

            const SizedBox(height: 8),

            if (p.proofUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  p.proofUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (c, e, s) => Container(
                        height: 180,
                        width: double.infinity,
                        color: AppTheme.bgCardLight,
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: AppTheme.textMuted,
                        ),
                      ),
                ),
              )
            else
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No proof attached',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              ),
          ],
        ),

        actions: [
          /// Download Button
          TextButton.icon(
            onPressed: () {
              Get.snackbar(
                'Download Started',
                'The payment proof is being downloaded...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.accentGreen,
                colorText: Colors.white,
              );
            },
            icon: const Icon(
              Icons.download_rounded,
              size: 18,
              color: AppTheme.accentGreen,
            ),
            label: const Text(
              'Download File',
              style: TextStyle(
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// Close Button
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text(
              'Close',
              style: TextStyle(
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      barrierDismissible: true,
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
