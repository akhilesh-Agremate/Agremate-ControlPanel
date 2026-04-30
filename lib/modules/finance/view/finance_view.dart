import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/modules/finance/controller/finance_controller.dart';
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
    final fmtFull = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Revenue KPI
            Row(
              children: [
                Expanded(child: KpiCard(title: 'Total Revenue', value: fmt.format(fc.totalRevenue.value), icon: Icons.account_balance_wallet_rounded, accentColor: AppTheme.accentGreen, subtitle: 'All landlords combined')),
                const SizedBox(width: 16),
                Expanded(child: KpiCard(title: 'Rented Properties', value: '${fc.rentedProperties.length}', icon: Icons.home_rounded, accentColor: AppTheme.accentOrange)),
                const SizedBox(width: 16),
                Expanded(child: KpiCard(title: 'Paid This Year', value: '${fc.rentPayments.where((p) => p.status == "paid").length}', icon: Icons.check_circle_rounded, accentColor: AppTheme.accentCyan)),
                const SizedBox(width: 16),
                Expanded(child: KpiCard(title: 'Overdue', value: '${fc.rentPayments.where((p) => p.status == "overdue").length}', icon: Icons.warning_rounded, accentColor: AppTheme.accentRed)),
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
                        gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.border.withValues(alpha: 0.3), strokeWidth: 0.5)),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60, getTitlesWidget: (v, m) => Text(fmt.format(v), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)))),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                            final idx = v.toInt();
                            if (idx >= 0 && idx < fc.revenueRecords.length) {
                              return Padding(padding: const EdgeInsets.only(top: 8), child: Text(fc.revenueRecords[idx].month, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)));
                            }
                            return const SizedBox();
                          })),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: fc.revenueRecords.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount)).toList(),
                            isCurved: true,
                            color: AppTheme.accentGreen,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: true, color: AppTheme.accentGreen.withValues(alpha: 0.1)),
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
                  IconButton(onPressed: fc.clearSelection, icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary)),
                  Text(fc.selectedPropertyName.value, style: AppTheme.heading2),
                ],
              ),
              const SizedBox(height: 16),
              // Landlord/Tenant info
              if (fc.selectedPropertyPayments.isNotEmpty) ...[
                GlassCard(
                  glowColor: AppTheme.accentOrange,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: AppTheme.accentOrange, size: 20),
                      const SizedBox(width: 8),
                      Text('Landlord: ${fc.selectedPropertyPayments.first.landlordName}', style: AppTheme.heading3),
                      const SizedBox(width: 32),
                      const Icon(Icons.person_outline, color: AppTheme.accentCyan, size: 20),
                      const SizedBox(width: 8),
                      Text('Tenant: ${fc.selectedPropertyPayments.first.tenantName}', style: AppTheme.heading3),
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
                  headingRowColor: WidgetStateProperty.all(AppTheme.bgCardLight),
                  columns: const [
                    DataColumn(label: Text('Month', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Villa Name', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Amount', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Status', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Paid Date', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  ],
                  rows: fc.selectedPropertyPayments.map((p) => DataRow(cells: [
                    DataCell(Text('${p.month} ${p.year}', style: const TextStyle(color: AppTheme.textSecondary))),
                    DataCell(Text(fc.selectedPropertyName.value, style: const TextStyle(color: AppTheme.textSecondary))),
                    DataCell(Text(fmtFull.format(p.amount), style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w600))),
                    DataCell(StatusBadge(label: p.status.capitalizeFirst ?? p.status, color: p.status == 'paid' ? AppTheme.accentGreen : (p.status == 'overdue' ? AppTheme.accentRed : AppTheme.accentYellow))),
                    DataCell(Text(p.paidDate != null ? '${p.paidDate!.day}/${p.paidDate!.month}/${p.paidDate!.year}' : '—', style: const TextStyle(color: AppTheme.textMuted))),
                  ])).toList(),
                ),
              ),
            ] else ...[
              Text('Rented Properties', style: AppTheme.heading2),
              const SizedBox(height: 4),
              Text('Click on a property to view monthly rent payments', style: AppTheme.caption),
              const SizedBox(height: 16),
              ...fc.rentedProperties.where((p) {
                if (nav.searchQuery.value.isEmpty) return true;
                final q = nav.searchQuery.value.toLowerCase();
                return (p['propertyName'] as String).toLowerCase().contains(q) ||
                       (p['landlordName'] as String).toLowerCase().contains(q) ||
                       (p['tenantName'] as String).toLowerCase().contains(q);
              }).map((prop) => GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                onTap: () => fc.selectProperty(prop['propertyId'] as String, prop['propertyName'] as String),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.home_rounded, color: AppTheme.accentGreen, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prop['propertyName'] as String, style: AppTheme.heading3),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              StatusBadge.landlord(),
                              const SizedBox(width: 6),
                              Text(prop['landlordName'] as String, style: AppTheme.caption),
                              const SizedBox(width: 16),
                              StatusBadge.tenant(),
                              const SizedBox(width: 6),
                              Text(prop['tenantName'] as String, style: AppTheme.caption),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(fmtFull.format(prop['totalPaid']), style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                  ],
                ),
              )),
            ],
          ],
        ),
      );
    });
  }
}
