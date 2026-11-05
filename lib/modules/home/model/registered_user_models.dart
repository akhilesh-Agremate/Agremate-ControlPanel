class RegisteredPropertyItem {
  final String name;
  final String address;
  final bool isOccupied;
  final List<String> tenantNames;

  RegisteredPropertyItem({
    required this.name,
    required this.address,
    required this.isOccupied,
    this.tenantNames = const [],
  });

  factory RegisteredPropertyItem.fromJson(Map<String, dynamic> json) {
    final names = <String>[];
    final tenantsJson = json['tenants'];
    if (tenantsJson is List) {
      for (final item in tenantsJson) {
        if (item is Map) {
          final name = (item['name'] ?? '').toString().trim();
          if (name.isNotEmpty && !names.contains(name)) {
            names.add(name);
          }
        }
      }
    }
    return RegisteredPropertyItem(
      name: (json['propertyName'] ?? json['name'] ?? '').toString(),
      address: (json['propertyAddress'] ?? json['address'] ?? '').toString(),
      isOccupied: json['isOccupied'] == true,
      tenantNames: names,
    );
  }
}

class RegisteredLandlordItem {
  final String id;
  final String name;
  final String phone;
  final String email;
  final bool isActive;
  final int propertyCount;
  final DateTime? joinedDate;
  final List<RegisteredPropertyItem> properties;
  final List<RegisteredTenantItem> tenants;

  RegisteredLandlordItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.isActive,
    required this.propertyCount,
    this.joinedDate,
    this.properties = const [],
    this.tenants = const [],
  });

  factory RegisteredLandlordItem.fromJson(Map<String, dynamic> json) {
    final properties = <RegisteredPropertyItem>[];
    final propertiesJson = json['properties'];
    if (propertiesJson is List) {
      for (final item in propertiesJson) {
        if (item is Map) {
          properties.add(
            RegisteredPropertyItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final tenants = <RegisteredTenantItem>[];
    final tenantsJson = json['tenants'];
    if (tenantsJson is List) {
      for (final item in tenantsJson) {
        if (item is Map) {
          tenants.add(
            RegisteredTenantItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return RegisteredLandlordItem(
      id: (json['landlordId'] ?? json['userId'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      isActive: json['isActive'] == true,
      propertyCount: ((json['propertyCount'] ?? properties.length) as num)
          .toInt(),
      joinedDate: DateTime.tryParse((json['joinedDate'] ?? '').toString()),
      properties: properties,
      tenants: tenants,
    );
  }
}

class RegisteredTenantItem {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String propertyName;
  final String propertyAddress;
  final String tenancyStartDate;
  final bool isActive;

  RegisteredTenantItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.propertyName,
    required this.propertyAddress,
    required this.tenancyStartDate,
    required this.isActive,
  });

  factory RegisteredTenantItem.fromJson(Map<String, dynamic> json) {
    return RegisteredTenantItem(
      id: (json['tenantId'] ?? json['userId'] ?? json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      propertyName: (json['propertyName'] ?? json['property'] ?? '').toString(),
      propertyAddress:
          (json['propertyAddress'] ?? json['address'] ?? '').toString(),
      tenancyStartDate: (json['tenancyStartDate'] ?? json['joinedDate'] ?? '')
          .toString(),
      isActive: json['isActive'] != false,
    );
  }

  DateTime? get startDate => DateTime.tryParse(tenancyStartDate);
}
