import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class AdminControlRepository {
  Future<bool> getLandlordContactAccess() async {
    AppLogger.i('AdminControlRepository', 'getLandlordContactAccess started');
    try {
      final response =
      await DioClient.instance.get(AppEndpoints.adminControlSettings);
      AppLogger.i('AdminControlRepository', 'settings response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == true) {
          final result = data['result'];
          if (result is bool) return result;
          if (result is String) return result.toLowerCase() == 'true';
          if (result is Map) {
            final v = result['landlordContactAccess'] ??
                result['hasAccess'] ??
                result['isContactMaskEnabled'];
            if (v is bool) return v;
            if (v is String) return v.toLowerCase() == 'true';
          }
          return false;
        }
        throw Exception(data?['message'] ?? 'Failed to get landlord contact access');
      }
      throw Exception('Failed to get landlord contact access: Status code ${response.statusCode}');
    } catch (e, stack) {
      AppLogger.e('AdminControlRepository', 'getLandlordContactAccess failed', e, stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> setLandlordContactAccess(bool hasAccess) async {
    AppLogger.i('AdminControlRepository', 'setLandlordContactAccess started with hasAccess=$hasAccess');
    try {
      final response = await DioClient.instance.post(
        AppEndpoints.landlordContactAccess,
        data: {'hasAccess': hasAccess},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == true) {
          return Map<String, dynamic>.from(data);
        }
        throw Exception(data?['message'] ?? 'Failed to update landlord contact access');
      }
      throw Exception('Failed to update landlord contact access: Status code ${response.statusCode}');
    } catch (e, stack) {
      AppLogger.e('AdminControlRepository', 'setLandlordContactAccess failed', e, stack);
      rethrow;
    }
  }
}
