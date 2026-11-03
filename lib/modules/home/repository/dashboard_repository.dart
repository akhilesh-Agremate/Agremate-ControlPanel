import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/modules/home/model/dashboard_overview_model.dart';
import 'package:agremate_admin/modules/home/model/registered_user_models.dart';
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

  Future<List<RegisteredLandlordItem>> getRegisteredLandlords() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.allLandlordDetails,
        queryParameters: {'page': 1, 'pageSize': 50},
      );
      AppLogger.d(
        'DashboardRepository',
        'getRegisteredLandlords success status=${response.statusCode}',
      );
      return _asMapList(response.data)
          .map(RegisteredLandlordItem.fromJson)
          .toList();
    } catch (e, stack) {
      AppLogger.e(
        'DashboardRepository',
        'getRegisteredLandlords failed',
        e,
        stack,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPropertyCreationTrend() async {
    try {
      final statsResponse = await DioClient.instance.get(
        AppEndpoints.adminDashboardPropertyStats,
      );
      AppLogger.d(
        'DashboardRepository',
        'getPropertyCreationTrend stats status=${statsResponse.statusCode}',
      );
      final fromStats = _trendFromStats(statsResponse.data);
      if (fromStats.isNotEmpty) return fromStats;
    } catch (e, stack) {
      AppLogger.e(
        'DashboardRepository',
        'getPropertyCreationTrend stats failed',
        e,
        stack,
      );
    }

    try {
      final response = await DioClient.instance.get(
        AppEndpoints.adminDashboardProperties,
      );
      return _trendFromProperties(_asMapList(response.data));
    } catch (e, stack) {
      AppLogger.e(
        'DashboardRepository',
        'getPropertyCreationTrend properties failed',
        e,
        stack,
      );
      rethrow;
    }
  }

  List<Map<String, dynamic>> _trendFromStats(dynamic data) {
    if (data is! Map) return const [];
    final result = data['result'];
    if (result is! Map) return const [];
    final chart = result['propertiesChart'];
    if (chart is List && chart.isNotEmpty) {
      final points = <Map<String, dynamic>>[];
      for (final item in chart) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final label = (map['monthName'] ?? map['label'] ?? '').toString();
        if (label.isEmpty) continue;
        final raw = map['count'] ??
            map['value'] ??
            map['propertiesCount'] ??
            map['createdCount'] ??
            map['total'];
        points.add({
          'label': label,
          'value': raw is num ? raw.toInt() : int.tryParse('$raw') ?? 0,
        });
      }
      if (points.isNotEmpty) return points;
    }
    final spark = result['propertiesSparkline'];
    if (spark is List && spark.isNotEmpty) {
      final labels = <String>[];
      if (chart is List) {
        for (final item in chart) {
          if (item is Map) {
            labels.add((item['monthName'] ?? item['label'] ?? '').toString());
          }
        }
      }
      final points = <Map<String, dynamic>>[];
      for (var i = 0; i < spark.length; i++) {
        final raw = spark[i];
        points.add({
          'label': i < labels.length && labels[i].isNotEmpty
              ? labels[i]
              : '${i + 1}',
          'value': raw is num ? raw.toInt() : int.tryParse('$raw') ?? 0,
        });
      }
      return points;
    }
    return const [];
  }

  List<Map<String, dynamic>> _trendFromProperties(
    List<Map<String, dynamic>> properties,
  ) {
    final now = DateTime.now();
    final points = <Map<String, dynamic>>[];
    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      var count = 0;
      for (final item in properties) {
        final raw = (item['createdDate'] ??
                item['createdAt'] ??
                item['createdOn'] ??
                '')
            .toString();
        final date = DateTime.tryParse(raw);
        if (date != null &&
            date.year == month.year &&
            date.month == month.month) {
          count++;
        }
      }
      points.add({
        'label': [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ][month.month - 1],
        'value': count,
      });
    }
    return points;
  }

  Future<List<RegisteredTenantItem>> getRegisteredTenants() async {
    try {
      final response = await DioClient.instance.get(
        AppEndpoints.allTenants,
        queryParameters: {'page': 1, 'pageSize': 50},
      );
      AppLogger.d(
        'DashboardRepository',
        'getRegisteredTenants success status=${response.statusCode}',
      );
      return _asMapList(response.data)
          .map(RegisteredTenantItem.fromJson)
          .toList();
    } catch (e, stack) {
      AppLogger.e(
        'DashboardRepository',
        'getRegisteredTenants failed',
        e,
        stack,
      );
      rethrow;
    }
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    List<dynamic> list = const [];
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final result = data['result'];
      if (result is List) {
        list = result;
      } else if (result is Map) {
        for (final key in ['items', 'data', 'landlords', 'tenants']) {
          if (result[key] is List) {
            list = result[key] as List;
            break;
          }
        }
      }
    }
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}