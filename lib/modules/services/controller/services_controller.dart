import 'package:get/get.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/service_request/model/service_request_model.dart';
import 'package:agremate_admin/modules/services/repository/services_repository.dart';
import 'package:agremate_admin/core/constants/constants.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';

class ServicesController extends GetxController {
  final _repo = ServicesRepository();

  final serviceRequests = <ServiceRequestModel>[].obs;
  final recentRequests = <ServiceRequestModel>[].obs;
  final selectedServiceType = ''.obs;
  final filteredRequests = <ServiceRequestModel>[].obs;
  final categoryCounts = <String, int>{}.obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  Map<String, int> get serviceCounts {
    final counts = <String, int>{};
    for (final type in AppConstants.serviceTypes) {
      counts[type] = categoryCounts[type] ?? 0;
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
      AppLogger.i('ServicesController', 'Load service requests');
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _repo.getDashboardServices();
      final items = List<ServiceRequestModel>.from(data['requests'] as List);
      items.sort((a, b) => b.requestDate.compareTo(a.requestDate));

      if (_isRestricted() &&
          Get.isRegistered<PropertyController>() &&
          Get.find<PropertyController>().properties.isEmpty) {
        await Get.find<PropertyController>().fetchProperties();
      }

      final visible = _visibleRequests(items);
      serviceRequests.value = visible;
      recentRequests.value = visible.take(10).toList();

      if (_isRestricted()) {
        final counts = <String, int>{};
        for (final type in AppConstants.serviceTypes) {
          counts[type] = visible.where((r) => r.serviceType == type).length;
        }
        categoryCounts.assignAll(counts);
      } else {
        categoryCounts.assignAll(
          Map<String, int>.from(data['counts'] as Map),
        );
      }

      if (selectedServiceType.value.isNotEmpty) {
        filteredRequests.value =
            visible
                .where((r) => r.serviceType == selectedServiceType.value)
                .toList();
      }
      AppLogger.i(
        'ServicesController',
        'Service requests loaded count=${visible.length}',
      );
    } catch (e) {
      AppLogger.e('ServicesController', 'Load service requests failed', e);
      errorMessage.value = 'Failed to load service requests: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void selectServiceType(String type) {
    AppLogger.d('ServicesController', 'Select service type=$type');
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

  List<ServiceRequestModel> _visibleRequests(List<ServiceRequestModel> items) {
    if (!Get.isRegistered<AuthController>()) return items;
    final auth = Get.find<AuthController>();
    if (!auth.isRestrictedRole) return items;

    final ids = <String>{};
    final names = <String>{};
    if (Get.isRegistered<PropertyController>()) {
      for (final p in Get.find<PropertyController>().properties) {
        if (p.id.isNotEmpty) ids.add(p.id);
        if (p.name.isNotEmpty) names.add(p.name.toLowerCase());
      }
    }

    final userName = auth.userName.value.trim().toLowerCase();
    return items.where((r) {
      if (r.propertyId.isNotEmpty && ids.contains(r.propertyId)) return true;
      if (r.propertyName.isNotEmpty &&
          names.contains(r.propertyName.toLowerCase())) {
        return true;
      }
      if (auth.isLandlord &&
          userName.isNotEmpty &&
          r.landlordName.trim().toLowerCase() == userName) {
        return true;
      }
      if (auth.isTenant &&
          userName.isNotEmpty &&
          r.tenantName.trim().toLowerCase() == userName) {
        return true;
      }
      return false;
    }).toList();
  }

  bool _isRestricted() {
    if (!Get.isRegistered<AuthController>()) return false;
    return Get.find<AuthController>().isRestrictedRole;
  }
}
