import 'package:get/get.dart';
import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/model/property_stats_model.dart';
import 'package:agremate_admin/modules/property/model/landlord_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_details_model.dart';

class PropertyRepository {
  Future<List<PropertyModel>> getAllProperties() async {
    try {
      final properties =
          await _fetchPropertyList(AppEndpoints.adminDashboardProperties);
      if (!Get.isRegistered<AuthController>()) return properties;
      final auth = Get.find<AuthController>();
      if (!auth.isRestrictedRole) return properties;
      return _filterForCurrentUser(properties, auth);
    } catch (e, stack) {
      print('PropertyRepository.getAllProperties Error: $e');
      print(stack);
      rethrow;
    }
  }

  Future<List<PropertyModel>> _fetchPropertyList(String endpoint) async {
    final response = await DioClient.instance.get(endpoint);
    print('PropertyRepository.getAllProperties Response: ${response.data}');

    final List<dynamic> result;
    if (response.data is List) {
      result = response.data as List<dynamic>;
    } else if (response.data is Map && response.data['result'] is List) {
      result = response.data['result'] as List<dynamic>;
    } else {
      result = [];
    }

    print('PropertyRepository.getAllProperties Result length: ${result.length}');
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

  Future<PropertyStatsModel> getPropertyStats() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardPropertyStats,
      );
      print('PropertyRepository.getPropertyStats Response: ${response.data}');

      final data = response.data;
      if (data is Map && data['result'] is Map) {
        return PropertyStatsModel.fromJson(
          Map<String, dynamic>.from(data['result']),
        );
      }
      return PropertyStatsModel.empty();
    } catch (e) {
      print('PropertyRepository.getPropertyStats Error: $e');
      rethrow;
    }
  }

  Future<PropertyModel> getPropertyById(String id) async {
    try {
      final response = await DioClient.instance.get(
        '${AppEndpoints.adminDashboardProperties}/$id',
      );
      print('PropertyRepository.getPropertyById Response: ${response.data}');

      final data = response.data;
      if (data is Map && data['result'] is Map) {
        return PropertyModel.fromJson(
          Map<String, dynamic>.from(data['result']),
        );
      }
      throw Exception('Unexpected property details response');
    } catch (e) {
      print('PropertyRepository.getPropertyById Error: $e');
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
      final response = await DioClient.instance.get(AppEndpoints.allLandlordDetails);
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
          .map((json) => LandlordModel.fromJson(Map<String, dynamic>.from(json)))
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
      final response = await DioClient.instance.get(AppEndpoints.currentUserDetails);
      if (response.data['status'] == true) {
        return TenantDetailsModel.fromJson(response.data['result']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch tenant details');
      }
    } catch (e) {
      rethrow;
    }
  }
}
