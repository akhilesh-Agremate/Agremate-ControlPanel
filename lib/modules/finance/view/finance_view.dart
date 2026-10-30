import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/full_pdf_page.dart';
import 'package:agremate_admin/modules/finance/controller/finance_controller.dart';
import 'package:agremate_admin/modules/finance/model/finance_model.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/kpi_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final fc = Get.find<FinanceController>();
    final nav = Get.find<NavigationController>();
    final fmt = NumberFormat.compactCurrency(symbol: '₹', locale: 'en_IN');
    final fmtFull =
    NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return Obx(() {
      final isDetailOpen = fc.selectedPropertyId.value != null;
      if (fc.isLoading.value && !isDetailOpen) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGreen),
        );
      }
      
      final o = fc.overview.value;
      if (o == null && !isDetailOpen) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fc.error.value ?? AppStrings.noData, style: AppTheme.heading3),
              const SizedBox(height: 12),
              TextButton(onPressed: fc.loadAll, child: const Text(AppStrings.retry)),
            ],
          ),
        );
      }

      return ColoredBox(
        color: AppColors.scaffoldLight,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDetailOpen)
                _detailSection(fc)
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: AppStrings.totalRevenue,
                        value: o?.totalRevenueFormatted ?? '₹0',
                        icon: Icons.account_balance_wallet_rounded,
                        accentColor: AppTheme.accentGreen,
                        subtitle: AppStrings.allLandlordsCombined,
                        sparkData: o?.totalRevenueSparkline,
                        sparkLabels: o?.chartLabels.isEmpty == false ? o!.chartLabels : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiCard(
                        title: AppStrings.totalRevenue,
                        value: '${o?.rentedPropertiesCount ?? 0}',
                        icon: Icons.home_rounded,
                        accentColor: AppTheme.accentOrange,
                        sparkData: o?.rentedPropertiesSparkline,
                        sparkLabels: o?.chartLabels.isEmpty == false ? o!.chartLabels : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiCard(
                        title: AppStrings.paid,
                        value: '${o?.paidCount ?? 0}',
                        icon: Icons.check_circle_rounded,
                        accentColor: AppTheme.accentCyan,
                        sparkData: o?.paidSparkline,
                        sparkLabels: o?.chartLabels.isEmpty == false ? o!.chartLabels : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiCard(
                        title: AppStrings.overdue,
                        value: '${o?.overdueCount ?? 0}',
                        icon: Icons.warning_rounded,
                        accentColor: AppTheme.accentRed,
                        sparkData: o?.overdueSparkline,
                        sparkLabels: o?.chartLabels.isEmpty == false ? o!.chartLabels : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _chartCard(fmt, fc.revenueRecords),
                const SizedBox(height: 28),
                _propertyList(fc, nav, fmtFull),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _chartCard(NumberFormat fmt, List<RevenueRecord> records) {
    return GlassCard(
      color: AppColors.white,
      borderColor: AppColors.cardBorderBlue,
      glowColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.revenueTrend, style: AppTheme.heading3),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppTheme.border.withValues(alpha: 0.3),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (v, m) => Text(
                        fmt.format(v),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, m) {
                        final idx = v.toInt();
                        if (idx >= 0 && idx < records.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              records[idx].month,
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                lineBarsData: [
                  LineChartBarData(
                    preventCurveOverShooting: true,
                    spots: records
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.accentGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentGreen.withValues(alpha: 0.1),
                    ),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _propertyList(
      FinanceController fc, NavigationController nav, NumberFormat fmtFull) {
    final q = nav.searchQuery.value.toLowerCase();
    final list = fc.properties.where((p) {
      if (q.isEmpty) return true;
      return p.propertyName.toLowerCase().contains(q) ||
          p.landlordName.toLowerCase().contains(q) ||
          p.tenantName.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.rentedProperties, style: AppTheme.heading2),
        const SizedBox(height: 4),
        Text(AppStrings.clickPropertyHint, style: AppTheme.caption),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Text(AppStrings.noRentedPropertiesFound, style: AppTheme.caption)
        else
          ...list.map(
                (prop) => GlassCard(
              color: Colors.white,
              borderColor: AppColors.cardBorderBlue,
              glowColor: Colors.transparent,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              onTap: () => fc.selectProperty(prop.propertyId, prop.propertyName),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.home_rounded,
                        color: AppTheme.accentGreen, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prop.propertyName, style: AppTheme.heading3),
                        const SizedBox(height: 4),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            StatusBadge.landlord(),
                            Text(prop.landlordName, style: AppTheme.caption),
                            const SizedBox(width: 10),
                            StatusBadge.tenant(),
                            Text(prop.tenantName, style: AppTheme.caption),
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
                        'Joined: ${prop.joinedDateFormatted}',
                        style: AppTheme.caption
                            .copyWith(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prop.totalRevenueFormatted,
                        style: const TextStyle(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${fmtFull.format(prop.monthlyRent)} / month',
                        style: AppTheme.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _detailSection(FinanceController fc) {
    final d = fc.detail.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: fc.clearSelection,
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            ),
            Text(fc.selectedPropertyName.value, style: AppTheme.heading2),
          ],
        ),
        const SizedBox(height: 16),
        if (fc.isDetailLoading.value)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.accentGreen),
            ),
          )
        else if (d == null)
          Row(
            children: [
              Text(fc.detailError.value ?? 'No data', style: AppTheme.caption),
              TextButton(
                onPressed: () => fc.selectProperty(
                    fc.selectedPropertyId.value!, fc.selectedPropertyName.value),
                child: const Text('Retry'),
              ),
            ],
          )
        else ...[
            GlassCard(
              color: AppTheme.landlordBg,
              borderColor: AppTheme.landlordBorder,
              padding: const EdgeInsets.all(16),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  const Icon(Icons.person,
                      color: AppTheme.landlordFill, size: 20),
                  Text('Landlord: ${d.landlordName}',
                      style: AppTheme.heading3
                          .copyWith(color: AppTheme.landlordText)),
                  const SizedBox(width: 20),
                  const Icon(Icons.person_outline,
                      color: AppTheme.tenantFill, size: 20),
                  Text('Tenant: ${d.tenantName}',
                      style: AppTheme.heading3
                          .copyWith(color: AppTheme.tenantText)),
                  const SizedBox(width: 20),
                  Text('Total collected: ${d.totalCollectedFormatted}',
                      style: AppTheme.heading3
                          .copyWith(color: AppTheme.accentGreen)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: AppTheme.solidCardDecoration(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                  WidgetStateProperty.all(AppTheme.bgCardLight),
                  columns: const [
                    DataColumn(label: _H(AppStrings.month)),
                    DataColumn(label: _H(AppStrings.villaName)),
                    DataColumn(label: _H(AppStrings.amount)),
                    DataColumn(label: _H(AppStrings.transactionId)),
                    DataColumn(label: _H(AppStrings.status)),
                    DataColumn(label: _H(AppStrings.dueDate)),
                    DataColumn(label: _H(AppStrings.paidDate)),
                    DataColumn(label: _H(AppStrings.delay)),
                  ],
                  rows: d.months.map(_row).toList(),
                ),
              ),
            ),
          ],
      ],
    );
  }

  DataRow _row(FinanceMonthPayment p) {
    final paid = p.status.toLowerCase() == 'paid';
    final overdue = p.status.toLowerCase() == 'overdue';

    Color delayColor;
    if (p.delayDays > 10) {
      delayColor = AppTheme.accentRed;
    } else if (p.delayDays >= 2) {
      delayColor = Colors.orange;
    } else if (p.delayDays > 0) {
      delayColor = Colors.orangeAccent;
    } else {
      delayColor = paid ? Colors.green : AppTheme.textMuted;
    }

    return DataRow(cells: [
      DataCell(Text(p.month,
          style: const TextStyle(color: AppTheme.textSecondary))),
      DataCell(Text(p.propertyName,
          style: const TextStyle(color: AppTheme.textSecondary))),
      DataCell(Text(p.amountFormatted,
          style: const TextStyle(
              color: AppTheme.accentGreen, fontWeight: FontWeight.w600))),
      DataCell(
        p.isCash
            ? Builder(
          builder: (context) => InkWell(
            onTap: () => _showCashProof(context, p),
            child: const Text(
              'Cash in Hand',
              style: TextStyle(
                color: AppTheme.accentGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        )
            : Text(
          p.transactionId,
          style: TextStyle(
            color: p.transactionId == '—'
                ? AppTheme.textMuted
                : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      DataCell(SizedBox(
        width: 85,
        child: paid
            ? StatusBadge.paid()
            : (overdue ? StatusBadge.overdue() : StatusBadge.pending()),
      )),
      DataCell(Text(p.dueDateFormatted,
          style: const TextStyle(
              color: AppTheme.accentOrange, fontWeight: FontWeight.w500))),
      DataCell(Text(p.paidDateFormatted,
          style: const TextStyle(color: AppTheme.textMuted))),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(p.delay,
              style: TextStyle(
                  color: delayColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          if (p.delayDays > 0) ...[
            const SizedBox(width: 4),
            Icon(Icons.notifications_active_rounded,
                color: delayColor, size: 14),
          ],
        ],
      )),
    ]);
  }

  void _showCashProof(BuildContext context, FinanceMonthPayment p) {
    final url = p.receiptImageUrl;
    if (url == null || url.isEmpty) {
      Get.snackbar(AppStrings.noProof, AppStrings.noReceiptAttached);
      return;
    }

    if (url.toLowerCase().contains('.pdf')) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => FullPdfPage(url: url, title: 'Cash Payment Proof'),
        ),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.cashPaymentProof, style: AppTheme.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(AppStrings.amountReceived, p.amountFormatted),
            const SizedBox(height: 8),
            _infoRow(AppStrings.paymentDate, p.paidDateFormatted),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                height: 220,
                width: 320,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  height: 120,
                  width: 320,
                  color: AppTheme.bgCardLight,
                  child: const Icon(Icons.image_not_supported_rounded,
                      color: AppTheme.textMuted),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text(AppStrings.close,
                style: TextStyle(
                    color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style: const TextStyle(
              fontSize: 13, color: AppTheme.textSecondary)),
      const SizedBox(width: 24),
      Text(value,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
    ],
  );
}

class _H extends StatelessWidget {
  final String text;
  const _H(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
        color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
  );
}
