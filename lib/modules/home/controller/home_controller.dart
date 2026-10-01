import 'package:get/get.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/modules/service_request/model/service_request_model.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';

import '../model/dashboard_overview_model.dart';
import '../model/rent_collection_model.dart';
import '../repository/dashboard_repository.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  final _dashboardRepo = DashboardRepository();
  final overview = Rxn<DashboardOverviewModel>();
  final isOverviewLoading = false.obs;
  final showRentCollectionDetails = false.obs;
  final rentCollections = <RentCollectionModel>[].obs;
  final isRentCollectionsLoading = false.obs;
  final rentCollectionsError = ''.obs;
  final showPendingPaymentDetails = false.obs;
  final pendingPayments = <RentCollectionModel>[].obs;
  final isPendingPaymentsLoading = false.obs;
  final pendingPaymentsError = ''.obs;

  final List<String> periods = [
    'This Month',
    'Last Month',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
  ];

  var globalPeriod = 'This Month'.obs;
  var rentPeriod = 'This Month'.obs;
  var pendingPeriod = 'This Month'.obs;
  var subAmountPeriod = 'This Month'.obs;
  var subExpiredPeriod = 'This Month'.obs;

  void updateGlobalPeriod(String newPeriod) {
    globalPeriod.value = newPeriod;
    rentPeriod.value = newPeriod;
    pendingPeriod.value = newPeriod;
    subAmountPeriod.value = newPeriod;
    subExpiredPeriod.value = newPeriod;
  }

  final searchQuery = ''.obs;
  final filteredResults = <Map<String, dynamic>>[].obs;

  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredResults.clear();
      return;
    }

    final q = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    results.addAll(
      propertyList.where(
        (item) =>
            (item['title'] ?? '').toString().toLowerCase().contains(q) ||
            (item['landlordName'] ?? '').toString().toLowerCase().contains(q) ||
            (item['tenantName'] ?? '').toString().toLowerCase().contains(q),
      ),
    );

    results.addAll(
      recentServices.where(
        (item) =>
            (item['propertyName'] ?? '').toString().toLowerCase().contains(q) ||
            (item['tenantName'] ?? '').toString().toLowerCase().contains(q) ||
            (item['description'] ?? '').toString().toLowerCase().contains(q),
      ),
    );
    results.addAll(
      recentRent.where(
        (item) =>
            (item['propertyName'] ?? '').toString().toLowerCase().contains(q) ||
            (item['tenantName'] ?? '').toString().toLowerCase().contains(q),
      ),
    );

    results.addAll(
      recentSubs.where(
        (item) =>
            (item['title'] ?? '').toString().toLowerCase().contains(q) ||
            (item['landlordName'] ?? '').toString().toLowerCase().contains(q),
      ),
    );

    final seen = <String>{};
    filteredResults.assignAll(
      results.where((r) => seen.add('${r['id']}-${r['title']}')).toList(),
    );
  }

  List<Map<String, dynamic>> getFilteredData(
    List<Map<String, dynamic>> rawData,
    String query,
  ) {
    if (query.isEmpty) return rawData;
    final q = query.toLowerCase();
    return rawData.where((item) {
      final textToSearch =
          [
            item['title'],
            item['propertyName'],
            item['tenantName'],
            item['landlordName'],
            item['location'],
            item['detail'],
            item['description'],
          ].join(' ').toLowerCase();
      return textToSearch.contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchOverview();
    fetchRecentActivity();
  }

  Future<void> fetchOverview() async {
    try {
      print('fetchOverview: starting');
      isOverviewLoading.value = true;
      overview.value = await _dashboardRepo.getOverview();
      print('fetchOverview: success ${overview.value?.totalRentCollections}');
    } catch (e, st) {
      print('HomeController.fetchOverview error: $e');
      print(st);
      overview.value = null;
    } finally {
      isOverviewLoading.value = false;
    }
  }

  String _formatINR(num value) {
    final s = value.round().abs().toString();
    String grouped;
    if (s.length <= 3) {
      grouped = s;
    } else {
      final last3 = s.substring(s.length - 3);
      var rest = s.substring(0, s.length - 3);
      final parts = <String>[];
      while (rest.length > 2) {
        parts.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) parts.insert(0, rest);
      grouped = '${parts.join(',')},$last3';
    }
    return '${value < 0 ? '-' : ''}₹$grouped';
  }

  Future<void> fetchRecentActivity() async {
    try {
      isLoading.value = true;
      final result = await _dashboardRepo.getRecentActivity();
      final createdDates = <String, String>{};
      for (final item in _asMapList(result['recentProperties'])) {
        final id = (item['propertyId'] ?? item['id'] ?? '').toString();
        final created = _formatDateString(
          item['createdDate'] ?? item['createdAt'],
        );
        if (id.isNotEmpty && created.isNotEmpty) {
          createdDates[id] = created;
        }
      }

      recentRent.assignAll(
        _visibleActivityMaps(
          _asMapList(result['recentRentCollections']).map((item) {
            final propertyId = (item['propertyId'] ?? '').toString();
            return {
              'id': propertyId,
              'title': item['propertyName'] ?? '',
              'propertyName': item['propertyName'] ?? '',
              'tenantName': item['tenantName'] ?? 'N/A',
              'landlordName': item['landlordName'] ?? 'N/A',
              'rentAmount': '₹${_formatAmount(item['rent'])}',
              'advanceAmount': '₹${_formatAmount(item['advance'])}',
              'status': item['status'] ?? '',
              'location': item['location'] ?? '',
              'joinedDate': _formatDateString(item['joinedDate']),
              'paymentDate': _formatDateString(item['paymentDate']),
              'createdDate': createdDates[propertyId] ?? '',
              'type': 'rent',
            };
          }).toList(),
        ),
      );

      recentSubs.assignAll(
        _visibleActivityMaps(
          _asMapList(result['recentSubscriptions']).map((item) {
            return {
              'id': (item['id'] ?? item['landlordId'] ?? '').toString(),
              'title': item['landlordName'] ?? 'Subscription',
              'propertyName': item['planName'] ?? '',
              'landlordName': item['landlordName'] ?? 'N/A',
              'type': 'subscription',
              'status': item['status'] ?? '',
              'detail': item['planName'] ?? '',
            };
          }).toList(),
        ),
      );

      recentServices.assignAll(
        _visibleActivityMaps(
          _asMapList(result['recentServiceRequests']).map((item) {
            final model = ServiceRequestModel.fromJson(item);
            return {
              'id': model.id,
              'title': model.propertyName,
              'propertyName': model.propertyName,
              'detail': 'Issue: ${model.description}',
              'landlordName':
                  model.landlordName.isNotEmpty ? model.landlordName : 'N/A',
              'tenantName':
                  model.tenantName.isNotEmpty ? model.tenantName : 'N/A',
              'location': item['location'] ?? model.location,
              'raisedDate': _formatDate(model.requestDate),
              'resolvedDate': model.completedDate != null
                  ? _formatDate(model.completedDate!)
                  : null,
              'status': item['status'] ?? model.status,
              'chatMessages': model.chatMessages,
              'type': 'service',
              'rawModel': model,
            };
          }).toList(),
        ),
      );

      propertyList.assignAll(
        _visibleActivityMaps(
          _asMapList(result['recentProperties']).map((item) {
            return {
              'id': (item['propertyId'] ?? item['id'] ?? '').toString(),
              'title': item['propertyName'] ?? item['name'] ?? '',
              'landlordName': item['landlordName'] ?? 'N/A',
              'tenantName': item['tenantName'] ?? 'N/A',
              'location': item['location'] ?? item['address'] ?? '',
              'status': item['status'] ?? '',
              'joinedDate': _formatDateString(item['createdDate']),
              'propertyImages': item['thumbnailUrl'] != null &&
                      item['thumbnailUrl'].toString().isNotEmpty
                  ? [item['thumbnailUrl'].toString()]
                  : <String>[],
              'type': 'property',
            };
          }).toList(),
        ),
      );

      final docs = _asMapList(result['recentDocuments']).map((item) {
        final fileName =
            (item['fileName'] ?? item['documentName'] ?? '').toString();
        final ext = fileName.contains('.')
            ? fileName.split('.').last.toLowerCase()
            : 'pdf';
        return <String, dynamic>{
          'id': (item['documentId'] ?? item['id'] ?? '').toString(),
          'title': fileName,
          'propertyId': (item['propertyId'] ?? '').toString(),
          'propertyName': item['propertyName'] ?? 'Unknown Property',
          'tenantName': item['tenantName'] ?? 'N/A',
          'landlordName': item['landlordName'] ?? 'N/A',
          'fileTypes': [ext],
          'date': _formatDateString(
            item['uploadedDate'] ?? item['createdDate'],
          ),
          'sortDate': DateTime.tryParse(
                (item['uploadedDate'] ?? item['createdDate'] ?? '').toString(),
              ) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          'type': 'document',
          'thumbnailUrl': item['thumbnailUrl'] ?? '',
          'relativePath': item['documentUrl'] ?? '',
          'documentUrl': item['documentUrl'] ?? '',
        };
      }).toList();
      docs.sort(
        (a, b) => (b['sortDate'] as DateTime).compareTo(a['sortDate'] as DateTime),
      );
      final uniqueDocs = <String, Map<String, dynamic>>{};
      for (final doc in docs) {
        final key = (doc['propertyId'] as String).isNotEmpty
            ? doc['propertyId'] as String
            : doc['propertyName'] as String;
        uniqueDocs.putIfAbsent(key, () => doc);
      }
      documentList.assignAll(_visibleActivityMaps(uniqueDocs.values.toList()));
    } catch (e) {
      recentRent.clear();
      recentSubs.clear();
      recentServices.clear();
      propertyList.clear();
      documentList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String _formatDateString(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return '';
    return _formatDate(parsed);
  }

  List<Map<String, dynamic>> _visibleActivityMaps(
    List<Map<String, dynamic>> items,
  ) {
    if (!Get.isRegistered<AuthController>()) return items;
    final auth = Get.find<AuthController>();
    if (!auth.isRestrictedRole) return items;

    final propertyIds = <String>{};
    final propertyNames = <String>{};
    if (Get.isRegistered<PropertyController>()) {
      for (final p in Get.find<PropertyController>().properties) {
        if (p.id.isNotEmpty) propertyIds.add(p.id);
        if (p.name.isNotEmpty) propertyNames.add(p.name.toLowerCase());
      }
    }
    final userName = auth.userName.value.trim().toLowerCase();
    return items.where((item) {
      final propertyId = (item['id'] ?? item['propertyId'] ?? '').toString();
      final propertyName =
          (item['propertyName'] ?? item['title'] ?? '').toString().toLowerCase();
      if (propertyId.isNotEmpty && propertyIds.contains(propertyId)) {
        return true;
      }
      if (propertyName.isNotEmpty && propertyNames.contains(propertyName)) {
        return true;
      }
      if (auth.isLandlord &&
          userName.isNotEmpty &&
          (item['landlordName'] ?? '').toString().trim().toLowerCase() ==
              userName) {
        return true;
      }
      if (auth.isTenant &&
          userName.isNotEmpty &&
          (item['tenantName'] ?? '').toString().trim().toLowerCase() ==
              userName) {
        return true;
      }
      return false;
    }).toList();
  }

  String _formatDate(DateTime dt) {
    final months = [
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
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
  var selectedSubscription = Rxn<Map<String, dynamic>>();

   final Map<String, Map<String, String>> mockData = {
    'Total Rent Collections': {
      'This Month': '₹4,50,000',
      'Last Month': '₹4,20,000',
      'Last 3 Months': '₹12,80,000',
      'Last 6 Months': '₹25,40,000',
      'Last Year': '₹52,00,000',
    },
    'Pending Payments': {
      'This Month': '₹85,000',
      'Last Month': '₹62,000',
      'Last 3 Months': '₹1,45,000',
      'Last 6 Months': '₹2,10,000',
      'Last Year': '₹3,50,000',
    },
    'Total Subscriptions': {
      'This Month': '₹1,20,000',
      'Last Month': '₹1,15,000',
      'Last 3 Months': '₹3,50,000',
      'Last 6 Months': '₹6,80,000',
      'Last Year': '₹14,20,000',
    },
    'Subscription Expired': {
      'This Month': '12',
      'Last Month': '8',
      'Last 3 Months': '45',
      'Last 6 Months': '92',
      'Last Year': '185',
    },
  };

  var expandedLists = <String, bool>{}.obs;

  void toggleList(String key) {
    expandedLists[key] = !(expandedLists[key] ?? false);
  }

  final recentRent = <Map<String, dynamic>>[].obs;

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final n = amount is int ? amount : int.tryParse(amount.toString()) ?? 0;
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      return remainder == 0
          ? '${thousands},000'
          : '${thousands},${remainder.toString().padLeft(3, '0')}';
    }
    return n.toString();
  }

  final List<String> _indianNames = [
    'Aarav',
    'Vivaan',
    'Aditya',
    'Vihaan',
    'Arjun',
    'Sai',
    'Ayaan',
    'Krishna',
    'Ishaan',
    'Shaurya',
  ];
  final List<String> _indianLastNames = [
    'Patel',
    'Sharma',
    'Singh',
    'Kumar',
    'Das',
    'Bose',
    'Gupta',
    'Mehta',
    'Trivedi',
    'Jain',
  ];

  final recentSubs = <Map<String, dynamic>>[].obs;

  final recentServices = <Map<String, dynamic>>[].obs;

  final propertyList = <Map<String, dynamic>>[].obs;

  final documentList = <Map<String, dynamic>>[].obs;

  late final supportList =
      List.generate(10, (i) {
        final categories = ['Technical', 'Billing', 'Account', 'General'];
        final statuses = ['Pending', 'In Progress', 'Solved'];
        final messages = [
          'System login issue',
          'Payment failure',
          'Update profile details',
          'Feature request',
          'Bug report',
        ];
        final status = statuses[i % statuses.length];
        return {
          'title': 'Ticket #${i + 1001}',
          'category': categories[i % categories.length],
          'status': status,
          'message': messages[i % messages.length],
          'date': 'May ${15 + i}, 2024',
          'resolvedDate': status == 'Solved' ? 'May ${17 + i}, 2024' : null,
          'type': 'support',
          'detail':
              'Category: ${categories[i % categories.length]} | Status: $status\nMessage: ${messages[i % messages.length]}',
        };
      }).obs;

  String getAmount(String label, String period) {
    final o = overview.value;
    if (o == null) return isOverviewLoading.value ? '...' : '--';

    switch (label) {
      case 'Total Rent Collections':
        return _formatINR(o.totalRentCollections);
      case 'Pending Payments':
        return _formatINR(o.pendingPayments);
      case 'Total Subscriptions':
        return _formatINR(o.totalSubscriptions);
      case 'Subscription Expired':
        return o.subscriptionExpiredCount.toString();
      default:
        return '0';
    }
  }

  void updatePeriod(String cardLabel, String period) {
    if (cardLabel == 'Total Rent Collections') rentPeriod.value = period;
    if (cardLabel == 'Pending Payments') pendingPeriod.value = period;
    if (cardLabel == 'Total Subscriptions') subAmountPeriod.value = period;
    if (cardLabel == 'Subscription Expired') subExpiredPeriod.value = period;
  }

  RxString getPeriodVar(String cardLabel) {
    if (cardLabel == 'Total Rent Collections') return rentPeriod;
    if (cardLabel == 'Pending Payments') return pendingPeriod;
    if (cardLabel == 'Total Subscriptions') return subAmountPeriod;
    return subExpiredPeriod;
  }

  Future<void> openRentCollectionDetails() async {
    showRentCollectionDetails.value = true;
    await fetchRentCollections();
  }

  void closeRentCollectionDetails() {
    showRentCollectionDetails.value = false;
    rentCollectionsError.value = '';
  }

  Future<void> openPendingPaymentDetails() async {
    showPendingPaymentDetails.value = true;
    await fetchPendingPayments();
  }

  void closePendingPaymentDetails() {
    showPendingPaymentDetails.value = false;
    pendingPaymentsError.value = '';
  }

  Future<void> fetchPendingPayments() async {
    try {
      isPendingPaymentsLoading.value = true;
      pendingPaymentsError.value = '';
      final fetched = await _dashboardRepo.getPendingPayments();
      pendingPayments.assignAll(_visibleRentCollections(fetched));
    } catch (e) {
      pendingPaymentsError.value = 'Failed to load pending payments.';
      pendingPayments.clear();
    } finally {
      isPendingPaymentsLoading.value = false;
    }
  }

  Future<void> fetchRentCollections() async {
    try {
      isRentCollectionsLoading.value = true;
      rentCollectionsError.value = '';
      final fetched = await _dashboardRepo.getRentCollections();
      rentCollections.assignAll(_visibleRentCollections(fetched));
    } catch (e) {
      rentCollectionsError.value = 'Failed to load rent collections.';
      rentCollections.clear();
    } finally {
      isRentCollectionsLoading.value = false;
    }
  }

  List<ServiceRequestModel> _visibleServiceRequests(
    List<ServiceRequestModel> items,
  ) {
    if (!Get.isRegistered<AuthController>()) return items;
    final auth = Get.find<AuthController>();
    if (!auth.isRestrictedRole) return items;

    final propertyIds = <String>{};
    final propertyNames = <String>{};
    if (Get.isRegistered<PropertyController>()) {
      for (final p in Get.find<PropertyController>().properties) {
        if (p.id.isNotEmpty) propertyIds.add(p.id);
        if (p.name.isNotEmpty) propertyNames.add(p.name.toLowerCase());
      }
    }

    final userName = auth.userName.value.trim().toLowerCase();
    return items.where((r) {
      if (r.propertyId.isNotEmpty && propertyIds.contains(r.propertyId)) {
        return true;
      }
      if (r.propertyName.isNotEmpty &&
          propertyNames.contains(r.propertyName.toLowerCase())) {
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

  List<RentCollectionModel> _visibleRentCollections(
    List<RentCollectionModel> items,
  ) {
    if (!Get.isRegistered<AuthController>()) return items;
    final auth = Get.find<AuthController>();
    if (!auth.isRestrictedRole) return items;

    final propertyIds = <String>{};
    final propertyNames = <String>{};
    if (Get.isRegistered<PropertyController>()) {
      for (final p in Get.find<PropertyController>().properties) {
        if (p.id.isNotEmpty) propertyIds.add(p.id);
        if (p.name.isNotEmpty) propertyNames.add(p.name.toLowerCase());
      }
    }

    final userId = auth.userId.value;
    final userName = auth.userName.value.trim().toLowerCase();
    return items.where((item) {
      if (propertyIds.contains(item.propertyId)) return true;
      if (propertyNames.contains(item.propertyName.toLowerCase())) return true;
      if (auth.isLandlord) {
        if (userId.isNotEmpty && item.landlordId == userId) return true;
        if (userName.isNotEmpty &&
            item.landlordName.toLowerCase() == userName) {
          return true;
        }
      }
      if (auth.isTenant) {
        if (userId.isNotEmpty && item.tenantId == userId) return true;
        if (userName.isNotEmpty &&
            item.tenantName.toLowerCase() == userName) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}
