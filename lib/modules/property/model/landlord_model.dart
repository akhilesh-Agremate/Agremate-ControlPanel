class LandlordPropertyModel {
  final String id;
  final String name;
  final String address;
  final String status;
  final double rent;
  final String zone;

  LandlordPropertyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.rent,
    required this.zone,
  });

  factory LandlordPropertyModel.fromJson(Map<String, dynamic> json) {
    return LandlordPropertyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Property',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      rent: (json['rent'] ?? 0).toDouble(),
      zone: json['zone']?.toString() ?? '',
    );
  }
}

class LandlordModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String? panNumber;
  final int totalProperties;
  final int occupiedCount;
  final int vacantCount;
  final List<LandlordPropertyModel> properties;
  final double totalRevenue;
  final bool isActive;

  LandlordModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.panNumber,
    this.totalProperties = 0,
    this.occupiedCount = 0,
    this.vacantCount = 0,
    this.properties = const [],
    this.totalRevenue = 0,
    this.isActive = true,
  });

  factory LandlordModel.fromJson(Map<String, dynamic> json) {
    var list = json['properties'] as List<dynamic>? ?? [];
    List<LandlordPropertyModel> parsedProperties =
        list
            .map(
              (e) => LandlordPropertyModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();

    final propertyCount =
        ((json['propertyCount'] ?? json['totalProperties'] ?? parsedProperties.length) as num)
            .toInt();
    final activeCount =
        ((json['activePropertyCount'] ?? json['occupiedCount'] ?? 0) as num)
            .toInt();

    return LandlordModel(
      id: (json['landlordId'] ?? json['id'])?.toString() ?? '',
      name: json['name']?.toString() ?? 'N/A',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      panNumber: json['panNumber']?.toString(),
      totalProperties: propertyCount,
      occupiedCount: activeCount,
      vacantCount: json['vacantCount'] ?? 0,
      properties: parsedProperties,
      totalRevenue: parsedProperties.fold(0.0, (sum, p) => sum + p.rent),
      isActive: json['isActive'] as bool? ?? activeCount > 0,
    );
  }

  int get propertyCount => properties.length;
}
