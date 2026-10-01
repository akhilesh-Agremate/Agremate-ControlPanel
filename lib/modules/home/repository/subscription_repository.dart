import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/home/model/subscription_summary_model.dart';

class SubscriptionRepository {
  Future<List<SubscriptionSummaryModel>> getSubscriptionSummaries() async {
    try {
      final response = await DioClient.instance.get(AppEndpoints.landlordSubscriptionSummary);
      print('SubscriptionRepository.getSubscriptionSummaries Response: ${response.data}');

      final List<dynamic> result;
      if (response.data is List) {
        result = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['result'] != null) {
        result = response.data['result'] is List
            ? response.data['result'] as List<dynamic>
            : [response.data['result']];
      } else if (response.data is Map) {
        return [SubscriptionSummaryModel.fromJson(response.data)];
      } else {
        result = [];
      }

      return result
          .map((json) => SubscriptionSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('SubscriptionRepository.getSubscriptionSummaries Error: $e');
      rethrow;
    }
  }
}
