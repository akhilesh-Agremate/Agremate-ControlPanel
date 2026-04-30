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

  LandlordModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatar = '',
    this.propertyIds = const [],
    this.totalRevenue = 0,
    required this.lastLogin,
    this.isActive = true,
  });

  int get propertyCount => propertyIds.length;

  LandlordModel copyWith({
    String? name,
    String? phone,
    String? email,
    List<String>? propertyIds,
    double? totalRevenue,
    bool? isActive,
  }) {
    return LandlordModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar,
      propertyIds: propertyIds ?? this.propertyIds,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      lastLogin: lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }
}
