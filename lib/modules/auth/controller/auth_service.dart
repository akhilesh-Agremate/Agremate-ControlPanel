import 'package:dio/dio.dart';
import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';
import '../model/model.dart';

class AuthService {
  Dio get _dio => DioClient.instance;

  void setAuthToken(String type, String token) {
    DioClient.authHeader = '$type $token';
  }

  void clearAuthToken() {
    DioClient.authHeader = null;
  }

  Future<ApiResult<AccessCheckResult>> checkAccess(String phone) {
    AppLogger.i('AuthService', 'check-access started');
    return _call(
      () => _dio.get(
        AppEndpoints.checkAccess,
        queryParameters: {'phoneNumber': phone},
      ),
      (json) => AccessCheckResult.fromJson(json),
    );
  }

  Future<ApiResult<String>> sendOtp(String phone) {
    AppLogger.i('AuthService', 'send OTP started');
    return _call<String>(
          () => _dio.post(
        AppEndpoints.userPhoneNumberOTP,
        queryParameters: {'phoneNumber': phone},
      ),
          (json) => (json['session'] ?? '').toString(),
    );
  }

  Future<ApiResult<AuthSession>> confirmOtp(
      String phone, String otp, String session) {
    AppLogger.i('AuthService', 'verify OTP started');
    return _call(
          () => _dio.post(
        AppEndpoints.userConfirmSignUp,
        data: {
          'phoneNumber': phone,
          'otpEntered': otp,
          if (session.isNotEmpty) 'session': session,
        },
      ),
          (json) => AuthSession.fromJson(json),
    );
  }

  Future<ApiResult<T>> _call<T>(
      Future<Response> Function() request,
      T Function(Map<String, dynamic> json)? parse,
      ) async {
    try {
      final response = await request();
      final body = response.data;

      if (body is! Map) {
        return ApiResult.failure('Unexpected response from server.');
      }

      final status = body['status'] == true;
      final message = (body['message'] ?? '').toString();
      final result = body['result'];

      T? data;
      if (status && parse != null && result is Map) {
        data = parse(Map<String, dynamic>.from(result));
      }
      AppLogger.d('AuthService', 'API status=$status message=$message');
      return ApiResult<T>(status: status, message: message, data: data);
    } on DioException catch (e) {
      final body = e.response?.data;
      final serverMsg = body is Map ? body['message']?.toString() : null;
      AppLogger.e('AuthService', 'API Dio error', e);
      return ApiResult.failure(
        serverMsg ?? e.message ?? 'Network error. Please try again.',
      );
    } catch (e) {
      AppLogger.e('AuthService', 'API error', e);
      return ApiResult.failure(e.toString());
    }
  }
}