import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/service_request/model/service_request_model.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class ServicesRepository {
  Future<Map<String, dynamic>> getDashboardServices() async {
    AppLogger.i('ServicesRepository', 'Fetch service requests started');
    try {
    final response =
        await DioClient.instance.get(AppEndpoints.adminDashboardServices);
    final data = response.data;
    if (data is! Map) {
      AppLogger.w('ServicesRepository', 'Unexpected services response');
      return {
        'counts': <String, int>{},
        'requests': <ServiceRequestModel>[],
      };
    }

    final result = data['result'];
    final counts = <String, int>{};
    final requests = <ServiceRequestModel>[];

    if (result is Map) {
      final rawCounts = result['categoryCounts'];
      if (rawCounts is List) {
        for (final item in rawCounts) {
          if (item is! Map) continue;
          final name = ServiceRequestModel.normalizeCategory(
            item['category']?.toString(),
          );
          final count = item['count'];
          counts[name] = count is int ? count : int.tryParse('$count') ?? 0;
        }
      }

      final rawRequests = result['serviceRequests'];
      if (rawRequests is List) {
        for (final item in rawRequests) {
          if (item is! Map) continue;
          requests.add(
            ServiceRequestModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    AppLogger.i(
      'ServicesRepository',
      'Fetch service requests success count=${requests.length}',
    );
    return {'counts': counts, 'requests': requests};
    } catch (e) {
      AppLogger.e('ServicesRepository', 'Fetch service requests failed', e);
      rethrow;
    }
  }

  Future<List<ServiceRequestModel>> getAllMaintenanceRequests() async {
    final data = await getDashboardServices();
    return List<ServiceRequestModel>.from(data['requests'] as List);
  }
}
