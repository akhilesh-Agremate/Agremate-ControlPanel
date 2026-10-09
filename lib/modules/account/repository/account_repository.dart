import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/account/model/account_model.dart';

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

