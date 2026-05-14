import 'dart:convert';
import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/model/landlord_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_details_model.dart';

class PropertyRepository {
  Future<List<PropertyModel>> getAllProperties() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.allPropertyDetails);
      print('PropertyRepository.getAllProperties Response: ${response.data}');

      // The new endpoint returns a plain JSON array
      final List<dynamic> result;
      if (response.data is List) {
        result = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['result'] != null) {
        result = response.data['result'] as List<dynamic>;
      } else {
        result = [];
      }

      print('PropertyRepository.getAllProperties Result length: ${result.length}');
      return result
          .where((e) => e != null)
          .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print('PropertyRepository.getAllProperties Error: $e');
      print(stack);
      rethrow;
    }
  }

  Future<List<TenantModel>> getAllTenants() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.allTenants);
      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'];
        return result.map((json) => TenantModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch tenants');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LandlordModel>> getAllLandlords() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.allLandlords);
      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'];
        return result.map((json) => LandlordModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch landlords');
      }
    } catch (e) {
      rethrow;
    }
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
