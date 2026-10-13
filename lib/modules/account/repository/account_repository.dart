import 'package:dio/dio.dart';
import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/account/model/account_model.dart';
import 'package:agremate_admin/modules/account/model/role_model.dart';

class AccountRepository {
  Future<AccountModel> getProfile() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.currentUserDetails);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['status'] == true) {
          return AccountModel.fromJson(data['result'] ?? data);
        }
        throw Exception(data?['message'] ?? 'Failed to fetch profile');
      }
      throw Exception('Failed to fetch profile: Status code ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoleModel>> getRoles() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.getRoles);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['status'] == true) {
          final List list = data['result'] as List? ?? [];
          return list
              .map((item) => RoleModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception(data?['message'] ?? 'Failed to fetch roles');
      }
      throw Exception('Failed to fetch roles: Status code ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String roleId,
    required String phoneNumber,
  }) async {
    try {
      final response = await DioClient.instance.post(
        AppEndpoints.adminDashboardUsers,
        data: {
          'roleId': roleId,
          'phoneNumber': phoneNumber,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['status'] == true) {
          return data['result'] is Map<String, dynamic>
              ? data['result'] as Map<String, dynamic>
              : (data as Map<String, dynamic>);
        }
        throw Exception(data?['message'] ?? 'Failed to create user');
      }
      throw Exception('Failed to create user: Status code ${response.statusCode}');
    } on DioException catch (e) {
      final d = e.response?.data;
      if (d is Map && d['message'] != null) {
        throw Exception(d['message']);
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<AccountModel> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await DioClient.instance.put(
        AppEndpoints.updateProfile,
        data: {'name': name, 'email': email, 'phone': phone},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['status'] == true) {
          return AccountModel.fromJson(data['result'] ?? data);
        }
        throw Exception(data?['message'] ?? 'Failed to update profile');
      }
      throw Exception('Failed to update profile: Status code ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerAccount({
    required String emailPhone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await DioClient.instance.post(
        AppEndpoints.userSignUp,
        data: {
          'emailPhone': emailPhone,
          'password': password,
          'role': role,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['status'] == true) return;
        throw Exception(data?['message'] ?? 'Failed to register account');
      }
      throw Exception('Failed to register account: Status code ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}

