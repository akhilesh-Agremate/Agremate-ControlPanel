class RentalAgreementItem {
  final String id;
  final String agreementType;
  final String propertyName;
  final String propertyAddress;
  final String landlordName;
  final String tenantName;
  final DateTime? startDate;
  final DateTime? endDate;
  final double rentAmount;
  final String status;
  final String creatorName;
  final String creatorRole;
  final DateTime? createdDate;

  RentalAgreementItem({
    required this.id,
    required this.agreementType,
    required this.propertyName,
    required this.propertyAddress,
    required this.landlordName,
    required this.tenantName,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    required this.status,
    required this.creatorName,
    required this.creatorRole,
    required this.createdDate,
  });

  static String _clean(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.toLowerCase() == 'n/a' || s.toLowerCase() == 'null' ? '' : s;
  }

  factory RentalAgreementItem.fromJson(Map<String, dynamic> json) {
    return RentalAgreementItem(
      id: (json['id'] ?? '').toString(),
      agreementType: _clean(json['agreementType']),
      propertyName: _clean(json['propertyName']),
      propertyAddress: _clean(json['propertyAddress']),
      landlordName: _clean(json['landlordName']),
      tenantName: _clean(json['tenantName']),
      startDate: DateTime.tryParse((json['startDate'] ?? '').toString()),
      endDate: DateTime.tryParse((json['endDate'] ?? '').toString()),
      rentAmount: double.tryParse((json['rentAmount'] ?? 0).toString()) ?? 0,
      status: _clean(json['status']),
      creatorName: _clean(json['creatorName']),
      creatorRole: _clean(json['creatorRole']),
      createdDate: DateTime.tryParse((json['createdDate'] ?? '').toString()),
    );
  }
}