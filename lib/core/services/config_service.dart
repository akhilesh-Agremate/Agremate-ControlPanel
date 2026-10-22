import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/network_utils/dio_client.dart';

class ConfigService {
  static String? _mapsKey;
  static Future<String>? _pending;

  static Future<String> googleMapsKey() {
    if (_mapsKey != null) return Future.value(_mapsKey!);
    return _pending ??= _load().whenComplete(() => _pending = null);
  }

  static Future<String> _load() async {
    final r = await DioClient.instance.get(AppEndpoints.config);
    final data = r.data;
    final key = (data is Map
        ? (data['googleMapsKey'] ??
        (data['result'] is Map ? data['result']['googleMapsKey'] : null))
        : null) as String?;
    if (key == null || key.isEmpty) {
      throw Exception('googleMapsKey missing in Config response');
    }
    return _mapsKey = key;
  }
  static void clear() => _mapsKey = null;
}