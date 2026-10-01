class PropertyStatsModel {
  final int totalProperties;
  final int rentedCount;
  final int availableCount;
  final int maintenanceCount;
  final int totalLandlords;
  final int activeLandlordCount;
  final int totalTenants;
  final int tenantsAcrossProperties;
  final num totalRevenue;

  const PropertyStatsModel({
    required this.totalProperties,
    required this.rentedCount,
    required this.availableCount,
    required this.maintenanceCount,
    required this.totalLandlords,
    required this.activeLandlordCount,
    required this.totalTenants,
    required this.tenantsAcrossProperties,
    required this.totalRevenue,
  });

  factory PropertyStatsModel.empty() => const PropertyStatsModel(
        totalProperties: 0,
        rentedCount: 0,
        availableCount: 0,
        maintenanceCount: 0,
        totalLandlords: 0,
        activeLandlordCount: 0,
        totalTenants: 0,
        tenantsAcrossProperties: 0,
        totalRevenue: 0,
      );

  factory PropertyStatsModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) => ((value ?? 0) as num).toInt();
    num asNum(dynamic value) => (value ?? 0) as num;

    return PropertyStatsModel(
      totalProperties: asInt(json['totalProperties']),
      rentedCount: asInt(json['rentedCount']),
      availableCount: asInt(json['availableCount']),
      maintenanceCount: asInt(json['maintenanceCount']),
      totalLandlords: asInt(json['totalLandlords']),
      activeLandlordCount: asInt(json['activeLandlordCount']),
      totalTenants: asInt(json['totalTenants']),
      tenantsAcrossProperties: asInt(json['tenantsAcrossProperties']),
      totalRevenue: asNum(json['totalRevenue']),
    );
  }
}
