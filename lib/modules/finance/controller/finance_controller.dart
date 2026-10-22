import 'package:get/get.dart';
import 'package:agremate_admin/modules/finance/model/finance_model.dart';
import 'package:agremate_admin/network_utils/app_end_points.dart';
import 'package:agremate_admin/network_utils/dio_client.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class FinanceController extends GetxController {
  final overview = Rxn<FinanceOverview>();
  final properties = <FinanceProperty>[].obs;
  final isLoading = true.obs;
  final error = RxnString();
  final selectedPropertyId = RxnString();
  final selectedPropertyName = ''.obs;
  final detail = Rxn<FinancePropertyDetail>();
  final isDetailLoading = false.obs;
  final detailError = RxnString();

  @override
  void onReady() {
    super.onReady();
    loadAll();
  }

  Future<void> loadAll() async {
    AppLogger.i('FinanceController', 'Load finance started');
    isLoading.value = true;
    error.value = null;
    await Future.wait([fetchOverview(), fetchProperties()]);
    isLoading.value = false;
    AppLogger.i('FinanceController', 'Load finance finished');
  }

  Future<void> fetchOverview() async {
    try {
      final r = await DioClient.instance.get(AppEndpoints.financeOverview);
      final result = r.data is Map ? r.data['result'] : null;
      if (result is Map) {
        overview.value =
            FinanceOverview.fromJson(Map<String, dynamic>.from(result));
      } else {
        error.value = 'Invalid finance response';
      }
    } catch (e) {
      error.value = 'Failed to load finance overview';
    }
  }

  Future<void> fetchProperties() async {
    try {
      final r = await DioClient.instance.get(AppEndpoints.financeProperties);
      final result = r.data is Map ? r.data['result'] : null;
      if (result is List) {
        properties.value = result
            .map((e) => FinanceProperty.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      properties.clear();
    }
  }

  Future<void> selectProperty(String id, String name) async {
    selectedPropertyId.value = id;
    selectedPropertyName.value = name;
    detail.value = null;
    detailError.value = null;
    isDetailLoading.value = true;
    try {
      final r =
      await DioClient.instance.get(AppEndpoints.financePropertyDetail(id));
      if (selectedPropertyId.value != id) return;
      final result = r.data is Map ? r.data['result'] : null;
      if (result is Map) {
        detail.value =
            FinancePropertyDetail.fromJson(Map<String, dynamic>.from(result));
      } else {
        detailError.value = 'Invalid property response';
      }
    } catch (e) {
      detailError.value = 'Failed to load property payments';
    } finally {
      if (selectedPropertyId.value == id) isDetailLoading.value = false;
    }
  }

  void clearSelection() {
    selectedPropertyId.value = null;
    selectedPropertyName.value = '';
    detail.value = null;
    detailError.value = null;
  }

  List<RevenueRecord> get revenueRecords {
    final baseTrend = overview.value?.revenueTrend ?? [];

    if (selectedPropertyId.value != null && detail.value != null) {
      final propertyMonths = detail.value!.months;

      return baseTrend.map((t) {
        final targetMonth = '${t.monthName} ${t.year}';
        double amount = 0.0;

        for (var p in propertyMonths) {
          if (p.month.trim().toLowerCase() == targetMonth.toLowerCase()) {
            amount += p.amount;
          }
        }

        return RevenueRecord(
          month: t.monthName,
          amount: amount,
          year: t.year,
        );
      }).toList();
    }

    return baseTrend
        .map((t) => RevenueRecord(
            month: t.monthName, amount: t.revenue, year: t.year))
        .toList();
  }
}