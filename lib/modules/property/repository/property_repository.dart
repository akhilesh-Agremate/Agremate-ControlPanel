import 'package:get/get.dart';
import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/model/property_stats_model.dart';
import 'package:agremate_admin/modules/property/model/landlord_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_details_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:agremate_admin/modules/property/view/components/add_property_panel.dart'
    show PickedFile;
import '../model/amenity_model.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class PropertyRepository {
  Future<List<PropertyModel>> getAllProperties({String? category}) async {
    try {
      if (category != null && category.isNotEmpty) {
        final endpoint =
            '${AppEndpoints.adminDashboardProperties}?category=$category';
        final properties = await _fetchPropertyList(endpoint);
        if (!Get.isRegistered<AuthController>()) return properties;
        final auth = Get.find<AuthController>();
        if (!auth.isRestrictedRole) return properties;
        return _filterForCurrentUser(properties, auth);
      }

      try {
        final properties =
            await _fetchPropertyList(AppEndpoints.adminDashboardProperties);
        if (properties.isNotEmpty) {
          if (!Get.isRegistered<AuthController>()) return properties;
          final auth = Get.find<AuthController>();
          if (!auth.isRestrictedRole) return properties;
          return _filterForCurrentUser(properties, auth);
        }
      } catch (e) {
        AppLogger.w('PropertyRepository',
            'Fetch without category failed, falling back to category queries: $e');
      }

      final residentialList = await _fetchPropertyListSafely(
          '${AppEndpoints.adminDashboardProperties}?category=Residential');
      final pgList = await _fetchPropertyListSafely(
          '${AppEndpoints.adminDashboardProperties}?category=PG');

      final combinedMap = <String, PropertyModel>{};
      for (final p in [...residentialList, ...pgList]) {
        combinedMap[p.id] = p;
      }
      final combined = combinedMap.values.toList();
      if (!Get.isRegistered<AuthController>()) return combined;
      final auth = Get.find<AuthController>();
      if (!auth.isRestrictedRole) return combined;
      return _filterForCurrentUser(combined, auth);
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'getAllProperties failed', e, stack);
      rethrow;
    }
  }

  Future<List<PropertyModel>> _fetchPropertyListSafely(String endpoint) async {
    try {
      return await _fetchPropertyList(endpoint);
    } catch (e) {
      AppLogger.w('PropertyRepository', 'Safe fetch failed for $endpoint: $e');
      return [];
    }
  }

  Future<List<PropertyModel>> _fetchPropertyList(String endpoint) async {
    final response = await DioClient.instance.get(endpoint);
    AppLogger.d('PropertyRepository', 'getAllProperties Response status=${response.statusCode}');

    final List<dynamic> result;
    if (response.data is List) {
      result = response.data as List<dynamic>;
    } else if (response.data is Map && response.data['result'] is List) {
      result = response.data['result'] as List<dynamic>;
    } else {
      result = [];
    }

    AppLogger.i('PropertyRepository', 'getAllProperties count=${result.length}');
    return result
        .where((e) => e != null)
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<PropertyModel> _filterForCurrentUser(
      List<PropertyModel> properties,
      AuthController auth,
      ) {
    final userId = auth.userId.value;
    final phone = auth.userPhone.value.replaceAll(' ', '');
    final name = auth.userName.value.trim().toLowerCase();

    bool matchesPhone(String? value) {
      if (value == null || value.isEmpty || phone.isEmpty) return false;
      return value.replaceAll(' ', '') == phone;
    }

    bool matchesName(String? value) {
      if (value == null || value.isEmpty || name.isEmpty) return false;
      return value.trim().toLowerCase() == name;
    }

    return properties.where((p) {
      final isLandlordProperty =
          (userId.isNotEmpty && p.landlordId == userId) ||
              matchesPhone(p.landlordPhone) ||
              matchesName(p.landlordName);
      final isTenantProperty =
          (userId.isNotEmpty && p.tenantIds.contains(userId)) ||
              matchesPhone(p.primaryTenantPhone) ||
              matchesName(p.primaryTenantName);

      if (auth.isLandlord) return isLandlordProperty;
      if (auth.isTenant) return isTenantProperty;
      return isLandlordProperty || isTenantProperty;
    }).toList();
  }

  static const int _statusAvailable = 0;
  static const int _statusRented = 1;
  static const String _uploadCategory = 'TempPropertyUploads';

  int _propertyTypeFor(Map<String, dynamic> data) =>
      (data['propertyType'] as int?) ?? 0;

  String _errorText(dio.DioException e) {
    final d = e.response?.data;
    if (d is String && d.trim().isNotEmpty) return d.trim();
    if (d is Map) {
      final m = (d['message'] ?? d['title'] ?? d['error'] ?? '').toString();
      if (m.isNotEmpty) return m;
    }
    return e.message ?? 'Network error';
  }

  Future<Map<String, dynamic>> _uploadFile(
      PickedFile f, {
        String category = _uploadCategory,
      }) async {
    final form = dio.FormData.fromMap({
      'documentCategory': category,
      'files': dio.MultipartFile.fromBytes(f.bytes, filename: f.name),
    });
    final response = await DioClient.instance.post(
      AppEndpoints.uploadDoc,
      data: form,
    );
    AppLogger.d('PropertyRepository', '_uploadFile success');

    dynamic r = response.data;
    if (r is Map && r['result'] != null) r = r['result'];
    if (r is List && r.isNotEmpty) r = r.first;
    final m = Map<String, dynamic>.from(r as Map);

    return {
      'id': m['id'],
      'fileName': m['fileName'] ?? f.name,
      'absolutePath': m['absolutePath'] ?? '',
      'relativePath': m['relativePath'] ?? '',
      'thumbnailUrl': m['thumbnailUrl'] ?? '',
      'originalUrl': m['originalUrl'] ?? '',
      'uploadedTime':
      m['uploadedTime'] ?? DateTime.now().toUtc().toIso8601String(),
      'isDeletable': true,
    };
  }

  Future<List<AmenityModel>> _fetchAmenityList({int? type}) async {
    final url = type == null
        ? AppEndpoints.amenitiesList
        : '${AppEndpoints.amenitiesList}?amenitiesType=$type';
    final response = await DioClient.instance.get(url);
    final d = response.data;
    final List list =
    d is List ? d : (d is Map && d['result'] is List ? d['result'] : []);
    return list
        .whereType<Map>()
        .map((e) => AmenityModel.fromJson(Map<String, dynamic>.from(e)))
        .where((a) => a.id.isNotEmpty)
        .toList();
  }

  Future<List<AmenityModel>> getAmenities() => _fetchAmenityList(type:1);
  Future<List<AmenityModel>> getFeatures() => _fetchAmenityList(type: 3);

  String? _withCountryCode(dynamic p) {
    final s = p?.toString().trim() ?? '';
    if (s.isEmpty) return null;
    return s.startsWith('+') ? s : '+91$s';
  }

  Future<void> createProperty(Map<String, dynamic> data) async {
    try {
      AppLogger.i('PropertyRepository', 'Create property API started');
      final photos = (data['photos'] as List<PickedFile>? ?? []);
      final docs = (data['documents'] as List<PickedFile>? ?? []);
      final images = <Map<String, dynamic>>[];
      final documents = <Map<String, dynamic>>[];
      for (final p in photos) {
        images.add(await _uploadFile(p));
      }
      for (final d in docs) {
        documents.add(await _uploadFile(d));
      }

      final selected = (data['amenities'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final amenityIds = <String>[];
      final amenitiesDetails = <Map<String, dynamic>>[];

      String timing(Map t) =>
          '${t['from']} - ${t['to']}${(t['comment'] ?? '').toString().isNotEmpty ? '. ${t['comment']}' : ''}';

      for (final a in selected) {
        final id = a['id'].toString();
        final name = a['name'].toString().toLowerCase();
        amenityIds.add(id);
        if (name.contains('pool') && data['pool'] is Map) {
          amenitiesDetails.add({'id': id, 'details': timing(data['pool'])});
        } else if (name.contains('gym') && data['gym'] is Map) {
          amenitiesDetails.add({'id': id, 'details': timing(data['gym'])});
        }
      }

      final features = Map<String, dynamic>.from(data['features'] ?? {});
      final tenant = data['tenant'] as Map<String, dynamic>?;
      final landlord = data['landlord'] as Map<String, dynamic>?;

      final body = <String, dynamic>{
        'name': data['name'],
        'description': data['description'],
        'placeDetails': {
          'address': data['address'],
          'latitude': data['latitude'] ?? 0,
          'longitude': data['longitude'] ?? 0,
          'floor': data['floorNumber'],
          'doorNumber': data['doorNumber'],
        },
        'status': tenant != null ? _statusRented : _statusAvailable,
        'amenityIds': amenityIds,
        'amenitiesDetails': amenitiesDetails,
        'documents': documents,
        'images': images,
        'isSelfOwned': true,
        if (landlord != null) ...{
          'landlordName': landlord['name'],
          'landlordPhoneNumber': _withCountryCode(landlord['phone']),
          if ((landlord['email'] ?? '').toString().isNotEmpty)
            'landlordEmail': landlord['email'],
        },
        'advance': data['advance'],
        'deposit': 0,
        'rent': data['rent'],
        'rentPaymentDate': data['rentPaymentDate'] ?? 0,
        'bedrooms': features['bedrooms'] ?? 0,
        'bathrooms': features['bathrooms'] ?? 0,
        'kitchen': features['kitchens'] ?? 0,
        'builtYear': features['builtYear'] ?? 0,
        'propertyType': _propertyTypeFor(data),
        if (tenant != null) ...{
          'tenantName': tenant['name'],
          'tenantPhoneNumber': _withCountryCode(tenant['phone']),
          'tenantEmail': tenant['email'],
          if (tenant['startDate'] != null)
            'tenancyStartDate': tenant['startDate'],
        },
      };

      final response = await DioClient.instance.post(
        AppEndpoints.adminDashboardProperties,
        data: body,
      );
      AppLogger.i('PropertyRepository', 'Create property API success');

      final d = response.data;
      if (d is Map && d['status'] == false) {
        AppLogger.w(
          'PropertyRepository',
          'Create property rejected: ${d['message']}',
        );
        throw Exception(d['message'] ?? 'Failed to create property');
      }
    } on dio.DioException catch (e) {
      final msg = _errorText(e);
      AppLogger.e('PropertyRepository', 'Create property Dio error: $msg', e);
      throw Exception(msg);
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'Create property error', e, stack);
      rethrow;
    }
  }

  Map<String, dynamic> _imageObject(String url) {
    final i = url.indexOf('.amazonaws.com/');
    final rel = i == -1 ? url : url.substring(i + '.amazonaws.com/'.length);
    return {
      'fileName': rel.split('/').last,
      'absolutePath': url,
      'relativePath': rel,
      'thumbnailUrl': url,
      'originalUrl': url,
      'uploadedTime': DateTime.now().toUtc().toIso8601String(),
      'isDeletable': true,
    };
  }

  Future<void> updateProperty(PropertyModel existing, Map<String, dynamic> data) async {
    try {
      if (existing.status != PropertyStatus.available &&
          existing.status != PropertyStatus.rented) {
        throw Exception(
          'Editing "${existing.statusLabel}" properties is not supported yet.',
        );
      }
      final raw = existing.rawJson;

      final images = <Map<String, dynamic>>[
        for (final u in (data['existingImages'] as List? ?? [])) _imageObject(u.toString()),
      ];
      final documents = <Map<String, dynamic>>[
        for (final d in (data['existingDocuments'] as List? ?? []))
          if (d is Map) _documentObject(d),
      ];
      for (final p in (data['photos'] as List<PickedFile>? ?? [])) {
        images.add(await _uploadFile(p));
      }
      for (final d in (data['documents'] as List<PickedFile>? ?? [])) {
        documents.add(await _uploadFile(d));
      }

      final selected = (data['amenities'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final amenityIds = <String>[];
      final amenitiesDetails = <Map<String, dynamic>>[];
      String timing(Map t) =>
          '${t['from']} - ${t['to']}${(t['comment'] ?? '').toString().isNotEmpty ? '. ${t['comment']}' : ''}';
      for (final a in selected) {
        final id = a['id'].toString();
        final name = a['name'].toString().toLowerCase();
        amenityIds.add(id);
        if (name.contains('pool') && data['pool'] is Map) {
          amenitiesDetails.add({'id': id, 'details': timing(data['pool'])});
        } else if (name.contains('gym') && data['gym'] is Map) {
          amenitiesDetails.add({'id': id, 'details': timing(data['gym'])});
        }
      }

      final features = Map<String, dynamic>.from(data['features'] ?? {});
      final tenant = data['tenant'] as Map<String, dynamic>?;
      final landlord = data['landlord'] as Map<String, dynamic>?;
      final oldTenant = raw['tenant'] is Map
          ? Map<String, dynamic>.from(raw['tenant'])
          : <String, dynamic>{};

      final body = <String, dynamic>{
        'name': data['name'],
        'description': data['description'],
        'placeDetails': {
          'address': data['address'],
          'latitude': data['latitude'] ?? 0,
          'longitude': data['longitude'] ?? 0,
          'floor': data['floorNumber'],
          'doorNumber': data['doorNumber'],
        },
        'status': tenant != null ? _statusRented : _statusAvailable,
        'amenityIds': amenityIds,
        'amenitiesDetails': amenitiesDetails,
        'documents': documents,
        'images': images,
        'isSelfOwned': raw['isSelfOwned'] ?? true,
        if (landlord != null) ...{
          'landlordName': landlord['name'],
          'landlordPhoneNumber': _withCountryCode(landlord['phone']),
          if ((landlord['email'] ?? '').toString().isNotEmpty)
            'landlordEmail': landlord['email'],
        },
        if (tenant != null) ...{
          'tenant': {
            'id': oldTenant['id'],
            'name': tenant['name'],
            'phoneNumber': _withCountryCode(tenant['phone']),
            'email': tenant['email'],
            'panNumber': oldTenant['panNumber'],
            'fatherName': oldTenant['fatherName'],
          },
          if (tenant['startDate'] != null) 'tenancyStartDate': tenant['startDate'],
        },
        'extraProperties': raw['extraProperties']?.toString() ?? '',
        'advance': data['advance'],
        'rent': data['rent'],
        'rentPaymentDate': data['rentPaymentDate'] ?? 0,
        'bedrooms': features['bedrooms'] ?? 0,
        'bathrooms': features['bathrooms'] ?? 0,
        'kitchen': features['kitchens'] ?? 0,
        'builtYear': features['builtYear'] ?? 0,
        if (_intOrNull(raw['zone']) != null) 'zone': _intOrNull(raw['zone']),
        'propertyType': data['propertyType'] ?? 0,
        'contractReference': raw['contractReference']?.toString() ?? '',
      };

      final response = await DioClient.instance.put(
        '${AppEndpoints.adminDashboardProperties}/${existing.id}',
        data: body,
      );
      final d = response.data;
      if (d is Map && d['status'] == false) {
        throw Exception(d['message'] ?? 'Failed to update property');
      }
    } on dio.DioException catch (e) {
      throw Exception(_errorText(e));
    }
  }

  Future<String> deleteProperty(String id) async {
    try {
      final response = await DioClient.instance.delete(
        '${AppEndpoints.adminDashboardProperties}/$id',
      );
      AppLogger.i('PropertyRepository', 'deleteProperty Response: ${response.data}');
      final d = response.data;
      if (d is Map) {
        if (d['status'] == false) {
          throw Exception(d['message'] ?? 'Failed to delete property');
        }
        return d['message']?.toString() ??
            'Property delete request submitted. It will be hidden after 24 hours and permanently deleted after 3 days.';
      }
      return 'Property delete request submitted. It will be hidden after 24 hours and permanently deleted after 3 days.';
    } on dio.DioException catch (e) {
      final msg = _errorText(e);
      AppLogger.e('PropertyRepository', 'deleteProperty Dio error: $msg', e);
      throw Exception(msg);
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'deleteProperty error', e, stack);
      rethrow;
    }
  }

  int? _intOrNull(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString().trim() ?? '');
  }

  Future<PropertyStatsModel> getPropertyStats() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardPropertyStats,
      );
      AppLogger.d('PropertyRepository', 'getPropertyStats success');

      final data = response.data;
      if (data is Map && data['result'] is Map) {
        return PropertyStatsModel.fromJson(
          Map<String, dynamic>.from(data['result']),
        );
      }
      return PropertyStatsModel.empty();
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'getPropertyStats error', e, stack);
      rethrow;
    }
  }

  Map<String, dynamic> _documentObject(Map d) {
    String s(List<String> keys) {
      for (final k in keys) {
        final v = d[k]?.toString().trim() ?? '';
        if (v.isNotEmpty && v != 'null') return v;
      }
      return '';
    }

    final abs = s(['absolutePath', 'fileUrl', 'url']);
    final i = abs.indexOf('.amazonaws.com/');
    final rel = s(['relativePath']).isNotEmpty
        ? s(['relativePath'])
        : (i == -1 ? abs : abs.substring(i + '.amazonaws.com/'.length));
    final uploaded = s(['uploadedTime', 'uploadedDate']);

    return {
      'id': d['id'],
      'fileName': s(['fileName', 'documentName', 'name']),
      'absolutePath': abs,
      'relativePath': rel,
      'thumbnailUrl': s(['thumbnailUrl']),
      'originalUrl': s(['originalUrl']).isNotEmpty ? s(['originalUrl']) : abs,
      'uploadedTime':
      uploaded.isNotEmpty ? uploaded : DateTime.now().toUtc().toIso8601String(),
      'isDeletable': d['isDeletable'] ?? true,
    };
  }

  Future<PropertyModel> getPropertyById(String id) async {
    try {
      final response = await DioClient.instance.get(
        '${AppEndpoints.adminDashboardProperties}/$id',
      );
      AppLogger.d('PropertyRepository', 'getPropertyById success id=$id');

      final data = response.data;
      if (data is Map && data['result'] is Map) {
        return PropertyModel.fromJson(
          Map<String, dynamic>.from(data['result']),
        );
      }
      throw Exception('Unexpected property details response');
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'getPropertyById error', e, stack);
      rethrow;
    }
  }

  Future<List<TenantModel>> getAllTenants() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.allTenants);
      final List<dynamic> result;
      if (response.data is List) {
        result = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['result'] != null) {
        result = response.data['result'] as List<dynamic>;
      } else {
        result = [];
      }
      final tenants = result
          .whereType<Map>()
          .map((json) => TenantModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return _filterTenantsForCurrentUser(tenants);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LandlordModel>> getAllLandlords() async {
    try {
      final response =
      await DioClient.instance.get(AppEndpoints.allLandlordDetails);
      final List<dynamic> result;
      if (response.data is List) {
        result = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['result'] != null) {
        result = response.data['result'] as List<dynamic>;
      } else {
        result = [];
      }
      final landlords = result
          .whereType<Map>()
          .map((json) =>
          LandlordModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return _filterLandlordsForCurrentUser(landlords);
    } catch (e) {
      rethrow;
    }
  }

  bool _matchesLoggedInUser(
      AuthController auth,
      String id,
      String phone,
      String name,
      ) {
    final userId = auth.userId.value;
    final userPhone = auth.userPhone.value.replaceAll(' ', '');
    final userName = auth.userName.value.trim().toLowerCase();
    if (userId.isNotEmpty && id == userId) return true;
    if (userPhone.isNotEmpty && phone.replaceAll(' ', '') == userPhone) {
      return true;
    }
    if (userName.isNotEmpty && name.trim().toLowerCase() == userName) {
      return true;
    }
    return false;
  }

  List<LandlordModel> _filterLandlordsForCurrentUser(
      List<LandlordModel> landlords,
      ) {
    if (!Get.isRegistered<AuthController>()) return landlords;
    final auth = Get.find<AuthController>();
    if (!auth.isRestrictedRole) return landlords;
    if (auth.isLandlord) {
      return landlords
          .where((l) => _matchesLoggedInUser(auth, l.id, l.phone, l.name))
          .toList();
    }
    return landlords;
  }

  List<TenantModel> _filterTenantsForCurrentUser(List<TenantModel> tenants) {
    if (!Get.isRegistered<AuthController>()) return tenants;
    final auth = Get.find<AuthController>();
    if (!auth.isRestrictedRole) return tenants;
    if (auth.isTenant) {
      return tenants
          .where((t) => _matchesLoggedInUser(auth, t.id, t.phone, t.name))
          .toList();
    }
    return tenants;
  }

  Future<TenantDetailsModel> getTenantDetails(String userId) async {
    try {
      final response =
      await DioClient.instance.get(AppEndpoints.currentUserDetails);
      if (response.data['status'] == true) {
        return TenantDetailsModel.fromJson(response.data['result']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch tenant details');
      }
    } catch (e) {
      rethrow;
    }
  }
}