class TenantPropertyModel {
  final String id;
  final String name;
  final String address;
  final String status;
  final double rent;
  final String zone;

  TenantPropertyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.rent,
    required this.zone,
  });

  factory TenantPropertyModel.fromJson(Map<String, dynamic> json) {
    return TenantPropertyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Property',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      rent: (json['rent'] ?? 0).toDouble(),
      zone: json['zone']?.toString() ?? '',
    );
  }
}

class TenantModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? panNumber;
  final DateTime lastLogin;
  final String tenancyStartDate;
  final int openMaintenanceCount;
  final TenantPropertyModel? property;

  String get propertyId => property?.id ?? '';
  String get propertyName => property?.name ?? 'No Property Assigned';
  double get rentAmount => property?.rent ?? 0.0;
  bool get isActive => true;
  String get unitNumber => '';

  TenantModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.panNumber,
    required this.lastLogin,
    this.tenancyStartDate = '',
    this.openMaintenanceCount = 0,
    this.property,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    TenantPropertyModel? property;
    if (json['property'] is Map) {
      property = TenantPropertyModel.fromJson(
        json['property'] as Map<String, dynamic>,
      );
    } else if ((json['propertyName'] ?? '').toString().isNotEmpty) {
      property = TenantPropertyModel(
        id: '',
        name: json['propertyName'].toString(),
        address: '',
        status: '',
        rent: 0,
        zone: '',
      );
    }

    return TenantModel(
      id: (json['tenantId'] ?? json['id'])?.toString() ?? '',
      name: json['name']?.toString() ?? 'N/A',
      phone: (json['phone'] ?? json['phoneNumber'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      panNumber: json['panNumber']?.toString(),
      lastLogin: DateTime.now(),
      tenancyStartDate: json['tenancyStartDate']?.toString() ?? '',
      openMaintenanceCount: json['openMaintenanceCount'] ?? 0,
      property: property,
    );
  }
}
