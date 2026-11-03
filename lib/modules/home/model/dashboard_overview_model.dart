class DashboardOverviewModel {
  final int registeredUsersCount;
  final int landlordCount;
  final int tenantCount;
  final int activeSupportCount;
  final int contactOwnerCount;
  final int rentalAgreementCount;

  DashboardOverviewModel({
    required this.registeredUsersCount,
    required this.landlordCount,
    required this.tenantCount,
    required this.activeSupportCount,
    required this.contactOwnerCount,
    required this.rentalAgreementCount,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    final users = json['registeredUsers'];
    final tickets = json['supportTickets'];
    final agreements = json['rentalAgreements'];

    return DashboardOverviewModel(
      registeredUsersCount: asInt(
        users is Map ? users['totalRegisteredUsersCount'] : null,
      ),
      landlordCount: asInt(
        users is Map ? users['totalLandlordsCount'] : null,
      ),
      tenantCount: asInt(
        users is Map ? users['totalTenantsCount'] : null,
      ),
      activeSupportCount: asInt(
        tickets is Map ? tickets['activeSupportTicketsCount'] : null,
      ),
      contactOwnerCount: asInt(json['totalContactOwnersCount']),
      rentalAgreementCount: asInt(
        agreements is Map ? agreements['totalRentalAgreementsCount'] : null,
      ),
    );
  }
}
