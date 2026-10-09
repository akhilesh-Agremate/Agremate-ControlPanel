import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/home/model/dashboard_overview_model.dart';
import 'package:agremate_admin/modules/home/model/rent_collection_model.dart';
import 'package:agremate_admin/modules/home/model/subscription_model.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class DashboardRepository {
  Future<DashboardOverviewModel> getOverview() async {
    try {
      final response =
      await DioClient.instance.get(AppEndpoints.adminDashboardOverview);
      AppLogger.d('DashboardRepository', 'getOverview success status=${response.statusCode}');

      final data = response.data;
      if (data is Map && data['result'] is Map) {
        return DashboardOverviewModel.fromJson(
          Map<String, dynamic>.from(data['result']),
        );
      }
      throw Exception('Unexpected overview response');
    } catch (e, stack) {
      AppLogger.e('DashboardRepository', 'getOverview failed', e, stack);
      rethrow;
    }
  }

  Future<List<RentCollectionModel>> getRentCollections() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardRentCollections,
      );
      AppLogger.d('DashboardRepository', 'getRentCollections success status=${response.statusCode}');

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
    } catch (e, stack) {
      AppLogger.e('DashboardRepository', 'getRentCollections failed', e, stack);
      rethrow;
    }
  }

  Future<List<RentCollectionModel>> getPendingPayments() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardPendingPayments,
      );
      AppLogger.d('DashboardRepository', 'getPendingPayments success status=${response.statusCode}');

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
    } catch (e, stack) {
      AppLogger.e('DashboardRepository', 'getPendingPayments failed', e, stack);
      rethrow;
    }
  }

  Future<List<SubscriptionModel>> getSubscriptions() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardSubscriptions,
      );
      AppLogger.d('DashboardRepository', 'getSubscriptions success status=${response.statusCode}');

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
            (json) => SubscriptionModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } catch (e, stack) {
      AppLogger.e('DashboardRepository', 'getSubscriptions failed', e, stack);
      rethrow;
    }
  }

  Future<List<SubscriptionModel>> getExpiredSubscriptions() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardExpiredSubscriptions,
      );
      AppLogger.d('DashboardRepository', 'getExpiredSubscriptions success status=${response.statusCode}');

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
            (json) => SubscriptionModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } catch (e, stack) {
      AppLogger.e('DashboardRepository', 'getExpiredSubscriptions failed', e, stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRecentActivity() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardRecentActivity,
      );
      AppLogger.d('DashboardRepository', 'getRecentActivity success status=${response.statusCode}');
      final data = response.data;
      if (data is Map && data['result'] is Map) {
        return Map<String, dynamic>.from(data['result']);
      }
      return {};
    } catch (e, stack) {
      AppLogger.e('DashboardRepository', 'getRecentActivity failed', e, stack);
      rethrow;
    }
  }
}