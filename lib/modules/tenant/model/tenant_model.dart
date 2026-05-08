class TenantModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? propertyId;
  final String? propertyName;
  final double rentAmount;
  final DateTime lastLogin;
  final bool isActive;
  final String unitNumber;
  final String? panNumber;

  TenantModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.propertyId,
    this.propertyName,
    this.rentAmount = 0,
    required this.lastLogin,
    this.isActive = true,
    this.unitNumber = '',
    this.panNumber,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'N/A',
      phone: json['phoneNumber'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      panNumber: json['panNumber'],
      lastLogin: DateTime.now(),
    );
  }
}
