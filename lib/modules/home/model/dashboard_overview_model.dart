class DashboardOverviewModel {
  final num totalRentCollections;
  final num pendingPayments;
  final num totalSubscriptions;
  final int subscriptionExpiredCount;

  DashboardOverviewModel({
    required this.totalRentCollections,
    required this.pendingPayments,
    required this.totalSubscriptions,
    required this.subscriptionExpiredCount,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      totalRentCollections: json['totalRentCollections'] ?? 0,
      pendingPayments: json['pendingPayments'] ?? 0,
      totalSubscriptions: json['totalSubscriptions'] ?? 0,
      subscriptionExpiredCount:
      ((json['subscriptionExpiredCount'] ?? 0) as num).toInt(),
    );
  }
}