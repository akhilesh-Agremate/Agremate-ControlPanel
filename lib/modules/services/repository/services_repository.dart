import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/service_request/model/service_request_model.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

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

  Future<ServiceRequestModel> getServiceDetail(String id) async {
    final response =
        await DioClient.instance.get(AppEndpoints.adminServiceDetail(id));
    AppLogger.d(
      'ServicesRepository',
      'getServiceDetail status=${response.statusCode}',
    );
    final data = response.data;
    final result = data is Map ? data['result'] : null;
    if (result is! Map) throw Exception('Unexpected chat response');
    final map = Map<String, dynamic>.from(result);
    final inner = map['serviceRequest'];
    final json = inner is Map ? Map<String, dynamic>.from(inner) : map;
    if (json['messages'] == null && map['messages'] is List) {
      json['messages'] = map['messages'];
    }
    if (json['chatMessages'] == null && map['chatMessages'] is List) {
      json['chatMessages'] = map['chatMessages'];
    }
    return ServiceRequestModel.fromJson(json);
  }

  Future<void> sendMessage(
      String id,
      String message, {
        List<PlatformFile> files = const [],
      }) async {
    try {
      final form = FormData();
      form.fields.add(MapEntry('Message', message));

      for (final f in files) {
        final bytes = await f.readAsBytes();
        form.files.add(
          MapEntry('Files', MultipartFile.fromBytes(bytes, filename: f.name)),
        );
      }

      final response = await DioClient.instance.post(
        AppEndpoints.adminServiceMessages(id),
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data;
      if (data is Map && data['status'] == false) {
        throw Exception(data['message'] ?? 'Failed to send message');
      }
    } on DioException catch (e) {
      final d = e.response?.data;
      throw Exception(d is Map && d['message'] != null
          ? d['message'].toString()
          : (e.message ?? 'Failed to send message'));
    }
  }

  Future<List<ServiceRequestModel>> getAllMaintenanceRequests() async {
    final data = await getDashboardServices();
    return List<ServiceRequestModel>.from(data['requests'] as List);
  }
  Future<List<String>> getStatuses() async {
    AppLogger.i('ServicesRepository', 'Fetch statuses started');
    try {
      final response = await DioClient.instance
          .get(AppEndpoints.maintenanceRequestStatuses);
      final data = response.data;
      if (data is! Map || data['result'] is! List) {
        AppLogger.w('ServicesRepository', 'Unexpected statuses response');
        return <String>[];
      }
      final statuses =
      (data['result'] as List).map((e) => e.toString()).toList();
      AppLogger.i(
        'ServicesRepository',
        'Fetch statuses success count=${statuses.length}',
      );
      return statuses;
    } catch (e) {
      AppLogger.e('ServicesRepository', 'Fetch statuses failed', e);
      rethrow;
    }
  }

  Future<void> updateStatus({
    required String requestId,
    required String newStatus,
    String? rejectionReason,
  }) async {
    AppLogger.i('ServicesRepository', 'Update status $requestId -> $newStatus');
    try {
      final response = await DioClient.instance.put(
        AppEndpoints.maintenanceRequestUpdateStatus,
        queryParameters: {'newStatus': newStatus},
        data: {
          'requestId': requestId,
          'newStatus': newStatus,
          'rejectionReason': rejectionReason ?? '',
        },
      );
      final data = response.data;
      if (data is Map && data['status'] == true) return;
      throw Exception(
        data is Map ? (data['message'] ?? 'Update failed') : 'Update failed',
      );
    } catch (e) {
      AppLogger.e('ServicesRepository', 'Update status failed', e);
      rethrow;
    }
  }
}
