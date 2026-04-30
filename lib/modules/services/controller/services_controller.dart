import 'dart:math';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/service_request/model/service_request_model.dart';
import 'package:agremate_admin/core/constants/constants.dart';

class ServicesController extends GetxController {
  final serviceRequests = <ServiceRequestModel>[].obs;
  final selectedServiceType = ''.obs;
  final filteredRequests = <ServiceRequestModel>[].obs;
  final isLoading = true.obs;
  final _rng = Random(42);

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
      counts[type] = serviceRequests.where((r) => r.serviceType == type && r.isPending).length;
    }
    return counts;
  }

  @override
  void onInit() {
    super.onInit();
    _generateData();
  }

  void _generateData() {
    isLoading.value = true;
    final properties = [
      'Andheri Apartment 1', 'Bandra Villa 3', 'Powai Studio 5', 'Juhu Penthouse 2',
      'Malad Duplex 4', 'Goregaon Apartment 7', 'Thane Commercial 1', 'Worli Studio 8',
      'Dadar Apartment 12', 'Kurla Villa 6', 'Indiranagar Apartment 3', 'Koramangala Villa 2',
    ];
    final tenantNames = [
      'Aarav Menon', 'Ishika Sen', 'Rohan Pillai', 'Diya Chopra', 'Arjun Saxena',
      'Meera Kulkarni', 'Varun Bansal', 'Nisha Pandey', 'Siddharth Jain', 'Tanya Malhotra',
    ];
    final descriptions = {
      'Plumbing': ['Leaking faucet', 'Blocked drain', 'Pipe burst', 'Water heater issue'],
      'Electricity': ['Power outage', 'Faulty wiring', 'Switch replacement', 'MCB tripping'],
      'Pest Control': ['Cockroach infestation', 'Termite treatment', 'Rat problem', 'Mosquito spray'],
      'Community': ['Parking dispute', 'Noise complaint', 'Common area cleaning', 'Garden maintenance'],
      'Mechanical': ['Lift breakdown', 'Generator issue', 'Pump malfunction', 'Gate motor repair'],
      'Maintenance': ['Wall painting', 'Floor repair', 'Window fixing', 'Door alignment'],
      'Security': ['CCTV not working', 'Gate lock broken', 'Intercom issue', 'Security guard complaint'],
      'Others': ['Key duplication', 'Name plate change', 'General inquiry', 'Visitor management'],
    };
    final statuses = ['pending', 'in_progress', 'completed'];
    final priorities = ['low', 'medium', 'high'];

    final requests = <ServiceRequestModel>[];
    for (int i = 0; i < 60; i++) {
      final type = AppConstants.serviceTypes[_rng.nextInt(AppConstants.serviceTypes.length)];
      final descs = descriptions[type]!;
      requests.add(ServiceRequestModel(
        id: 'SR${i + 1}',
        propertyId: 'P${_rng.nextInt(12) + 1}',
        propertyName: properties[_rng.nextInt(properties.length)],
        tenantName: tenantNames[_rng.nextInt(tenantNames.length)],
        serviceType: type,
        description: descs[_rng.nextInt(descs.length)],
        status: statuses[_rng.nextInt(statuses.length)],
        requestDate: DateTime.now().subtract(Duration(days: _rng.nextInt(30))),
        priority: priorities[_rng.nextInt(priorities.length)],
      ));
    }
    serviceRequests.value = requests;
    isLoading.value = false;
  }

  void selectServiceType(String type) {
    if (selectedServiceType.value == type) {
      selectedServiceType.value = '';
      filteredRequests.value = [];
    } else {
      selectedServiceType.value = type;
      filteredRequests.value = serviceRequests.where((r) => r.serviceType == type).toList();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      if (selectedServiceType.value.isNotEmpty) {
        filteredRequests.value = serviceRequests.where((r) => r.serviceType == selectedServiceType.value).toList();
      }
      return;
    }
    var base = selectedServiceType.value.isNotEmpty
        ? serviceRequests.where((r) => r.serviceType == selectedServiceType.value)
        : serviceRequests;
    filteredRequests.value = base.where((r) =>
      r.propertyName.toLowerCase().contains(query.toLowerCase()) ||
      r.tenantName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
