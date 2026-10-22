class RentCollectionModel {
  final String id;
  final String propertyId;
  final String propertyName;
  final String landlordId;
  final String landlordName;
  final String tenantId;
  final String tenantName;
  final String paymentDate;
  final num rentAmount;
  final String dueDate;

  RentCollectionModel({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.landlordId,
    required this.landlordName,
    required this.tenantId,
    required this.tenantName,
    required this.paymentDate,
    required this.rentAmount,
    required this.dueDate,
  });

  factory RentCollectionModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic value) =>
        value is Map ? Map<String, dynamic>.from(value) : null;

    final property = asMap(json['property']);
    final landlord = asMap(json['landlord']);
    final tenant = asMap(json['tenant']);

    return RentCollectionModel(
      id: (json['id'] ?? json['rentCollectionId'] ?? '').toString(),
      propertyId: (json['propertyId'] ?? property?['id'] ?? '').toString(),
      propertyName: (json['propertyName'] ??
              property?['name'] ??
              property?['propertyName'] ??
              '')
          .toString(),
      landlordId: (json['landlordId'] ?? landlord?['id'] ?? '').toString(),
      landlordName: (json['landlordName'] ??
              landlord?['name'] ??
              landlord?['fullName'] ??
              '')
          .toString(),
      tenantId: (json['tenantId'] ?? tenant?['id'] ?? '').toString(),
      tenantName: (json['tenantName'] ??
              tenant?['name'] ??
              tenant?['fullName'] ??
              '')
          .toString(),
      paymentDate: (json['paymentDate'] ??
              json['paidDate'] ??
              json['paidOn'] ??
              '')
          .toString(),
      rentAmount: json['rentAmount'] ??
          json['pendingAmount'] ??
          json['amount'] ??
          json['totalAmount'] ??
          0,
      dueDate: (json['dueDate'] ?? json['rentDueDate'] ?? '').toString(),
    );
  }
}
