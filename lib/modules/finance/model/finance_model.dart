class RentPaymentModel {
  final String id;
  final String propertyId;
  final String propertyName;
  final String landlordId;
  final String landlordName;
  final String tenantId;
  final String tenantName;
  final double amount;
  final String month;
  final int year;
  final String status; // paid, pending, overdue
  final DateTime? paidDate;

  RentPaymentModel({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.landlordId,
    required this.landlordName,
    required this.tenantId,
    required this.tenantName,
    required this.amount,
    required this.month,
    required this.year,
    this.status = 'paid',
    this.paidDate,
  });
}

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
