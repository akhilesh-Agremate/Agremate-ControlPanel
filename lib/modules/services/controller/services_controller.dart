import 'package:get/get.dart';
import 'package:agremate_admin/modules/service_request/model/service_request_model.dart';
import 'package:agremate_admin/modules/services/repository/services_repository.dart';
import 'package:agremate_admin/core/constants/constants.dart';

class ServicesController extends GetxController {
  final _repo = ServicesRepository();

  final serviceRequests = <ServiceRequestModel>[].obs;
  final recentRequests = <ServiceRequestModel>[].obs;
  final selectedServiceType = ''.obs;
  final filteredRequests = <ServiceRequestModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // ── Computed counts from real API data ──────────────────────────────────
  Map<String, int> get serviceCounts {
    final counts = <String, int>{};
    for (final type in AppConstants.serviceTypes) {
      counts[type] = serviceRequests.where((r) => r.serviceType == type).length;
    }
    return counts;
  }

  Map<String, int> get pendingCounts {
    final counts = <String, int>{};
    for (final type in AppConstants.serviceTypes) {
      counts[type] =
          serviceRequests
              .where((r) => r.serviceType == type && r.isPending)
              .length;
    }
    return counts;
  }

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _repo.getAllMaintenanceRequests();

      // Sort by requestDate (descending)
      data.sort((a, b) => b.requestDate.compareTo(a.requestDate));

      serviceRequests.value = data;

      // Get top 10 most recent
      recentRequests.value = data.take(10).toList();

      // Re-apply filter if a type is selected
      if (selectedServiceType.value.isNotEmpty) {
        filteredRequests.value =
            data
                .where((r) => r.serviceType == selectedServiceType.value)
                .toList();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load service requests: $e';
      print('ServicesController.fetchRequests error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectServiceType(String type) {
    if (selectedServiceType.value == type) {
      selectedServiceType.value = '';
      filteredRequests.value = [];
    } else {
      selectedServiceType.value = type;
      filteredRequests.value =
          serviceRequests.where((r) => r.serviceType == type).toList();
    }
  }

  final searchQuery = ''.obs;

  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      if (selectedServiceType.value.isNotEmpty) {
        filteredRequests.value =
            serviceRequests
                .where((r) => r.serviceType == selectedServiceType.value)
                .toList();
      } else {
        filteredRequests.value = [];
      }
      return;
    }

    // Global search across all requests when a query is present
    filteredRequests.value =
        serviceRequests
            .where(
              (r) =>
                  r.propertyName.toLowerCase().contains(query.toLowerCase()) ||
                  r.tenantName.toLowerCase().contains(query.toLowerCase()) ||
                  r.description.toLowerCase().contains(query.toLowerCase()) ||
                  r.serviceType.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
  }

  void refresh() => fetchRequests();
}
