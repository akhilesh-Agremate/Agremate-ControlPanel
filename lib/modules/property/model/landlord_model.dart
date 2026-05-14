class LandlordModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatar;
  final List<String> propertyIds;
  final double totalRevenue;
  final DateTime lastLogin;
  final bool isActive;
  final String? panNumber;
  final String? aadharNumber;

  LandlordModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatar = '',
    this.propertyIds = const <String>[],
    this.totalRevenue = 0,
    required this.lastLogin,
    this.isActive = true,
    this.panNumber,
    this.aadharNumber,
  });

  factory LandlordModel.fromJson(Map<String, dynamic> json) {
    return LandlordModel(
      id: json['id'] ?? '',
      name: json['fullName'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      panNumber: json['panNumber'],
      aadharNumber: json['aadharNumber'],
      lastLogin: DateTime.now(),
    );
  }

  int get propertyCount => propertyIds.length;
}
