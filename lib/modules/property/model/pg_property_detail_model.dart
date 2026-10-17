import 'dart:convert';
import 'package:agremate_admin/modules/property/model/property_model.dart';

class PgPropertyDetailData {
  final String id;
  final String name;
  final String description;
  final String status;
  final String address;
  final String? floorNumber;
  final String? doorNumber;
  final double? latitude;
  final double? longitude;
  final String propertyType;
  final String? zone;
  final int bedrooms;
  final int bathrooms;
  final int kitchen;
  final int builtYear;
  final double rent;
  final double advance;
  final String? contractReference;
  final bool isDeleted;
  final List<String> images;
  final List<String> photoPaths;
  final List<dynamic> amenities;
  final List<String> amenityLabels;
  final PgLandlord? landlord;
  final Map<String, dynamic>? tenant;
  final Map<String, dynamic>? agreement;
  final List<PgDocument> documents;
  final PgDetails? pgDetails;
  final List<PgFloor> floors;
  final Map<String, dynamic> rawJson;

  PgPropertyDetailData({
    required this.id,
    required this.name,
    this.description = '',
    this.status = 'Available',
    this.address = '',
    this.floorNumber,
    this.doorNumber,
    this.latitude,
    this.longitude,
    this.propertyType = 'PG',
    this.zone,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.kitchen = 0,
    this.builtYear = 0,
    this.rent = 0,
    this.advance = 0,
    this.contractReference,
    this.isDeleted = false,
    this.images = const [],
    this.photoPaths = const [],
    this.amenities = const [],
    this.amenityLabels = const [],
    this.landlord,
    this.tenant,
    this.agreement,
    this.documents = const [],
    this.pgDetails,
    this.floors = const [],
    this.rawJson = const {},
  });

  static const String mediaBaseUrl =
      'https://amplify-agremate-dev-76a83-deployment.s3.ap-south-1.amazonaws.com/';

  static String resolveUrl(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty || value.toLowerCase() == 'null') return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    return '$mediaBaseUrl${value.startsWith('/') ? value.substring(1) : value}';
  }

  factory PgPropertyDetailData.fromJson(Map<String, dynamic> json) {
    final place = json['placeDetails'] is Map
        ? Map<String, dynamic>.from(json['placeDetails'])
        : <String, dynamic>{};

    final imagesList = <String>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final item in rawImages) {
        String u = '';
        if (item is Map) {
          u = (item['originalUrl'] ??
                  item['absolutePath'] ??
                  item['fileUrl'] ??
                  item['url'] ??
                  item['relativePath'] ??
                  '')
              .toString();
        } else if (item != null) {
          u = item.toString();
        }
        final resolved = resolveUrl(u);
        if (resolved.isNotEmpty && !imagesList.contains(resolved)) {
          imagesList.add(resolved);
        }
      }
    }

    final docsList = (json['documents'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((d) => PgDocument.fromJson(Map<String, dynamic>.from(d)))
        .toList();

    final allPhotos = <String>[...imagesList];
    for (final doc in docsList) {
      if (doc.isPhoto && doc.fileUrl.isNotEmpty && !allPhotos.contains(doc.fileUrl)) {
        allPhotos.add(doc.fileUrl);
      }
    }

    final rawAmenities = json['amenities'] as List<dynamic>? ?? [];
    final amenityLabels = <String>[];
    for (final a in rawAmenities) {
      if (a is Map) {
        final name = (a['name'] ?? a['amenityName'] ?? '').toString().trim();
        if (name.isNotEmpty) amenityLabels.add(name);
      } else if (a is String && a.trim().isNotEmpty) {
        amenityLabels.add(a.trim());
      }
    }

    var floorsRaw = json['floors'];
    if ((floorsRaw is! List || floorsRaw.isEmpty) && json['pgDetails'] is Map) {
      floorsRaw = (json['pgDetails'] as Map)['floors'];
    }
    final floorsList = (floorsRaw as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((f) => PgFloor.fromJson(Map<String, dynamic>.from(f)))
        .toList();

    final pgDetailsObj = json['pgDetails'] is Map
        ? PgDetails.fromJson(Map<String, dynamic>.from(json['pgDetails']))
        : null;

    final landlordObj = json['landlord'] is Map
        ? PgLandlord.fromJson(Map<String, dynamic>.from(json['landlord']))
        : null;

    for (final fl in floorsList) {
      for (final rm in fl.rooms) {
        for (final am in rm.amenitiesList) {
          if (!amenityLabels.contains(am)) {
            amenityLabels.add(am);
          }
        }
      }
    }

    String resolvedAddress = (place['address'] ?? json['address'] ?? '').toString();
    double? lat = (place['latitude'] as num?)?.toDouble() ??
        (json['latitude'] as num?)?.toDouble();
    double? lng = (place['longitude'] as num?)?.toDouble() ??
        (json['longitude'] as num?)?.toDouble();

    if (resolvedAddress.trim().startsWith('{') && resolvedAddress.trim().endsWith('}')) {
      try {
        final decoded = jsonDecode(resolvedAddress) as Map<String, dynamic>;
        resolvedAddress = (decoded['Address'] ?? decoded['address'] ?? resolvedAddress).toString();
        lat ??= (decoded['Latitude'] as num?)?.toDouble();
        lng ??= (decoded['Longitude'] as num?)?.toDouble();
      } catch (_) {}
    }

    return PgPropertyDetailData(
      id: (json['id'] ?? json['propertyId'] ?? '').toString(),
      name: (json['name'] ?? json['propertyName'] ?? 'PG Property').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'Available').toString(),
      address: resolvedAddress,
      floorNumber: (place['floor'] ?? json['floor'] ?? json['floorNumber'])
          ?.toString(),
      doorNumber: (place['doorNumber'] ?? json['doorNumber'])?.toString(),
      latitude: lat,
      longitude: lng,
      propertyType: (json['propertyType'] ?? 'PG').toString(),
      zone: json['zone']?.toString(),
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      kitchen: (json['kitchen'] as num?)?.toInt() ?? 0,
      builtYear: (json['builtYear'] as num?)?.toInt() ?? 0,
      rent: (json['rent'] as num?)?.toDouble() ??
          (json['rentAmount'] as num?)?.toDouble() ??
          0.0,
      advance: (json['advance'] as num?)?.toDouble() ??
          (json['advanceAmount'] as num?)?.toDouble() ??
          0.0,
      contractReference: json['contractReference']?.toString(),
      isDeleted: json['isDeleted'] == true,
      images: imagesList,
      photoPaths: allPhotos,
      amenities: rawAmenities,
      amenityLabels: amenityLabels,
      landlord: landlordObj,
      tenant: json['tenant'] is Map ? Map<String, dynamic>.from(json['tenant']) : null,
      agreement: json['agreement'] is Map ? Map<String, dynamic>.from(json['agreement']) : null,
      documents: docsList,
      pgDetails: pgDetailsObj,
      floors: floorsList,
      rawJson: json,
    );
  }

  factory PgPropertyDetailData.fromPropertyModel(PropertyModel model) {
    if (model.rawJson.isNotEmpty) {
      try {
        return PgPropertyDetailData.fromJson(model.rawJson);
      } catch (_) {}
    }

    return PgPropertyDetailData(
      id: model.id,
      name: model.name,
      description: model.description ?? '',
      status: model.statusLabel,
      address: model.address.address,
      latitude: model.address.latitude,
      longitude: model.address.longitude,
      propertyType: model.propertyTypeLabel,
      bedrooms: model.bedrooms,
      bathrooms: model.bathrooms,
      kitchen: model.kitchen,
      builtYear: model.builtYear,
      rent: model.rentAmount,
      advance: model.advanceAmount,
      images: model.images,
      photoPaths: model.images,
      amenities: model.amenitiesList,
      amenityLabels: model.amenitiesList.map((a) => a['name'] ?? '').where((s) => s.isNotEmpty).toList(),
      landlord: PgLandlord(
        id: model.landlordId,
        userId: model.landlordId,
        name: model.landlordName,
        phone: model.landlordPhone ?? '',
        email: model.landlordEmail ?? '',
        address: model.landlordAddress ?? '',
      ),
      rawJson: model.rawJson,
    );
  }

  String get pgType => pgDetails?.pgType.isNotEmpty == true ? pgDetails!.pgType : 'Co-ed';
  String get genderAllowed => pgDetails?.genderAllowed.isNotEmpty == true ? pgDetails!.genderAllowed : 'Any';

  List<String> get houseRules => pgDetails?.houseRules ?? const [];
  dynamic get rentPaymentDate => pgDetails?.rentPaymentDate;

  int get totalFloors => floors.length;

  int get totalRooms {
    if (pgDetails != null && pgDetails!.totalRooms > 0) return pgDetails!.totalRooms;
    int count = 0;
    for (final f in floors) {
      count += f.rooms.length;
    }
    return count > 0 ? count : (bedrooms > 0 ? bedrooms : 1);
  }

  int get totalBeds {
    if (pgDetails != null && pgDetails!.totalBeds > 0) return pgDetails!.totalBeds;
    int count = 0;
    for (final f in floors) {
      count += f.totalBeds;
    }
    return count;
  }

  int get occupiedBeds {
    if (pgDetails != null && pgDetails!.occupiedBeds > 0) return pgDetails!.occupiedBeds;
    int count = 0;
    for (final f in floors) {
      count += f.occupiedBeds;
    }
    return count;
  }

  int get availableBeds {
    if (pgDetails != null && pgDetails!.availableBeds > 0) return pgDetails!.availableBeds;
    int count = 0;
    for (final f in floors) {
      count += f.availableBeds;
    }
    if (count > 0) return count;
    return totalBeds >= occupiedBeds ? (totalBeds - occupiedBeds) : 0;
  }

  String get roomType {
    for (final f in floors) {
      for (final r in f.rooms) {
        if (r.roomTypeLabel.isNotEmpty) return r.roomTypeLabel;
      }
    }
    return 'Single';
  }

  String get rentPerBed {
    for (final f in floors) {
      for (final r in f.rooms) {
        if (r.rentPerBed > 0) return r.rentPerBed.toInt().toString();
        if (r.rent > 0) return r.rent.toInt().toString();
      }
    }
    if (rent > 0) return rent.toInt().toString();
    return '';
  }

  String get displayRentPerBed => rentPerBed;

  List<PgBed> get allOccupiedBeds {
    final list = <PgBed>[];
    for (final f in floors) {
      for (final r in f.rooms) {
        for (final b in r.beds) {
          if (b.isOccupied) list.add(b);
        }
      }
    }
    return list;
  }
}

class PgDetails {
  final String pgType;
  final String genderAllowed;
  final int totalRooms;
  final int totalBeds;
  final int availableBeds;
  final int occupiedBeds;
  final dynamic rentPaymentDate;
  final List<String> houseRules;

  PgDetails({
    this.pgType = 'Co-ed',
    this.genderAllowed = 'Any',
    this.totalRooms = 0,
    this.totalBeds = 0,
    this.availableBeds = 0,
    this.occupiedBeds = 0,
    this.rentPaymentDate,
    this.houseRules = const [],
  });

  factory PgDetails.fromJson(Map<String, dynamic> json) {
    final rulesRaw = json['houseRules'] as List<dynamic>? ?? [];
    final rules = rulesRaw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();

    return PgDetails(
      pgType: (json['pgType'] ?? 'Co-ed').toString(),
      genderAllowed: (json['genderAllowed'] ?? 'Any').toString(),
      totalRooms: (json['totalRooms'] as num?)?.toInt() ?? 0,
      totalBeds: (json['totalBeds'] as num?)?.toInt() ?? 0,
      availableBeds: (json['availableBeds'] as num?)?.toInt() ?? 0,
      occupiedBeds: (json['occupiedBeds'] as num?)?.toInt() ?? 0,
      rentPaymentDate: json['rentPaymentDate'],
      houseRules: rules,
    );
  }
}

class PgFloor {
  final String? floorId;
  final int index;
  final String floorName;
  final List<PgRoom> rooms;

  PgFloor({
    this.floorId,
    required this.index,
    required this.floorName,
    this.rooms = const [],
  });

  factory PgFloor.fromJson(Map<String, dynamic> json) {
    final rawRooms = (json['rooms'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((r) => PgRoom.fromJson(Map<String, dynamic>.from(r)))
        .toList();

    return PgFloor(
      floorId: json['floorId']?.toString(),
      index: (json['index'] as num?)?.toInt() ?? 1,
      floorName: (json['floorName'] ?? 'Floor 1').toString(),
      rooms: rawRooms,
    );
  }

  int get totalBeds {
    int count = 0;
    for (final r in rooms) {
      count += r.totalBeds > 0 ? r.totalBeds : r.beds.length;
    }
    return count;
  }

  int get occupiedBeds {
    int count = 0;
    for (final r in rooms) {
      count += r.beds.where((b) => b.isOccupied).length;
    }
    return count;
  }

  int get availableBeds {
    int count = 0;
    for (final r in rooms) {
      final avail = r.beds.where((b) => b.isAvailable).length;
      count += avail > 0 ? avail : (r.availableBeds > 0 ? r.availableBeds : (r.totalBeds - r.beds.where((b) => b.isOccupied).length));
    }
    return count;
  }
}

class PgRoom {
  final String id;
  final String unitId;
  final int index;
  final dynamic roomType;
  final dynamic unitType;
  final double rentPerBed;
  final double rent;
  final String roomName;
  final String name;
  final int totalBeds;
  final int availableBeds;
  final String? floorId;
  final String? floorName;
  final List<String> amenitiesList;
  final List<PgBed> beds;
  final List<PgRoomImage> images;

  PgRoom({
    required this.id,
    this.unitId = '',
    this.index = 1,
    this.roomType,
    this.unitType,
    this.rentPerBed = 0,
    this.rent = 0,
    this.roomName = 'Room',
    this.name = 'Room',
    this.totalBeds = 0,
    this.availableBeds = 0,
    this.floorId,
    this.floorName,
    this.amenitiesList = const [],
    this.beds = const [],
    this.images = const [],
  });

  factory PgRoom.fromJson(Map<String, dynamic> json) {
    final rawBeds = (json['beds'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((b) => PgBed.fromJson(Map<String, dynamic>.from(b)))
        .toList();

    final rawImages = (json['images'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((img) => PgRoomImage.fromJson(Map<String, dynamic>.from(img)))
        .toList();

    final rawAmenities = json['amenitiesList'] as List<dynamic>? ?? [];
    final amenities = <String>[];
    for (final a in rawAmenities) {
      if (a is Map) {
        final n = (a['name'] ?? a['amenityName'] ?? '').toString().trim();
        if (n.isNotEmpty) amenities.add(n);
      } else if (a is String && a.trim().isNotEmpty) {
        amenities.add(a.trim());
      }
    }

    final rName = (json['roomName'] ?? json['name'] ?? 'Room').toString();

    return PgRoom(
      id: (json['id'] ?? json['unitId'] ?? '').toString(),
      unitId: (json['unitId'] ?? json['id'] ?? '').toString(),
      index: (json['index'] as num?)?.toInt() ?? 1,
      roomType: json['roomType'],
      unitType: json['unitType'],
      rentPerBed: (json['rentPerBed'] as num?)?.toDouble() ??
          (json['rent'] as num?)?.toDouble() ??
          0.0,
      rent: (json['rent'] as num?)?.toDouble() ??
          (json['rentPerBed'] as num?)?.toDouble() ??
          0.0,
      roomName: rName,
      name: rName,
      totalBeds: (json['totalBeds'] as num?)?.toInt() ?? rawBeds.length,
      availableBeds: (json['availableBeds'] as num?)?.toInt() ??
          rawBeds.where((b) => b.isAvailable).length,
      floorId: json['floorId']?.toString(),
      floorName: json['floorName']?.toString(),
      amenitiesList: amenities,
      beds: rawBeds,
      images: rawImages,
    );
  }

  String get roomTypeLabel {
    final type = roomType ?? unitType;
    if (type == null) {
      if (totalBeds == 1) return 'Single';
      if (totalBeds == 2) return 'Double Sharing';
      if (totalBeds == 3) return 'Triple Sharing';
      if (totalBeds > 3) return '$totalBeds Sharing';
      return 'Single';
    }
    if (type is int || (type is String && int.tryParse(type) != null)) {
      final code = type is int ? type : int.parse(type as String);
      switch (code) {
        case 1:
          return 'Single';
        case 2:
          return 'Double Sharing';
        case 3:
          return 'Triple Sharing';
        case 4:
          return 'Four Sharing';
        default:
          return '$code Sharing';
      }
    }
    return type.toString();
  }

  int get occupiedBeds {
    final occ = beds.where((b) => b.isOccupied).length;
    if (occ > 0) return occ;
    final total = totalBeds > 0 ? totalBeds : beds.length;
    final avail = availableBeds;
    if (total > 0 && avail >= 0 && total >= avail) return total - avail;
    return occ;
  }
}

class PgBed {
  final String id;
  final String bedId;
  final String unitId;
  final int index;
  final String bedNumber;
  int status;
  final double rent;
  final double rentAmount;
  final double? advance;
  final String? pgTenantRoomId;
  String? tenantName;
  String? tenantPhone;
  String? tenantEmail;
  String? joinDate;
  final Map<String, dynamic>? tenant;

  PgBed({
    required this.id,
    this.bedId = '',
    this.unitId = '',
    this.index = 1,
    this.bedNumber = 'Bed',
    this.status = 0,
    this.rent = 0,
    this.rentAmount = 0,
    this.advance,
    this.pgTenantRoomId,
    this.tenantName,
    this.tenantPhone,
    this.tenantEmail,
    this.joinDate,
    this.tenant,
  });

  factory PgBed.fromJson(Map<String, dynamic> json) {
    final tMap = json['tenant'] is Map ? Map<String, dynamic>.from(json['tenant']) : null;
    final tName = json['tenantName']?.toString() ?? tMap?['name']?.toString();
    final tPhone = json['tenantPhone']?.toString() ?? tMap?['phone']?.toString();
    final tEmail = json['tenantEmail']?.toString() ?? tMap?['email']?.toString();

    return PgBed(
      id: (json['id'] ?? json['bedId'] ?? '').toString(),
      bedId: (json['bedId'] ?? json['id'] ?? '').toString(),
      unitId: (json['unitId'] ?? '').toString(),
      index: (json['index'] as num?)?.toInt() ?? 1,
      bedNumber: (json['bedNumber'] ?? 'Bed').toString(),
      status: (json['status'] as num?)?.toInt() ?? 0,
      rent: (json['rent'] as num?)?.toDouble() ??
          (json['rentAmount'] as num?)?.toDouble() ??
          0.0,
      rentAmount: (json['rentAmount'] as num?)?.toDouble() ??
          (json['rent'] as num?)?.toDouble() ??
          0.0,
      advance: (json['advance'] as num?)?.toDouble(),
      pgTenantRoomId: json['pgTenantRoomId']?.toString(),
      tenantName: tName?.isNotEmpty == true ? tName : null,
      tenantPhone: tPhone?.isNotEmpty == true ? tPhone : null,
      tenantEmail: tEmail?.isNotEmpty == true ? tEmail : null,
      joinDate: json['joinDate']?.toString(),
      tenant: tMap,
    );
  }

  bool get isOccupied => status == 1 || (tenantName != null && tenantName!.trim().isNotEmpty);
  bool get isAvailable => !isOccupied && status == 0;
  String get statusLabel {
    if (isOccupied) return 'Occupied';
    if (status == 2) return 'Maintenance';
    return 'Available';
  }
}

class PgRoomImage {
  final String? documentDetailId;
  final String? propertyImageId;
  final String url;
  final String thumbnailUrl;
  final int displayOrder;

  PgRoomImage({
    this.documentDetailId,
    this.propertyImageId,
    required this.url,
    this.thumbnailUrl = '',
    this.displayOrder = 0,
  });

  factory PgRoomImage.fromJson(Map<String, dynamic> json) {
    return PgRoomImage(
      documentDetailId: json['documentDetailId']?.toString(),
      propertyImageId: json['propertyImageId']?.toString(),
      url: PgPropertyDetailData.resolveUrl(json['url']?.toString()),
      thumbnailUrl: PgPropertyDetailData.resolveUrl(
        json['thumbnailUrl']?.toString() ?? json['url']?.toString(),
      ),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class PgDocument {
  final String id;
  final String? documentDetailId;
  final String documentName;
  final String documentType;
  final String category;
  final String fileUrl;
  final String? thumbnailUrl;
  final String? uploadedDate;
  final String? status;
  final Map<String, dynamic>? uploadedBy;

  String get name => documentName;

  PgDocument({
    required this.id,
    this.documentDetailId,
    required this.documentName,
    this.documentType = '',
    this.category = '',
    required this.fileUrl,
    this.thumbnailUrl,
    this.uploadedDate,
    this.status,
    this.uploadedBy,
  });

  factory PgDocument.fromJson(Map<String, dynamic> json) {
    final rawFileUrl = json['fileUrl']?.toString() ??
        json['url']?.toString() ??
        json['relativePath']?.toString() ??
        '';
    final resolvedFile = PgPropertyDetailData.resolveUrl(rawFileUrl);

    final rawThumb = json['thumbnailUrl']?.toString();
    final resolvedThumb = rawThumb != null && rawThumb.isNotEmpty
        ? PgPropertyDetailData.resolveUrl(rawThumb)
        : null;

    return PgDocument(
      id: (json['id'] ?? '').toString(),
      documentDetailId: json['documentDetailId']?.toString(),
      documentName: (json['documentName'] ?? json['name'] ?? json['fileName'] ?? 'Document').toString(),
      documentType: (json['documentType'] ?? json['type'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      fileUrl: resolvedFile,
      thumbnailUrl: resolvedThumb,
      uploadedDate: json['uploadedDate']?.toString(),
      status: json['status']?.toString(),
      uploadedBy: json['uploadedBy'] is Map ? Map<String, dynamic>.from(json['uploadedBy']) : null,
    );
  }

  bool get isPhoto {
    final type = documentType.toLowerCase();
    final cat = category.toLowerCase();
    final name = documentName.toLowerCase();
    return type.contains('image') ||
        type.contains('photo') ||
        cat.contains('photo') ||
        cat.contains('image') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp');
  }

  bool get isPdf =>
      fileUrl.toLowerCase().contains('.pdf') ||
      documentName.toLowerCase().endsWith('.pdf');
}

class PgLandlord {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String address;

  PgLandlord({
    required this.id,
    this.userId = '',
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  factory PgLandlord.fromJson(Map<String, dynamic> json) {
    return PgLandlord(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Landlord').toString(),
      phone: (json['phone'] ??
              json['phoneNumber'] ??
              json['mobile'] ??
              json['contactNumber'] ??
              '')
          .toString(),
      email: (json['email'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
    );
  }
}
