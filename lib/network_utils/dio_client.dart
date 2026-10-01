import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/routes/app_routes.dart';
import '../config.dart';
import 'internet_check_interceptor.dart';
import 'network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class DioClient {
  static Dio? _dio;
  static String? authHeader;

  static Dio get instance {
    if (_dio == null) {
      final env = ConfigEnvironments.getEnvironments();

      _dio = Dio(
        BaseOptions(
          baseUrl: '${env['baseUrl']}${AppEndpoints.api}',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'accept': '*/*'},
        ),
      );

      _dio!.interceptors.add(
        InternetCheckInterceptor(
          networkInfo: NetworkInfoImpl(InternetConnectionChecker.instance),
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (authHeader != null && authHeader!.isNotEmpty) {
              options.headers['Authorization'] = authHeader;
            }
            handler.next(options);
          },
          onError: (e, handler) {
            final isAuthCall =
                e.requestOptions.path.contains('/User/phone-number-otp') ||
                    e.requestOptions.path.contains('/User/confirm-signup');
            if (e.response?.statusCode == 401 &&
                !isAuthCall &&
                authHeader != null) {
              authHeader = null;
              if (Get.currentRoute != AppRoutes.login) {
                Get.offAllNamed(AppRoutes.login);
              }
            }
            handler.next(e);
          },
        ),
      );

      _dio!.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
    return _dio!;
  }
}