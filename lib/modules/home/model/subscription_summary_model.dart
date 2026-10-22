class SubscriptionSummaryModel {
  final String landlordId;
  final String landlordName;
  final String? landlordEmail;
  final String landlordPhone;
  final int totalSubscriptions;
  final int activeSubscriptions;
  final int inactiveSubscriptions;
  final int activePercentage;
  final int inactivePercentage;
  final List<dynamic> planChanges;

  SubscriptionSummaryModel({
    required this.landlordId,
    required this.landlordName,
    this.landlordEmail,
    required this.landlordPhone,
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    required this.inactiveSubscriptions,
    required this.activePercentage,
    required this.inactivePercentage,
    required this.planChanges,
  });

  factory SubscriptionSummaryModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionSummaryModel(
      landlordId: json['landlordId'] ?? '',
      landlordName: json['landlordName'] ?? '',
      landlordEmail: json['landlordEmail'],
      landlordPhone: json['landlordPhone'] ?? '',
      totalSubscriptions: json['totalSubscriptions'] ?? 0,
      activeSubscriptions: json['activeSubscriptions'] ?? 0,
      inactiveSubscriptions: json['inactiveSubscriptions'] ?? 0,
      activePercentage: json['activePercentage'] ?? 0,
      inactivePercentage: json['inactivePercentage'] ?? 0,
      planChanges: json['planChanges'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'landlordId': landlordId,
      'landlordName': landlordName,
      'landlordEmail': landlordEmail,
      'landlordPhone': landlordPhone,
      'totalSubscriptions': totalSubscriptions,
      'activeSubscriptions': activeSubscriptions,
      'inactiveSubscriptions': inactiveSubscriptions,
      'activePercentage': activePercentage,
      'inactivePercentage': inactivePercentage,
      'planChanges': planChanges,
    };
  }
}
