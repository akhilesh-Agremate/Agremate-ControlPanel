import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/home/model/dashboard_overview_model.dart';
import 'package:agremate_admin/modules/home/model/rent_collection_model.dart';

class DashboardRepository {
  Future<DashboardOverviewModel> getOverview() async {
    try {
      final response =
      await DioClient.instance.get(AppEndpoints.adminDashboardOverview);
      print('DashboardRepository.getOverview Response: ${response.data}');

      final data = response.data;
      if (data is Map && data['result'] is Map) {
        return DashboardOverviewModel.fromJson(
          Map<String, dynamic>.from(data['result']),
        );
      }
      throw Exception('Unexpected overview response');
    } catch (e) {
      print('DashboardRepository.getOverview Error: $e');
      rethrow;
    }
  }

  Future<List<RentCollectionModel>> getRentCollections() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardRentCollections,
      );
      print('DashboardRepository.getRentCollections Response: ${response.data}');

      final List<dynamic> result;
      if (response.data is List) {
        result = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['result'] is List) {
        result = response.data['result'] as List<dynamic>;
      } else {
        result = [];
      }

      return result
          .whereType<Map>()
          .map(
            (json) => RentCollectionModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } catch (e) {
      print('DashboardRepository.getRentCollections Error: $e');
      rethrow;
    }
  }

  Future<List<RentCollectionModel>> getPendingPayments() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardPendingPayments,
      );
      print('DashboardRepository.getPendingPayments Response: ${response.data}');

      final List<dynamic> result;
      if (response.data is List) {
        result = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['result'] is List) {
        result = response.data['result'] as List<dynamic>;
      } else {
        result = [];
      }

      return result
          .whereType<Map>()
          .map(
            (json) => RentCollectionModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } catch (e) {
      print('DashboardRepository.getPendingPayments Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRecentActivity() async {
    final response = await DioClient.instance.get(
      AppEndpoints.adminDashboardRecentActivity,
    );
    final data = response.data;
    if (data is Map && data['result'] is Map) {
      return Map<String, dynamic>.from(data['result']);
    }
    return {};
  }
}