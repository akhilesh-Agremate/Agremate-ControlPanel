import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';

class PropertyRepository {
  Future<List<PropertyModel>> getAllProperties() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.allProperties);
      
      if (response.data['status'] == true) {
        final List<dynamic> result = response.data['result'];
        return result.map((json) => PropertyModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch properties');
      }
    } catch (e) {
      rethrow;
    }
  }
}
