import 'package:dio/dio.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class DioLogInterceptor extends Interceptor {
  static const _tag = 'HTTP';
  static const _startKey = '_log_start_ms';
  static const _maxBody = 1500;
  static const _secretKeys = {
    'authorization', 'password', 'token', 'accesstoken', 'refreshtoken',
    'idtoken', 'otp', 'secret', 'clientsecret', 'razorpayclientsecret',
    'googlemapskey', 'apikey',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    AppLogger.d(
      _tag,
      '--> ${options.method} ${options.uri}\n'
          'headers: ${_mask(options.headers)}\n'
          'body: ${_body(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.i(
      _tag,
      '<-- ${response.statusCode} ${response.requestOptions.method} '
          '${response.requestOptions.uri} (${_ms(response.requestOptions)} ms)\n'
          'body: ${_body(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    AppLogger.e(
      _tag,
      'x-- ${err.response?.statusCode ?? err.type.name} ${o.method} ${o.uri} '
          '(${_ms(o)} ms)\n'
          'message: ${err.message}\n'
          'response: ${_body(err.response?.data)}',
      err.error,
    );
    handler.next(err);
  }

  int _ms(RequestOptions o) {
    final s = o.extra[_startKey];
    return s is int ? DateTime.now().millisecondsSinceEpoch - s : -1;
  }

  String _body(dynamic data) {
    if (data == null) return '-';
    if (data is FormData) {
      return 'FormData(files: ${data.files.map((f) => f.key).toList()}, '
          'fields: ${data.fields.length})';
    }
    final s = _maskValue(data).toString();
    return s.length > _maxBody ? '${s.substring(0, _maxBody)}… (truncated)' : s;
  }

  dynamic _maskValue(dynamic v) {
    if (v is Map) return _mask(v);
    if (v is List) return v.map(_maskValue).toList();
    return v;
  }

  Map<String, dynamic> _mask(Map m) => {
    for (final e in m.entries)
      e.key.toString(): _secretKeys.contains(
          e.key.toString().toLowerCase().replaceAll('_', ''))
          ? '***'
          : _maskValue(e.value),
  };
}