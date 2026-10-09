class DashboardOverviewModel {
  final num totalRentCollections;
  final num pendingPayments;
  final int totalSubscriptionsCount;
  final int subscriptionExpiredCount;

  DashboardOverviewModel({
    required this.totalRentCollections,
    required this.pendingPayments,
    this.totalSubscriptionsCount=0,
    required this.subscriptionExpiredCount,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      totalRentCollections: json['totalRentCollections'] ?? 0,
      pendingPayments: json['pendingPayments'] ?? 0,
      totalSubscriptionsCount:
      ((json['totalSubscriptionsCount'] ?? json['subscriptionCount'] ?? 0) as num).toInt(),
      subscriptionExpiredCount:
      ((json['subscriptionExpiredCount'] ?? 0) as num).toInt(),
    );
  }
}