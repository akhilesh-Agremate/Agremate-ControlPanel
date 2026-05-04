enum PropertyStatus {
  rented,
  available,
  booked,
  requested,
  maintenance,
}

class PropertyModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String landlordId;
  final String landlordName;
  final String? landlordPhone;
  final String? landlordEmail;
  final List<String> tenantIds;
  final double rentAmount;
  final double advanceAmount;
  final String propertyType;
  final int totalUnits;
  final int occupiedUnits;
  final PropertyStatus status;
  final String? primaryTenantName;
  final String? primaryTenantPhone;
  final String? primaryTenantEmail;
  final DateTime? tenantJoinedDate;
  final Map<String, int> serviceRequestCounts;
  final Map<String, String> serviceRequestMessages;
  final String imageUrl;
  final DateTime createdAt;

  PropertyModel({
    required this.id,
    required this.name,
    required this.address,
    this.city = 'Mumbai',
    required this.landlordId,
    required this.landlordName,
    this.landlordPhone,
    this.landlordEmail,
    this.tenantIds = const [],
    this.rentAmount = 0,
    this.advanceAmount = 0,
    this.propertyType = 'Apartment',
    this.totalUnits = 1,
    this.occupiedUnits = 0,
    required this.status,
    this.primaryTenantName,
    this.primaryTenantPhone,
    this.primaryTenantEmail,
    this.tenantJoinedDate,
    this.serviceRequestCounts = const {},
    this.serviceRequestMessages = const {},
    this.imageUrl = 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=600&h=300&auto=format&fit=crop',
    required this.createdAt,
  });

  bool get isRented => status == PropertyStatus.rented;
  int get tenantCount => tenantIds.length;
  double get occupancyRate => totalUnits > 0 ? occupiedUnits / totalUnits : 0;
  
  int getRequestCount(String category) => serviceRequestCounts[category] ?? 0;

  String get statusLabel {
    switch (status) {
      case PropertyStatus.rented: return 'Rented';
      case PropertyStatus.available: return 'Available';
      case PropertyStatus.booked: return 'Booked';
      case PropertyStatus.requested: return 'Requested';
      case PropertyStatus.maintenance: return 'Maintenance';
    }
  }
}
