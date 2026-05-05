enum PropertyStatus {
  rented,
  available,
  booked,
  requested,
  maintenance,
}

class PropertyAddress {
  final String address;
  final double latitude;
  final double longitude;

  PropertyAddress({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PropertyAddress.fromJson(Map<String, dynamic> json) {
    return PropertyAddress(
      address: json['Address'] ?? '',
      latitude: (json['Latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['Longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() => address;
}

class PropertyModel {
  final String id;
  final String name;
  final PropertyAddress address;
  final bool isOwner;
  final PropertyStatus status;
  final double rentAmount;
  final double advanceAmount;
  final int bedrooms;
  final int bathrooms;
  final int kitchen;
  final int builtYear;
  final String? description;
  final List<dynamic> documents;
  final String imageUrl;
  
  // Fields for backward compatibility and UI usage
  final String city;
  final String landlordId;
  final String landlordName;
  final String? landlordPhone;
  final String? landlordEmail;
  final List<String> tenantIds;
  final String? primaryTenantName;
  final String? primaryTenantPhone;
  final String? primaryTenantEmail;
  final DateTime? tenantJoinedDate;
  final Map<String, int> serviceRequestCounts;
  final Map<String, String> serviceRequestMessages;
  final String propertyType;
  final int totalUnits;
  final int occupiedUnits;
  final DateTime createdAt;

  PropertyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    this.isOwner = true,
    this.rentAmount = 0,
    this.advanceAmount = 0,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.kitchen = 0,
    this.builtYear = 0,
    this.description,
    this.documents = const [],
    this.imageUrl = 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=600&h=300&auto=format&fit=crop',
    this.city = 'Unknown',
    this.landlordId = '',
    this.landlordName = 'N/A',
    this.landlordPhone,
    this.landlordEmail,
    this.tenantIds = const [],
    this.primaryTenantName,
    this.primaryTenantPhone,
    this.primaryTenantEmail,
    this.tenantJoinedDate,
    this.serviceRequestCounts = const {},
    this.serviceRequestMessages = const {},
    this.propertyType = 'Apartment',
    this.totalUnits = 1,
    this.occupiedUnits = 0,
    required this.createdAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final addr = PropertyAddress.fromJson(json['address'] ?? {});
    return PropertyModel(
      id: json['propertyId'] ?? '',
      name: json['name'] ?? '',
      address: addr,
      isOwner: json['isOwner'] ?? true,
      status: _parseStatus(json['status']),
      rentAmount: (json['rent'] as num?)?.toDouble() ?? 0.0,
      advanceAmount: (json['advance'] as num?)?.toDouble() ?? 0.0,
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      kitchen: json['kitchen'] ?? 0,
      builtYear: json['builtYear'] ?? 0,
      description: json['description'],
      documents: json['documents'] ?? [],
      imageUrl: (json['images'] != null && (json['images'] as List).isNotEmpty)
          ? json['images'][0]
          : [
              'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=600&h=300&auto=format&fit=crop',
              'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=600&h=300&auto=format&fit=crop',
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&h=300&auto=format&fit=crop',
              'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&h=300&auto=format&fit=crop',
              'https://images.unsplash.com/photo-1600607687940-c52af096999a?q=80&w=600&h=300&auto=format&fit=crop',
            ][(json['propertyId']?.hashCode ?? 0) % 5],
      createdAt: DateTime.now(),
      city: addr.address.split(',').last.trim(),
    );
  }

  static PropertyStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'rented': return PropertyStatus.rented;
      case 'available': return PropertyStatus.available;
      case 'booked': return PropertyStatus.booked;
      case 'requested': return PropertyStatus.requested;
      case 'maintenance': return PropertyStatus.maintenance;
      default: return PropertyStatus.available;
    }
  }

  bool get isRented => status == PropertyStatus.rented;
  
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
