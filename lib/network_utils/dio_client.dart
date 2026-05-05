import 'package:dio/dio.dart';
import 'internet_check_interceptor.dart';
import 'network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: 'https://api-dev.app.agremate.com/api',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'accept': '*/*',
          },
        ),
      );

      // Add Interceptors
      _dio!.interceptors.add(
        InternetCheckInterceptor(
          networkInfo: NetworkInfoImpl(InternetConnectionChecker.instance),
        ),
      );

      // Log interceptor for debugging
      _dio!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
    return _dio!;
  }
}
