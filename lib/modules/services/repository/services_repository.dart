import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/service_request/model/service_request_model.dart';

class ServicesRepository {
  Future<List<ServiceRequestModel>> getAllMaintenanceRequests() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.allMaintenanceRequests);
      print('ServicesRepository response: ${response.data}');

      final List<dynamic> result;
      if (response.data is List) {
        result = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['result'] != null) {
        result = response.data['result'] as List<dynamic>;
      } else if (response.data is Map) {
        // Handle single object response by wrapping it in a list
        result = [response.data];
      } else {
        result = [];
      }

      print('ServicesRepository: ${result.length} records');
      return result
          .where((e) => e != null)
          .map((json) => ServiceRequestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print('ServicesRepository error: $e');
      print(stack);
      rethrow;
    }
  }
}
