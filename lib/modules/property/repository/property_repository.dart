import 'dart:convert';
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
        return _scopeForCurrentUser(properties);
      }

      try {
        final properties =
            await _fetchPropertyList(AppEndpoints.adminDashboardProperties);
        if (properties.isNotEmpty) {
          final scoped = await _scopeForCurrentUser(properties);
          _applyLoggedInLandlordName(scoped);
          return scoped;
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
      final scoped = await _scopeForCurrentUser(combinedMap.values.toList());
      _applyLoggedInLandlordName(scoped);
      return scoped;
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'getAllProperties failed', e, stack);
      rethrow;
    }
  }

  Future<void> _hydrateIdentity(AuthController auth) async {
    if (auth.userPhone.value.trim().isEmpty &&
        auth.phoneNumber.value.trim().isNotEmpty) {
      auth.userPhone.value = auth.phoneNumber.value.trim();
    }

    void absorb(dynamic node, [int depth = 0]) {
      if (node is! Map || depth > 3) return;
      for (final key in ['id', 'userId', 'landlordId', 'tenantId', 'agremateId']) {
        auth.rememberIdentityId(node[key]?.toString());
      }
      final phone = (node['phoneNumber'] ?? node['phone'] ?? node['mobile'])
          ?.toString()
          .trim();
      if ((phone ?? '').isNotEmpty && auth.userPhone.value.trim().isEmpty) {
        auth.userPhone.value = phone!;
      }
      final name = (node['fullName'] ?? node['name'])?.toString().trim();
      if ((name ?? '').isNotEmpty && auth.userName.value.trim().isEmpty) {
        auth.userName.value = name!;
      }
      final email = node['email']?.toString().trim();
      if ((email ?? '').isNotEmpty && auth.userEmail.value.trim().isEmpty) {
        auth.userEmail.value = email!;
      }
      absorb(node['user'], depth + 1);
      absorb(node['users'], depth + 1);
      absorb(node['userInfo'], depth + 1);
      absorb(node['userRole'], depth + 1);
      absorb(node['role'], depth + 1);
    }

    Future<void> absorbEndpoint(String endpoint, {Map<String, dynamic>? query}) async {
      try {
        final response = await DioClient.instance.get(
          endpoint,
          queryParameters: query,
        );
        dynamic data = response.data;
        if (data is Map && data['result'] != null) data = data['result'];
        absorb(data);
      } catch (e) {
        AppLogger.w('PropertyRepository', 'Identity hydrate failed for $endpoint: $e');
      }
    }

    await absorbEndpoint(AppEndpoints.currentUserDetails);
    await absorbEndpoint(AppEndpoints.userBootstrap);
    auth.persistIdentity();
  }

  Future<List<PropertyModel>> _fetchTokenScopedProperties() async {
    final combined = <String, PropertyModel>{};
    var fallbackIndex = 0;
    void addAll(List<PropertyModel> list) {
      for (final p in list) {
        if (p.id.isNotEmpty) {
          combined[p.id] = p;
      } else {
          combined['anon-$fallbackIndex'] = p;
          fallbackIndex++;
        }
      }
    }

    addAll(await _fetchPropertyListSafely(AppEndpoints.getMyPropertyList));
    addAll(await _fetchPropertyListSafely(AppEndpoints.currentUserDetails));
    addAll(await _fetchPropertyListSafely(AppEndpoints.landlordDetails));
    return combined.values.toList();
  }

  Future<List<PropertyModel>> _scopeForCurrentUser(
    List<PropertyModel> properties,
  ) async {
    if (!Get.isRegistered<AuthController>()) return properties;
    final auth = Get.find<AuthController>();
    if (!auth.isRestrictedRole) return properties;

    await _hydrateIdentity(auth);
    final filtered = _filterForCurrentUser(properties, auth);
    AppLogger.i(
      'PropertyRepository',
      'Role filter role=${auth.role.value} in=${properties.length} out=${filtered.length} ids=${auth.identityIds.length}',
    );
    if (filtered.isNotEmpty) {
      _applyLoggedInLandlordName(filtered);
      return filtered;
    }

    final mine = await _fetchTokenScopedProperties();
    if (mine.isNotEmpty) {
      AppLogger.i(
        'PropertyRepository',
        'Restricted-role token-scoped fallback count=${mine.length}',
      );
      _applyLoggedInLandlordName(mine);
      return mine;
    }

    if (auth.isLandlord) {
      try {
        final response =
            await DioClient.instance.get(AppEndpoints.allLandlordDetails);
        final raw = _extractList(response.data);
        final linkedIds = <String>{};
        for (final row in raw.whereType<Map>()) {
          final map = Map<String, dynamic>.from(row);
          final landlord = LandlordModel.fromJson(map);
          final userId = (map['userId'] ?? map['id'] ?? landlord.id).toString();
          if (_matchesLoggedInUser(
                auth,
                userId,
                landlord.phone,
                landlord.name,
              ) ||
              _matchesLoggedInUser(auth, landlord.id, landlord.phone, landlord.name)) {
            for (final p in landlord.properties) {
              if (p.id.isNotEmpty) linkedIds.add(p.id);
            }
          }
        }
        if (linkedIds.isNotEmpty) {
          final matched =
              properties.where((p) => linkedIds.contains(p.id)).toList();
          if (matched.isNotEmpty) {
            AppLogger.i(
              'PropertyRepository',
              'Landlord fallback via landlord.properties count=${matched.length}',
            );
            _applyLoggedInLandlordName(matched);
            return matched;
          }
        }
      } catch (e) {
        AppLogger.w(
          'PropertyRepository',
          'Landlord fallback via landlords failed: $e',
        );
      }
    }

    if (properties.isNotEmpty) {
      final hasLandlordMeta = properties.any((p) {
        final phone = (p.landlordPhone ?? '').trim();
        final name = p.landlordName.trim().toLowerCase();
        final email = (p.landlordEmail ?? '').trim();
        return p.landlordId.isNotEmpty ||
            phone.isNotEmpty ||
            email.isNotEmpty ||
            (name.isNotEmpty && name != 'n/a');
      });
      if (!hasLandlordMeta) {
        AppLogger.i(
          'PropertyRepository',
          'Restricted role using token-scoped list count=${properties.length}',
        );
        _applyLoggedInLandlordName(properties);
        return properties;
      }
    }

    return filtered;
  }

  void _applyLoggedInLandlordName(List<PropertyModel> properties) {
    if (!Get.isRegistered<AuthController>()) return;
    final auth = Get.find<AuthController>();
    if (!auth.isLandlord) return;
    final name = auth.userName.value.trim();
    if (name.isEmpty) return;
    for (final property in properties) {
      final current = property.landlordName.trim().toLowerCase();
      if (current.isEmpty || current == 'n/a') {
        property.landlordName = name;
      }
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

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is! Map) return const [];

    const keys = [
      'items',
      'data',
      'properties',
      'socialProperties',
      'ownedProperties',
      'rentedProperties',
      'records',
      'result',
      'list',
      'owned',
    ];

    final found = <dynamic>[];
    void collect(dynamic node, int depth) {
      if (node is List) {
        if (node.isNotEmpty) found.addAll(node);
        return;
      }
      if (node is! Map || depth > 3) return;
      for (final key in keys) {
        final v = node[key];
        if (v is List && v.isNotEmpty) {
          found.addAll(v);
        } else if (v is Map) {
          collect(v, depth + 1);
        }
      }
    }

    collect(data, 0);
    if (found.isNotEmpty) return found;
    return const [];
  }

  Future<List<PropertyModel>> _fetchPropertyList(String endpoint) async {
    final response = await DioClient.instance.get(endpoint);
    AppLogger.d(
      'PropertyRepository',
      'getAllProperties Response status=${response.statusCode} endpoint=$endpoint',
    );

    final result = _extractList(response.data);
    AppLogger.i('PropertyRepository', 'getAllProperties count=${result.length}');
    return result
        .whereType<Map>()
        .map((json) => PropertyModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  String _phoneDigits(String? value) {
    final d = (value ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (d.length > 10) return d.substring(d.length - 10);
    return d;
  }

  bool _samePhone(String? a, String? b) {
    final x = _phoneDigits(a);
    final y = _phoneDigits(b);
    if (x.isEmpty || y.isEmpty) return false;
    return x == y;
  }

  List<PropertyModel> _filterForCurrentUser(
      List<PropertyModel> properties,
      AuthController auth,
      ) {
    final ids = auth.identityIds;
    final phone = auth.userPhone.value.isNotEmpty
        ? auth.userPhone.value
        : auth.phoneNumber.value;
    final name = auth.userName.value.trim().toLowerCase();
    final email = auth.userEmail.value.trim().toLowerCase();

    bool matchesId(String? value) {
      if (ids.isEmpty || value == null || value.isEmpty) return false;
      final needle = value.trim().toLowerCase();
      return ids.any((id) => id.toLowerCase() == needle);
    }

    bool matchesName(String? value) {
      if (value == null || value.isEmpty || name.isEmpty) return false;
      final n = value.trim().toLowerCase();
      if (n == 'n/a') return false;
      return n == name;
    }

    bool matchesEmail(String? value) {
      if (value == null || value.isEmpty || email.isEmpty) return false;
      return value.trim().toLowerCase() == email;
    }

    return properties.where((p) {
      final landlordObj =
          p.rawJson['landlord'] is Map ? p.rawJson['landlord'] as Map : {};
      final isLandlordProperty = matchesId(p.landlordId) ||
          matchesId(landlordObj['userId']?.toString()) ||
          matchesId(landlordObj['id']?.toString()) ||
          matchesId(landlordObj['landlordId']?.toString()) ||
          matchesId(p.rawJson['landlordUserId']?.toString()) ||
          matchesId(p.rawJson['ownerId']?.toString()) ||
          matchesId(p.rawJson['createdBy']?.toString()) ||
          matchesId(p.rawJson['userId']?.toString()) ||
          _samePhone(p.landlordPhone, phone) ||
          _samePhone(landlordObj['phone']?.toString(), phone) ||
          _samePhone(landlordObj['phoneNumber']?.toString(), phone) ||
          matchesName(p.landlordName) ||
          matchesName(landlordObj['name']?.toString()) ||
          matchesName(landlordObj['fullName']?.toString()) ||
          matchesEmail(p.landlordEmail) ||
          matchesEmail(landlordObj['email']?.toString());
      final isTenantProperty = p.tenantIds.any((id) => matchesId(id)) ||
          _samePhone(p.primaryTenantPhone, phone) ||
          matchesName(p.primaryTenantName);

      if (auth.isLandlord) return isLandlordProperty;
      if (auth.isTenant) return isTenantProperty;
      return isLandlordProperty || isTenantProperty;
    }).toList();
  }

  static const int _statusAvailable = 0;
  static const int _statusRented = 1;
  static const int _statusBooked = 2;
  static const int _statusRequested = 3;
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

  void _report(Map data, String message, double progress) {
    final cb = data['onUploadProgress'];
    if (cb != null) cb(message, progress);
  }

  void _refreshUpload(Map data) {
    final cb = data['onUploadUi'];
    if (cb != null) cb();
  }

  Future<Map<String, dynamic>> uploadPropertyFile(PickedFile f) async {
    try {
      return await _uploadFile(f);
    } on dio.DioException catch (e) {
      throw Exception(_errorText(e));
    }
  }

  Future<bool> _askRetry(Map data, String name, String error) async {
    final cb = data['onUploadRetry'];
    if (cb == null) return false;
    final result = await cb(name, error);
    return result == true;
  }

  Future<List<Map<String, dynamic>>> _uploadFiles(
    List<PickedFile> files,
    Map data, {
    required String kind,
    required int doneBefore,
    required int total,
  }) async {
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final place = doneBefore + i + 1;
      while (file.uploading && file.uploaded == null) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      if (file.uploaded != null) {
        file.uploading = false;
        _refreshUpload(data);
        out.add(Map<String, dynamic>.from(file.uploaded!));
        continue;
      }
      while (true) {
        try {
          file.uploading = true;
          _refreshUpload(data);
          _report(
            data,
            'Uploading $kind $place of $total\n${file.name}',
            total == 0 ? 0 : (doneBefore + i) / total,
          );
          final uploaded = await _uploadFile(
            file,
            onSend: (fraction) {
              _report(
                data,
                'Uploading $kind $place of $total\n${file.name}',
                total == 0 ? 0 : (doneBefore + i + fraction) / total,
              );
            },
          );
          file.uploaded = uploaded;
          file.uploading = false;
          _refreshUpload(data);
          out.add(uploaded);
          break;
        } catch (e) {
          final message = e is dio.DioException
              ? _errorText(e)
              : '$e'.replaceFirst('Exception: ', '');
          final retry = await _askRetry(data, file.name, message);
          if (!retry) {
            file.uploading = false;
            _refreshUpload(data);
            throw Exception(message);
          }
        }
      }
    }
    return out;
  }

  Future<Map<String, dynamic>> _uploadFile(
      PickedFile f, {
        String category = _uploadCategory,
        void Function(double fraction)? onSend,
      }) async {
    final form = dio.FormData.fromMap({
      'documentCategory': category,
      'files': dio.MultipartFile.fromBytes(f.bytes, filename: f.name),
    });
    final response = await DioClient.instance.post(
      AppEndpoints.uploadDoc,
      data: form,
      onSendProgress: (sent, total) {
        if (onSend == null || total <= 0) return;
        onSend(sent / total);
      },
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
      'isCover': m['isCover'] == true,
    };
  }

  String? _applyCover(List<Map<String, dynamic>> images, dynamic coverIndex) {
    if (images.isEmpty) return null;
    var index = coverIndex is int ? coverIndex : int.tryParse('$coverIndex') ?? 0;
    if (index < 0 || index >= images.length) index = 0;
    for (var i = 0; i < images.length; i++) {
      images[i]['isCover'] = i == index;
    }
    final id = images[index]['id']?.toString() ?? '';
    return id.isEmpty ? null : id;
  }

  Future<void> setCoverImage(String propertyId, String documentDetailId) async {
    try {
      final response = await DioClient.instance.patch(
        '/Property/$propertyId/cover-image/$documentDetailId',
      );
      final d = response.data;
      if (d is Map && d['status'] == false) {
        throw Exception(d['message'] ?? 'Failed to update cover image');
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
          "You don't have permission to modify this property's cover image.",
        );
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Selected image not found. Please refresh.');
      }
      throw Exception(_errorText(e));
    }
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
      final uploadTotal = photos.length + docs.length;
      final images = await _uploadFiles(
        photos,
        data,
        kind: 'image',
        doneBefore: 0,
        total: uploadTotal,
      );
      final documents = await _uploadFiles(
        docs,
        data,
        kind: 'document',
        doneBefore: photos.length,
        total: uploadTotal,
      );
      _report(data, 'Saving property...', -1);

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

      final coverId = _applyCover(images, data['coverIndex']);
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
        if (coverId != null) 'coverImageDocumentDetailId': coverId,
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
        if (data['bhkType'] != null) 'bhkType': data['bhkType'],
        if (data['carpetArea'] != null) 'carpetArea': data['carpetArea'],
        if (data['squareFeetArea'] != null) 'squareFeetArea': data['squareFeetArea'],
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

  Future<void> createPgProperty(Map<String, dynamic> data) async {
    try {
      AppLogger.i('PropertyRepository', 'Create PG property API started');
      final photos = (data['photos'] as List<PickedFile>? ?? []);
      final docs = (data['documents'] as List<PickedFile>? ?? []);
      final uploadTotal = photos.length + docs.length;
      final images = await _uploadFiles(
        photos,
        data,
        kind: 'image',
        doneBefore: 0,
        total: uploadTotal,
      );
      final documents = await _uploadFiles(
        docs,
        data,
        kind: 'document',
        doneBefore: photos.length,
        total: uploadTotal,
      );
      _report(data, 'Saving property...', -1);

      final selected = (data['amenities'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final amenityIds = <String>[];

      for (final a in selected) {
        final id = a['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        amenityIds.add(id);
      }

      final body = <String, dynamic>{
        'name': data['name'],
        'description': data['description'] ?? '',
        'category': 'PG',
        'propertyType': 7,
        'status': 0,
        'pgType': data['pgType'] ?? 1,
        'genderAllowed': data['genderAllowed'] ?? 1,
        'city': data['city'] ?? 'Bengaluru',
        'pincode': data['pincode'] ?? '560001',
        'rentPaymentDate': data['rentPaymentDate'] ?? 5,
        'zone': data['zone'] ?? 1,
        if (data['landlord'] is Map) ...{
          'landlordName': (data['landlord'] as Map)['name'],
          'landlordPhoneNumber':
          _withCountryCode((data['landlord'] as Map)['phone']),
          if (((data['landlord'] as Map)['email'] ?? '').toString().isNotEmpty)
            'landlordEmail': (data['landlord'] as Map)['email'],
        },
        'placeDetails': {
          'address': data['address'] ?? '',
          'latitude': data['latitude'] ?? 0.0,
          'longitude': data['longitude'] ?? 0.0,
          'floor': (data['floor'] ?? 'Ground Floor').toString(),
          'doorNumber': (data['doorNumber'] ?? '').toString(),
        },
        'houseRules': data['houseRules'] ?? <String>[],
        'amenityIds': amenityIds,
        'floors': data['floors'] ?? <Map<String, dynamic>>[],
        if (images.isNotEmpty) 'images': images,
        if (_applyCover(images, data['coverIndex']) != null)
          'coverImageDocumentDetailId': _applyCover(images, data['coverIndex']),
        if (documents.isNotEmpty) 'documents': documents,
      };

      AppLogger.i('PropertyRepository', 'Creating PG property payload: $body');

      final response = await DioClient.instance.post(
        '${AppEndpoints.adminDashboardProperties}?category=PG',
        data: body,
      );

      AppLogger.i('PropertyRepository', 'Create PG property API success: ${response.statusCode}');

      final d = response.data;
      if (d is Map && d['status'] == false) {
        throw Exception(d['message'] ?? 'Failed to create PG property');
      }
    } on dio.DioException catch (e) {
      final msg = _errorText(e);
      AppLogger.e('PropertyRepository', 'Create PG property Dio error: $msg', e);
      throw Exception(msg);
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'Create PG property error', e, stack);
      rethrow;
    }
  }

  Future<void> updatePgProperty(String propertyId, Map<String, dynamic> data) async {
    try {
      AppLogger.i('PropertyRepository', 'Update PG property API started id=$propertyId');

      final existingPg = await getPropertyById(propertyId);
      final rawPgImages = existingPg.rawJson['images'] is List
          ? existingPg.rawJson['images'] as List
          : const [];
      final images = <Map<String, dynamic>>[
        for (final u in (data['existingImages'] as List? ?? []))
          _imageObject(u.toString(), rawPgImages),
      ];
      final documents = <Map<String, dynamic>>[
        for (final d in (data['existingDocuments'] as List? ?? []))
          if (d is Map) _documentObject(d),
      ];
      final newPhotos = (data['photos'] as List<PickedFile>? ?? []);
      final newDocs = (data['documents'] as List<PickedFile>? ?? []);
      final uploadTotal = newPhotos.length + newDocs.length;
      images.addAll(await _uploadFiles(
        newPhotos,
        data,
        kind: 'image',
        doneBefore: 0,
        total: uploadTotal,
      ));
      documents.addAll(await _uploadFiles(
        newDocs,
        data,
        kind: 'document',
        doneBefore: newPhotos.length,
        total: uploadTotal,
      ));
      _report(data, 'Saving property...', -1);

      final selected = (data['amenities'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final amenityIds = selected.map((a) => a['id'].toString()).toList();

      final rentAmt = (data['rent'] as num?)?.toInt() ?? 0;
      var advAmt = (data['advance'] as num?)?.toInt() ?? 0;
      if (advAmt < rentAmt) advAmt = rentAmt;

      final body = <String, dynamic>{
        'name': data['name'],
        'description': data['description'] ?? '',
        'category': 'PG',
        'propertyType': 7,
        'status': data['status'] ?? 0,
        'pgType': data['pgType'] ?? 1,
        'genderAllowed': data['genderAllowed'] ?? 1,
        'city': data['city'] ?? '',
        'pincode': data['pincode'] ?? '',
        'rent': rentAmt,
        'advance': advAmt,
        'rentPaymentDate': data['rentPaymentDate'] ?? 5,
        'bedrooms': data['bedrooms'] ?? 0,
        'bathrooms': data['bathrooms'] ?? 0,
        'kitchen': data['kitchen'] ?? 1,
        'builtYear': data['builtYear'] ?? DateTime.now().year,
        'zone': data['zone'] ?? 1,
        'contractReference': data['contractReference'] ?? '',
        'placeDetails': {
          'address': data['address'] ?? '',
          'latitude': data['latitude'] ?? 0.0,
          'longitude': data['longitude'] ?? 0.0,
          'floor': (data['floor'] ?? 'Ground Floor').toString(),
          'doorNumber': (data['doorNumber'] ?? '').toString(),
        },
        'houseRules': data['houseRules'] ?? <String>[],
        'amenityIds': amenityIds,
        'amenitiesDetails': <Map<String, dynamic>>[],
        'documents': documents,
        if (_applyCover(images, data['coverIndex']) != null)
          'coverImageDocumentDetailId': _applyCover(images, data['coverIndex']),
        'images': images,
        'isSelfOwned': data['isSelfOwned'] ?? true,
        'extraProperties': data['extraProperties'],
        if (data['floors'] != null) 'floors': data['floors'],
      };

      AppLogger.i('PropertyRepository', 'Update PG property payload: $body');

      final response = await DioClient.instance.put(
        '${AppEndpoints.adminDashboardProperties}/$propertyId',
        data: body,
      );

      AppLogger.i('PropertyRepository', 'Update PG property API success: ${response.statusCode}');

      final d = response.data;
      if (d is Map && d['status'] == false) {
        throw Exception(d['message'] ?? 'Failed to update PG property');
      }
    } on dio.DioException catch (e) {
      final msg = _errorText(e);
      AppLogger.e('PropertyRepository', 'Update PG property Dio error: $msg', e);
      throw Exception(msg);
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'Update PG property error', e, stack);
      rethrow;
    }
  }

  List<Map<String, dynamic>> _keptImages(Map data, List rawImages) {
    final urls = data['existingImages'] as List? ?? [];
    final ids = data['existingImageIds'] as List? ?? [];
    final images = <Map<String, dynamic>>[];
    for (var i = 0; i < urls.length; i++) {
      final obj = _imageObject(urls[i].toString(), rawImages);
      final id = i < ids.length ? ids[i]?.toString() ?? '' : '';
      if ((obj['id']?.toString() ?? '').isEmpty && id.isNotEmpty) {
        obj['id'] = id;
      }
      images.add(obj);
    }
    return images;
  }

  Map<String, dynamic> _imageObject(String url, [List rawImages = const []]) {
    for (final e in rawImages) {
      if (e is! Map) continue;
      final candidates = [
        e['absolutePath'],
        e['originalUrl'],
        e['thumbnailUrl'],
        e['fileUrl'],
        e['url'],
        e['relativePath'],
      ].map((v) => v?.toString().trim() ?? '').where((v) => v.isNotEmpty);
      if (candidates.any((c) => c == url || url.endsWith(c))) {
        return _documentObject(e);
      }
    }
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
          existing.status != PropertyStatus.rented &&
          existing.status != PropertyStatus.booked &&
          existing.status != PropertyStatus.requested) {
        throw Exception(
          'Editing "${existing.statusLabel}" properties is not supported yet.',
        );
      }
      final raw = existing.rawJson;

      final rawImages = raw['images'] is List ? raw['images'] as List : const [];
      final images = _keptImages(data, rawImages);
      final documents = <Map<String, dynamic>>[
        for (final d in (data['existingDocuments'] as List? ?? []))
          if (d is Map) _documentObject(d),
      ];

      final newPhotos = (data['photos'] as List<PickedFile>? ?? []);
      final newDocs = (data['documents'] as List<PickedFile>? ?? []);
      final uploadTotal = newPhotos.length + newDocs.length;
      images.addAll(await _uploadFiles(
        newPhotos,
        data,
        kind: 'image',
        doneBefore: 0,
        total: uploadTotal,
      ));
      documents.addAll(await _uploadFiles(
        newDocs,
        data,
        kind: 'document',
        doneBefore: newPhotos.length,
        total: uploadTotal,
      ));
      _report(data, 'Saving property...', -1);

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
        'status': _statusForUpdate(existing, tenant),
        'amenityIds': amenityIds,
        'amenitiesDetails': amenitiesDetails,
        'documents': documents,
        'images': images,
        if (_applyCover(images, data['coverIndex']) != null)
          'coverImageDocumentDetailId': _applyCover(images, data['coverIndex']),
        'isSelfOwned': raw['isSelfOwned'] ?? true,
        if (landlord != null) ...{
          'landlordId': (raw['landlord'] is Map ? raw['landlord']['id'] : null) ??
              existing.landlordId,
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
        if (data['bhkType'] != null) 'bhkType': data['bhkType'],
        if (data['carpetArea'] != null) 'carpetArea': data['carpetArea'],
        if (data['squareFeetArea'] != null) 'squareFeetArea': data['squareFeetArea'],
        'contractReference': raw['contractReference']?.toString() ?? '',
      };
      AppLogger.i('PropertyRepository',
          'Update docs count=${documents.length}: ${jsonEncode(documents)}');
      AppLogger.i('PropertyRepository', 'IMAGES >> ${jsonEncode(images)}');

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
        final resultMsg = d['result']?.toString().trim() ?? '';
        if (resultMsg.isNotEmpty && resultMsg.toLowerCase() != 'null') {
          return resultMsg;
        }
        final msg = d['message']?.toString().trim() ?? '';
        if (msg.isNotEmpty && msg.toLowerCase() != 'null' && msg.toLowerCase() != 'success') {
          return msg;
        }
        return 'Property soft-deleted successfully.';
      }
      return 'Property soft-deleted successfully.';
    } on dio.DioException catch (e) {
      final msg = _errorText(e);
      AppLogger.e('PropertyRepository', 'deleteProperty Dio error: $msg', e);
      throw Exception(msg);
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'deleteProperty error', e, stack);
      rethrow;
    }
  }

  int _statusForUpdate(PropertyModel existing, Map<String, dynamic>? tenant) {
    if (existing.status == PropertyStatus.requested) {
      return _intOrNull(existing.rawJson['status']) ?? _statusRequested;
    }
    if (existing.status == PropertyStatus.booked) {
      final raw = existing.rawJson['status'];
      if (raw is num) return raw.toInt();
      final parsed = int.tryParse(raw?.toString() ?? '');
      if (parsed != null) return parsed;
      return _statusBooked;
    }
    return tenant != null ? _statusRented : _statusAvailable;
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
      if ((d['id']?.toString() ?? '').isNotEmpty) 'id': d['id'],
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
        final property = PropertyModel.fromJson(
          Map<String, dynamic>.from(data['result']),
        );
        _applyLoggedInLandlordName([property]);
        return property;
      }
      throw Exception('Unexpected property details response');
    } catch (e, stack) {
      AppLogger.e('PropertyRepository', 'getPropertyById error', e, stack);
      rethrow;
    }
  }

  Future<List<TenantModel>> getAllTenants() async {
    try {
      const pageSize = 50;
      const maxPages = 1000;
      final all = <TenantModel>[];
      final seen = <String>{};

      for (var page = 1; page <= maxPages; page++) {
        final response = await DioClient.instance.get(
          AppEndpoints.allTenants,
          queryParameters: {'page': page, 'pageSize': pageSize},
        );
        final items = _extractList(response.data)
            .whereType<Map>()
            .map((json) => TenantModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        var added = 0;
        for (final t in items) {
          final key = '${t.id}|${_phoneDigits(t.phone)}|${t.propertyName}|${t.name}';
          if (seen.add(key)) {
            all.add(t);
            added++;
          }
        }
        AppLogger.i('PropertyRepository',
            'getAllTenants page=$page got=${items.length} added=$added total=${all.length}');
        if (items.isEmpty || added == 0) break;
      }
      return _filterTenantsForCurrentUser(all);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LandlordModel>> getAllLandlords() async {
    try {
      const pageSize = 50;
      const maxPages = 1000;
      final all = <LandlordModel>[];
      final seen = <String>{};

      for (var page = 1; page <= maxPages; page++) {
        final response = await DioClient.instance.get(
          AppEndpoints.allLandlordDetails,
          queryParameters: {'page': page, 'pageSize': pageSize},
        );
        final items = _extractList(response.data)
            .whereType<Map>()
            .map((json) => LandlordModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        var added = 0;
        for (final l in items) {
          final key = '${l.id}|${_phoneDigits(l.phone)}|${l.name.trim().toLowerCase()}';
          if (seen.add(key)) {
            all.add(l);
            added++;
          }
        }
        AppLogger.i('PropertyRepository',
            'getAllLandlords page=$page got=${items.length} added=$added total=${all.length}');

        if (items.isEmpty || added == 0) break;
      }
      return _filterLandlordsForCurrentUser(all);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LandlordModel>> getLandlordsPage({int page = 1, int pageSize = 50}) async {
    final response = await DioClient.instance.get(
      AppEndpoints.allLandlordDetails,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return _extractList(response.data)
        .whereType<Map>()
        .map((j) => LandlordModel.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  Future<List<TenantModel>> getTenantsPage({int page = 1, int pageSize = 50}) async {
    final response = await DioClient.instance.get(
      AppEndpoints.allTenants,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return _extractList(response.data)
        .whereType<Map>()
        .map((j) => TenantModel.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  List<LandlordModel> filterLandlords(List<LandlordModel> l) =>
      _filterLandlordsForCurrentUser(l);
  List<TenantModel> filterTenants(List<TenantModel> t) =>
      _filterTenantsForCurrentUser(t);

  bool _matchesLoggedInUser(
      AuthController auth,
      String id,
      String phone,
      String name,
      ) {
    final ids = auth.identityIds;
    final userPhone = auth.userPhone.value.isNotEmpty
        ? auth.userPhone.value
        : auth.phoneNumber.value;
    final userName = auth.userName.value.trim().toLowerCase();
    final needle = id.trim().toLowerCase();
    if (needle.isNotEmpty &&
        ids.any((value) => value.toLowerCase() == needle)) {
      return true;
    }
    if (_samePhone(phone, userPhone)) return true;
    if (userName.isNotEmpty &&
        name.trim().toLowerCase() == userName &&
        name.trim().toLowerCase() != 'n/a') {
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