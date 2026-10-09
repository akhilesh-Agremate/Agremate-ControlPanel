import 'dart:convert';
import 'package:agremate_admin/core/utils/app_logger.dart';

enum PropertyStatus { rented, available, booked, requested, maintenance, unknown }

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
  final List<String> images;
  final String? imageUrl;
  final String city;
  final String landlordId;
  final String landlordName;
  final String? landlordPhone;
  final String? landlordEmail;
  final String? landlordAddress;
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
  final Map<String, dynamic> rawJson;
  final List<Map<String, String>> amenitiesList;
  final DateTime? tenancyStartDate;
  final String? agreementId;
  final DateTime? agreementStartDate;
  final int? agreementPeriodMonths;
  final double? agreementRentAmount;

  final String category;
  final int? totalRooms;
  final int? totalBeds;
  final int? availableBeds;

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
    this.images = const <String>[],
    this.imageUrl,
    this.city = 'Unknown',
    this.landlordId = '',
    this.landlordName = 'N/A',
    this.landlordPhone,
    this.landlordEmail,
    this.landlordAddress,
    this.tenantIds = const <String>[],
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
    this.rawJson = const {},
    this.amenitiesList = const [],
    this.tenancyStartDate,
    this.agreementId,
    this.agreementStartDate,
    this.agreementPeriodMonths,
    this.agreementRentAmount,
    this.category = '',
    this.totalRooms,
    this.totalBeds,
    this.availableBeds,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    try {
      PropertyAddress addr;
      final rawAddr = json['address'];
      if (rawAddr is String) {
        try {
          addr = PropertyAddress.fromJson(jsonDecode(rawAddr) as Map<String, dynamic>);
        } catch (_) {
          addr = PropertyAddress(
            address: rawAddr,
            latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
          );
        }
      } else if (rawAddr is Map<String, dynamic>) {
        addr = PropertyAddress.fromJson(rawAddr);
      } else {
        addr = PropertyAddress.fromJson(
          json['placeDetails'] as Map<String, dynamic>? ?? {},
        );
      }

      final landlordObj = json['landlord'] as Map<String, dynamic>?;
      final landlordId   = landlordObj?['id']?.toString() ?? json['landlordId']?.toString() ?? '';
      final landlordName = landlordObj?['name']?.toString() ?? json['landlordName']?.toString() ?? json['ownerName']?.toString() ?? 'N/A';
      final landlordPhone = landlordObj?['phone']?.toString() ?? json['landlordPhone']?.toString();
      final landlordEmail = landlordObj?['email']?.toString() ?? json['landlordEmail']?.toString();
      final landlordAddress = landlordObj?['address']?.toString();
      final tenantObj = json['tenant'] as Map<String, dynamic>?;
      final tenantId = tenantObj?['id']?.toString() ?? json['tenantId']?.toString() ?? '';
      final tenantIds = json['tenantIds'] is List
          ? List<String>.from((json['tenantIds'] as List).map((e) => e.toString()))
          : (tenantId.isNotEmpty ? <String>[tenantId] : <String>[]);
      final tenantName  = tenantObj?['name']?.toString() ?? json['tenantName']?.toString() ?? json['primaryTenantName']?.toString();
      final tenantPhone = tenantObj?['phoneNumber']?.toString() ??
          tenantObj?['phone']?.toString() ??
          json['primaryTenantPhone']?.toString();
      final tenantEmail = tenantObj?['email']?.toString() ?? json['primaryTenantEmail']?.toString();
      DateTime? tenancyStart;
      if (tenantObj?['tenancyStartDate'] != null) {
        tenancyStart = DateTime.tryParse(tenantObj!['tenancyStartDate'].toString());
      }

      final rawAmenities = json['amenities'] as List<dynamic>?;
      final amenitiesList = rawAmenities
          ?.map((a) => {
                'name':    (a['name'] ?? '').toString(),
                'type':    (a['type'] ?? '').toString(),
                'details': (a['details'] ?? '').toString(),
              })
          .toList() ?? <Map<String, String>>[];

      final agreementObj = json['agreement'] as Map<String, dynamic>?;
      final agreementId          = agreementObj?['id']?.toString();
      final agreementStartDate   = agreementObj?['startDate'] != null ? DateTime.tryParse(agreementObj!['startDate'].toString()) : null;
      final agreementPeriodMonths = (agreementObj?['periodMonths'] as num?)?.toInt();
      final agreementRentAmount   = (agreementObj?['rentAmount'] as num?)?.toDouble();

      final thumbnailUrl = _resolveMediaUrl(json['thumbnailUrl']?.toString());
      final images = json['images'] != null
          ? List<String>.from((json['images'] as List).map((e) => _resolveMediaUrl(e.toString())))
              .where((url) => url.isNotEmpty)
              .toList()
          : <String>[];
      if (thumbnailUrl.isNotEmpty && !images.contains(thumbnailUrl)) {
        images.insert(0, thumbnailUrl);
      }

      return PropertyModel(
        id: json['propertyId']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? json['propertyName']?.toString() ?? 'Unnamed Property',
        address: addr,
        isOwner: json['isOwner'] ?? true,
        status: _parseStatus(json['status']?.toString()),
        rentAmount:
            (json['rentAmount'] as num?)?.toDouble() ??
            (json['rent'] as num?)?.toDouble() ??
            (json['price'] as num?)?.toDouble() ??
            0.0,
        advanceAmount:
            (json['advanceAmount'] as num?)?.toDouble() ??
            (json['advance'] as num?)?.toDouble() ??
            0.0,
        bedrooms:  (json['bedrooms'] as num?)?.toInt() ?? 0,
        bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
        kitchen:   (json['kitchen'] as num?)?.toInt() ?? 0,
        builtYear: (json['builtYear'] as num?)?.toInt() ?? 0,
        description: json['description']?.toString(),
        documents: json['documents'] ?? [],
        images: images,
        imageUrl: images.isNotEmpty ? images[0] : null,
        createdAt: DateTime.now(),
        city: addr.address.split(',').lastWhere((s) => s.trim().isNotEmpty, orElse: () => '').trim(),
        landlordId: landlordId,
        landlordName: landlordName,
        landlordPhone: landlordPhone,
        landlordEmail: landlordEmail,
        landlordAddress: landlordAddress,
        tenantIds: tenantIds,
        primaryTenantName: tenantName,
        primaryTenantPhone: tenantPhone,
        primaryTenantEmail: tenantEmail,
        tenantJoinedDate: tenancyStart,
        rawJson: json,
        amenitiesList: amenitiesList,
        tenancyStartDate: tenancyStart,
        agreementId: agreementId,
        agreementStartDate: agreementStartDate,
        agreementPeriodMonths: agreementPeriodMonths,
        agreementRentAmount: agreementRentAmount,
        propertyType: json['propertyType']?.toString() ?? 'Apartment',
        category: json['category']?.toString() ??
            json['propertyCategory']?.toString() ??
            '',
        totalRooms: (json['totalRooms'] as num?)?.toInt(),
        totalBeds: (json['totalBeds'] as num?)?.toInt(),
        availableBeds: (json['availableBeds'] as num?)?.toInt(),
      );
    } catch (e, stack) {
      AppLogger.e('PropertyModel', 'fromJson failed', e, stack);
      rethrow;
    }
  }

  static const String _mediaBaseUrl =
      'https://amplify-agremate-dev-76a83-deployment.s3.ap-south-1.amazonaws.com/';

  static String _resolveMediaUrl(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty || value.toLowerCase() == 'null') return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    return '$_mediaBaseUrl${value.startsWith('/') ? value.substring(1) : value}';
  }

  static PropertyStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'rented':
        return PropertyStatus.rented;
      case 'available':
        return PropertyStatus.available;
      case 'booked':
        return PropertyStatus.booked;
      case 'requested':
        return PropertyStatus.requested;
      case 'maintenance':
        return PropertyStatus.maintenance;
      default:
        return PropertyStatus.unknown;
    }
  }

  bool get isRented => status == PropertyStatus.rented;

  bool get isPg {
    final cat = category.trim().toLowerCase();
    final pType = propertyType.trim().toLowerCase();
    return cat == 'pg' ||
        pType == 'pg' ||
        pType == '3' ||
        pType.contains('pg') ||
        (totalBeds != null && totalBeds! > 0) ||
        (totalRooms != null && totalRooms! > 0);
  }

  bool get isIndividual {
    final cat = category.trim().toLowerCase();
    final pType = propertyType.trim().toLowerCase();
    if (isPg) return false;
    return cat == 'residential' ||
        cat == 'individual' ||
        cat.isEmpty ||
        (pType != 'pg' && pType != '3');
  }

  String get propertyTypeLabel {
    switch (propertyType.trim()) {
      case '0':
        return 'Apartment';
      case '1':
        return 'House';
      case '2':
        return 'Villa';
      case '3':
        return 'PG';
      default:
        return propertyType.isEmpty ? 'Apartment' : propertyType;
    }
  }

  String get statusLabel {
    switch (status) {
      case PropertyStatus.rented:
        return 'Rented';
      case PropertyStatus.available:
        return 'Available';
      case PropertyStatus.booked:
        return 'Booked';
      case PropertyStatus.requested:
        return 'Requested';
      case PropertyStatus.maintenance:
        return 'Maintenance';
      case PropertyStatus.unknown:
        return 'Unknown';
    }
  }
}
