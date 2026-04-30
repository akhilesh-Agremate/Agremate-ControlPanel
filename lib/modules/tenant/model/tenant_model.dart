class TenantModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String propertyId;
  final String propertyName;
  final double rentAmount;
  final DateTime lastLogin;
  final bool isActive;
  final String unitNumber;

  TenantModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.propertyId,
    required this.propertyName,
    this.rentAmount = 0,
    required this.lastLogin,
    this.isActive = true,
    this.unitNumber = '',
  });
}
