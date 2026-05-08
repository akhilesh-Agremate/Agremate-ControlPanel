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
      final response = await DioClient.instance.get(AppEndpoints.allProperties);
      print('PropertyRepository.getAllProperties Response: ${response.data}');
      
      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'] ?? [];
        print('PropertyRepository.getAllProperties Result length: ${result.length}');
        return result.where((e) => e != null).map((json) => PropertyModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch properties');
      }
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
