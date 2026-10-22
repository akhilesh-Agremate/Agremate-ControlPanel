class SubscriptionModel {
  final String id;
  final String landlordId;
  final String landlordName;
  final String planName;
  final String status;
  final String startDate;
  final String endDate;
  final num amount;

  SubscriptionModel({
    required this.id,
    required this.landlordId,
    required this.landlordName,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: (json['id'] ?? json['subscriptionId'] ?? '').toString(),
      landlordId: (json['landlordId'] ?? '').toString(),
      landlordName: (json['landlordName'] ?? json['landlord']?['name'] ?? json['landlord']?['fullName'] ?? '').toString(),
      planName: (json['planName'] ?? json['plan']?['name'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      startDate: (json['startDate'] ?? json['subscribedDate'] ?? '').toString(),
      endDate: (json['endDate'] ?? json['expiryDate'] ?? '').toString(),
      amount: json['amount'] ?? json['planAmount'] ?? json['totalAmount'] ?? 0,
    );
  }
}
