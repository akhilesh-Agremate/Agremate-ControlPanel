import 'package:dio/dio.dart';
import 'network_info.dart';

class InternetCheckInterceptor extends Interceptor {
  final NetworkInfo networkInfo;

  InternetCheckInterceptor({required this.networkInfo});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (await networkInfo.isConnected) {
      return handler.next(options);
    } else {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: "No internet connection",
          type: DioExceptionType.connectionError,
        ),
      );
    }
  }
}
