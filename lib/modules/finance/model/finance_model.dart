class RevenueRecord {
  final String month;
  final double amount;
  final int year;

  RevenueRecord({
    required this.month,
    required this.amount,
    required this.year,
  });
}

class RevenueTrendPoint {
  final int month;
  final String monthName;
  final int year;
  final String label;
  final double revenue;

  RevenueTrendPoint({
    required this.month,
    required this.monthName,
    required this.year,
    required this.label,
    required this.revenue,
  });

  factory RevenueTrendPoint.fromJson(Map<String, dynamic> j) => RevenueTrendPoint(
    month: (j['month'] as num?)?.toInt() ?? 0,
    monthName: j['monthName']?.toString() ?? '',
    year: (j['year'] as num?)?.toInt() ?? 0,
    label: j['label']?.toString() ?? '',
    revenue: (j['revenue'] as num?)?.toDouble() ?? 0,
  );
}

class FinanceOverview {
  final double totalRevenue;
  final String totalRevenueFormatted;
  final List<double> totalRevenueSparkline;
  final int rentedPropertiesCount;
  final List<double> rentedPropertiesSparkline;
  final int paidCount;
  final List<double> paidSparkline;
  final int overdueCount;
  final List<double> overdueSparkline;
  final List<RevenueTrendPoint> revenueTrend;
  final List<String> chartLabels;

  FinanceOverview({
    required this.totalRevenue,
    required this.totalRevenueFormatted,
    required this.totalRevenueSparkline,
    required this.rentedPropertiesCount,
    required this.rentedPropertiesSparkline,
    required this.paidCount,
    required this.paidSparkline,
    required this.overdueCount,
    required this.overdueSparkline,
    required this.revenueTrend,
    required this.chartLabels,
  });

  static List<double> _nums(dynamic v) =>
      (v as List? ?? []).map((e) => (e as num).toDouble()).toList();

  factory FinanceOverview.fromJson(Map<String, dynamic> j) => FinanceOverview(
    totalRevenue: (j['totalRevenue'] as num?)?.toDouble() ?? 0,
    totalRevenueFormatted: j['totalRevenueFormatted']?.toString() ?? '₹0',
    totalRevenueSparkline: _nums(j['totalRevenueSparkline']),
    rentedPropertiesCount: (j['rentedPropertiesCount'] as num?)?.toInt() ?? 0,
    rentedPropertiesSparkline: _nums(j['rentedPropertiesSparkline']),
    paidCount: (j['paidCount'] as num?)?.toInt() ?? 0,
    paidSparkline: _nums(j['paidSparkline']),
    overdueCount: (j['overdueCount'] as num?)?.toInt() ?? 0,
    overdueSparkline: _nums(j['overdueSparkline']),
    revenueTrend: (j['revenueTrend'] as List? ?? [])
        .map((e) => RevenueTrendPoint.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    chartLabels: (j['totalRevenueChart'] as List? ?? [])
        .map((e) => (e['monthName'] ?? '').toString())
        .toList(),
  );
}

class FinanceProperty {
  final String propertyId;
  final String propertyName;
  final String landlordName;
  final String tenantName;
  final String joinedDateFormatted;
  final double totalRevenueCollected;
  final String totalRevenueFormatted;
  final double monthlyRent;
  final String status;

  FinanceProperty({
    required this.propertyId,
    required this.propertyName,
    required this.landlordName,
    required this.tenantName,
    required this.joinedDateFormatted,
    required this.totalRevenueCollected,
    required this.totalRevenueFormatted,
    required this.monthlyRent,
    required this.status,
  });

  factory FinanceProperty.fromJson(Map<String, dynamic> j) => FinanceProperty(
    propertyId: j['propertyId']?.toString() ?? '',
    propertyName: j['propertyName']?.toString() ?? '',
    landlordName: j['landlordName']?.toString() ?? '',
    tenantName: j['tenantName']?.toString() ?? '',
    joinedDateFormatted: j['joinedDateFormatted']?.toString() ?? '',
    totalRevenueCollected:
    (j['totalRevenueCollected'] as num?)?.toDouble() ?? 0,
    totalRevenueFormatted: j['totalRevenueFormatted']?.toString() ?? '₹0',
    monthlyRent: (j['monthlyRent'] as num?)?.toDouble() ?? 0,
    status: j['status']?.toString() ?? '',
  );
}

class FinanceMonthPayment {
  final String month;
  final String propertyName;
  final double amount;
  final String amountFormatted;
  final String transactionId;
  final String? paymentMethod;
  final String? receiptImageUrl;
  final String status;
  final String dueDateFormatted;
  final String paidDateFormatted;
  final int delayDays;
  final String delay;

  FinanceMonthPayment({
    required this.month,
    required this.propertyName,
    required this.amount,
    required this.amountFormatted,
    required this.transactionId,
    required this.paymentMethod,
    required this.receiptImageUrl,
    required this.status,
    required this.dueDateFormatted,
    required this.paidDateFormatted,
    required this.delayDays,
    required this.delay,
  });

  bool get isCash => paymentMethod == 'CashInHand';

  factory FinanceMonthPayment.fromJson(Map<String, dynamic> j) =>
      FinanceMonthPayment(
        month: j['month']?.toString() ?? '',
        propertyName: j['propertyName']?.toString() ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        amountFormatted: j['amountFormatted']?.toString() ?? '',
        transactionId: j['transactionId']?.toString() ?? '—',
        paymentMethod: j['paymentMethod']?.toString(),
        receiptImageUrl: j['receiptImageUrl']?.toString(),
        status: j['status']?.toString() ?? '',
        dueDateFormatted: j['dueDateFormatted']?.toString() ?? '—',
        paidDateFormatted: j['paidDateFormatted']?.toString() ?? '—',
        delayDays: (j['delayDays'] as num?)?.toInt() ?? 0,
        delay: (j['delay']?.toString() ?? '—').replaceAll('🔔', '').trim(),
      );
}

class FinancePropertyDetail {
  final String propertyId;
  final String propertyName;
  final String landlordName;
  final String tenantName;
  final double monthlyRent;
  final double totalCollected;
  final String totalCollectedFormatted;
  final List<FinanceMonthPayment> months;

  FinancePropertyDetail({
    required this.propertyId,
    required this.propertyName,
    required this.landlordName,
    required this.tenantName,
    required this.monthlyRent,
    required this.totalCollected,
    required this.totalCollectedFormatted,
    required this.months,
  });

  factory FinancePropertyDetail.fromJson(Map<String, dynamic> j) =>
      FinancePropertyDetail(
        propertyId: j['propertyId']?.toString() ?? '',
        propertyName: j['propertyName']?.toString() ?? '',
        landlordName: j['landlordName']?.toString() ?? '',
        tenantName: j['tenantName']?.toString() ?? '',
        monthlyRent: (j['monthlyRent'] as num?)?.toDouble() ?? 0,
        totalCollected: (j['totalCollected'] as num?)?.toDouble() ?? 0,
        totalCollectedFormatted:
        j['totalCollectedFormatted']?.toString() ?? '₹0',
        months: (j['months'] as List? ?? [])
            .map((e) =>
            FinanceMonthPayment.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}