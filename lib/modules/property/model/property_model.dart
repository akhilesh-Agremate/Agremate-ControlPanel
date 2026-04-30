class PropertyModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String landlordId;
  final String landlordName;
  final List<String> tenantIds;
  final double rentAmount;
  final String propertyType;
  final int totalUnits;
  final int occupiedUnits;
  final bool isRented;
  final DateTime createdAt;

  PropertyModel({
    required this.id,
    required this.name,
    required this.address,
    this.city = 'Mumbai',
    required this.landlordId,
    required this.landlordName,
    this.tenantIds = const [],
    this.rentAmount = 0,
    this.propertyType = 'Apartment',
    this.totalUnits = 1,
    this.occupiedUnits = 0,
    this.isRented = false,
    required this.createdAt,
  });

  int get tenantCount => tenantIds.length;
  double get occupancyRate => totalUnits > 0 ? occupiedUnits / totalUnits : 0;
}
