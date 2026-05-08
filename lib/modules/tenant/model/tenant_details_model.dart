class TenantDetailsModel {
  final int propertyCount;
  final int ownerCount;
  final int tenantCount;
  final bool isVerified;
  final bool isEmailExists;
  final bool isPhoneNumberExists;
  final String? profileUrl;
  final UserRoleModel userRole;
  final List<SocialPropertyModel> socialProperties;

  TenantDetailsModel({
    required this.propertyCount,
    required this.ownerCount,
    required this.tenantCount,
    required this.isVerified,
    required this.isEmailExists,
    required this.isPhoneNumberExists,
    this.profileUrl,
    required this.userRole,
    required this.socialProperties,
  });

  factory TenantDetailsModel.fromJson(Map<String, dynamic> json) {
    return TenantDetailsModel(
      propertyCount: json['propertyCount'] ?? 0,
      ownerCount: json['ownerCount'] ?? 0,
      tenantCount: json['tenantCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isEmailExists: json['isEmailExists'] ?? false,
      isPhoneNumberExists: json['isPhoneNumberExists'] ?? false,
      profileUrl: json['profileUrl'],
      userRole: UserRoleModel.fromJson(json['userRole'] ?? {}),
      socialProperties: (json['socialProperties'] as List? ?? [])
          .map((e) => SocialPropertyModel.fromJson(e))
          .toList(),
    );
  }
}

class UserRoleModel {
  final String roleId;
  final RoleInfoModel roles;
  final String userId;
  final UserInfoModel users;

  UserRoleModel({
    required this.roleId,
    required this.roles,
    required this.userId,
    required this.users,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      roleId: json['roleId'] ?? '',
      roles: RoleInfoModel.fromJson(json['roles'] ?? {}),
      userId: json['userId'] ?? '',
      users: UserInfoModel.fromJson(json['users'] ?? {}),
    );
  }
}

class RoleInfoModel {
  final String name;
  final String description;
  final String id;

  RoleInfoModel({
    required this.name,
    required this.description,
    required this.id,
  });

  factory RoleInfoModel.fromJson(Map<String, dynamic> json) {
    return RoleInfoModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      id: json['id'] ?? '',
    );
  }
}

class UserInfoModel {
  final String id;
  final String agremateId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? fullAddress;
  final List<FamilyMemberModel> familyMembers;
  final List<VehicleModel> vehicles;

  UserInfoModel({
    required this.id,
    required this.agremateId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.fullAddress,
    required this.familyMembers,
    required this.vehicles,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'] ?? '',
      agremateId: json['agremateId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      fullAddress: json['fullAddress'],
      familyMembers: (json['familyMembers'] as List? ?? [])
          .map((e) => FamilyMemberModel.fromJson(e))
          .toList(),
      vehicles: (json['vehicles'] as List? ?? [])
          .map((e) => VehicleModel.fromJson(e))
          .toList(),
    );
  }
}

class FamilyMemberModel {
  final String id;
  final String name;
  final int age;

  FamilyMemberModel({
    required this.id,
    required this.name,
    required this.age,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
    );
  }
}

class VehicleModel {
  final String id;
  final String type;
  final String model;
  final String number;

  VehicleModel({
    required this.id,
    required this.type,
    required this.model,
    required this.number,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      model: json['model'] ?? '',
      number: json['number'] ?? '',
    );
  }
}

class SocialPropertyModel {
  final String id;
  final String name;
  final String description;
  final String status;
  final double rent;
  final double advance;
  final int bedrooms;
  final int bathrooms;
  final int kitchen;
  final String address;
  final List<SocialPropertyDocument> documents;

  SocialPropertyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.rent,
    required this.advance,
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchen,
    required this.address,
    required this.documents,
  });

  factory SocialPropertyModel.fromJson(Map<String, dynamic> json) {
    final place = json['placeDetails'] ?? {};
    return SocialPropertyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      rent: (json['rent'] as num?)?.toDouble() ?? 0.0,
      advance: (json['advance'] as num?)?.toDouble() ?? 0.0,
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      kitchen: json['kitchen'] ?? 0,
      address: place['Address'] ?? '',
      documents: (json['documents'] as List? ?? [])
          .map((e) => SocialPropertyDocument.fromJson(e))
          .toList(),
    );
  }
}

class SocialPropertyDocument {
  final String id;
  final String fileName;
  final String absolutePath;
  final String thumbnailUrl;

  SocialPropertyDocument({
    required this.id,
    required this.fileName,
    required this.absolutePath,
    required this.thumbnailUrl,
  });

  factory SocialPropertyDocument.fromJson(Map<String, dynamic> json) {
    return SocialPropertyDocument(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      absolutePath: json['absolutePath'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }
}
