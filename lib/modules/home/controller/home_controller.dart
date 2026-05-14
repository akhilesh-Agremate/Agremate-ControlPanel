import 'package:get/get.dart';
import 'package:agremate_admin/modules/services/repository/services_repository.dart';
import 'package:agremate_admin/modules/service_request/model/service_request_model.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/property/repository/property_repository.dart';

class HomeController extends GetxController {
  final _servicesRepo = ServicesRepository();
  final _propertyRepo = PropertyRepository();
  final isLoading = false.obs;

  final List<String> periods = [
    'This Month',
    'Last Month',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
  ];

  // Selected periods for each card
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

  // Search state
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

    // 1. Properties
    results.addAll(
      propertyList.where(
        (item) =>
            (item['title'] ?? '').toString().toLowerCase().contains(q) ||
            (item['landlordName'] ?? '').toString().toLowerCase().contains(q) ||
            (item['tenantName'] ?? '').toString().toLowerCase().contains(q),
      ),
    );

    // 2. Services
    results.addAll(
      recentServices.where(
        (item) =>
            (item['propertyName'] ?? '').toString().toLowerCase().contains(q) ||
            (item['tenantName'] ?? '').toString().toLowerCase().contains(q) ||
            (item['description'] ?? '').toString().toLowerCase().contains(q),
      ),
    );

    // 3. Rent
    results.addAll(
      recentRent.where(
        (item) =>
            (item['propertyName'] ?? '').toString().toLowerCase().contains(q) ||
            (item['tenantName'] ?? '').toString().toLowerCase().contains(q),
      ),
    );

    // 4. Subscriptions
    results.addAll(
      recentSubs.where(
        (item) =>
            (item['title'] ?? '').toString().toLowerCase().contains(q) ||
            (item['landlordName'] ?? '').toString().toLowerCase().contains(q),
      ),
    );

    // Remove potential duplicates
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
    fetchRecentServices();
    fetchRecentRent();
    fetchRecentProperties();
  }

  Future<void> fetchRecentServices() async {
    try {
      isLoading.value = true;
      final requests = await _servicesRepo.getAllMaintenanceRequests();
      print(
        'HomeController: Fetched ${requests.length} total service requests',
      );

      // 1. Remove duplicates by ID
      final uniqueRequests = <String, ServiceRequestModel>{};
      for (var r in requests) {
        if (r.id.isNotEmpty) {
          uniqueRequests[r.id] = r;
        }
      }
      var processedList = uniqueRequests.values.toList();

      // 2. Sort by date descending (newest first)
      processedList.sort((a, b) => b.requestDate.compareTo(a.requestDate));

      // 3. Take top 10 most recent
      final top10 = processedList.take(10).toList();

      // Try to get landlord info from PropertyController if available
      final pc =
          Get.isRegistered<PropertyController>()
              ? Get.find<PropertyController>()
              : null;

      // Map to the format expected by HomeView
      final mapped =
          top10.map((r) {
            String landlord = r.landlordName;
            if (pc != null && landlord == 'N/A') {
              final prop = pc.properties.firstWhereOrNull(
                (p) => p.id == r.propertyId,
              );
              if (prop != null) {
                landlord = prop.landlordName;
              }
            }

            return {
              'id': r.id,
              'title': r.propertyName,
              'propertyName': r.propertyName,
              'detail': 'Issue: ${r.description}',
              'landlordName': landlord,
              'tenantName': r.tenantName.isNotEmpty ? r.tenantName : 'N/A',
              'location': r.location,
              'raisedDate': _formatDate(r.requestDate),
              'resolvedDate':
                  r.completedDate != null
                      ? _formatDate(r.completedDate!)
                      : null,
              'status': r.status,
              'activeStatus':
                  r.status == 'completed' || r.status == 'solved'
                      ? 'Completed'
                      : 'Active',
              'chatMessages': r.chatMessages,
              'type': 'service',
              'rawModel': r, // Add the raw model for specialized rendering
            };
          }).toList();

      if (mapped.isEmpty) {
        _provideMockServices();
      } else {
        recentServices.assignAll(mapped);
      }
    } catch (e) {
      print('HomeController.fetchRecentServices error: $e');
      _provideMockServices();
    } finally {
      isLoading.value = false;
    }
  }

  void _provideMockServices() {
    recentServices.assignAll([
      {
        'title': 'Leaking Tap',
        'propertyName': 'Green Villa 101',
        'detail': 'Issue: Water leaking from the kitchen tap.',
        'landlordName': 'John Doe',
        'tenantName': 'Alex Smith',
        'location': 'Block A, Mumbai',
        'raisedDate': 'May 12, 2024',
        'status': 'Pending',
        'activeStatus': 'Active',
        'chatMessages': [],
      },
      {
        'title': 'AC Maintenance',
        'propertyName': 'Sunshine Apt 402',
        'detail': 'Issue: AC not cooling properly.',
        'landlordName': 'Mehta Singh',
        'tenantName': 'Rahul Kumar',
        'location': 'Block C, Pune',
        'raisedDate': 'May 10, 2024',
        'status': 'Solved',
        'activeStatus': 'Completed',
        'chatMessages': [],
      },
    ]);
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

  // Detail view state
  var selectedSubscription = Rxn<Map<String, dynamic>>();

  // Mock data mapping
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

  // Expanded states for lists
  var expandedLists = <String, bool>{}.obs;

  void toggleList(String key) {
    expandedLists[key] = !(expandedLists[key] ?? false);
  }

  // Rent collections — populated from PropertyController
  final recentRent = <Map<String, dynamic>>[].obs;

  Future<void> fetchRecentRent() async {
    try {
      print('HomeController: fetchRecentRent starting...');
      final props = await _propertyRepo.getAllProperties();
      print('HomeController: fetchRecentRent got ${props.length} properties');

      // 1. Filter: only properties that have a tenancyStartDate set
      final withTenancy =
          props.where((p) => p.tenancyStartDate != null).toList();

      // 2. Sort by tenancyStartDate descending (most recently added tenant first)
      withTenancy.sort(
        (a, b) => b.tenancyStartDate!.compareTo(a.tenancyStartDate!),
      );

      // 3. Take top 10
      final top10 = withTenancy.take(10).toList();

      print(
        'HomeController: fetchRecentRent — ${withTenancy.length} with tenancy, showing ${top10.length}',
      );

      final mapped =
          top10.map((p) {
            final rent = p.rentAmount;
            final advance = p.advanceAmount;
            final landlord = p.landlordName.isNotEmpty ? p.landlordName : 'N/A';
            final tenant = p.primaryTenantName ?? '';
            final location =
                p.address.address.isNotEmpty
                    ? p.address.address
                    : 'Location N/A';
            // Use tenancyStartDate as the "Joined" date
            final joinedDate = _formatDate(p.tenancyStartDate!);

            return <String, dynamic>{
              'id': p.id,
              'title': p.name,
              'propertyName': p.name,
              'detail':
                  'Landlord: $landlord | Tenant: ${tenant.isNotEmpty ? tenant : 'N/A'}\nRent: ₹$rent',
              'tenantName': tenant.isNotEmpty ? tenant : 'N/A',
              'landlordName': landlord,
              'rentAmount': '₹${_formatAmount(rent)}',
              'advanceAmount': '₹${_formatAmount(advance)}',
              'location': location,
              'propertyStatus': p.statusLabel,
              'type': 'rent',
              'joinedDate': joinedDate,
            };
          }).toList();

      print('HomeController: fetchRecentRent mapped ${mapped.length} items');
      recentRent.assignAll(mapped);
    } catch (e) {
      print('HomeController.fetchRecentRent error: $e');
    }
  }

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

  late final recentSubs =
      List.generate(10, (i) {
        String name =
            '${_indianNames[i % _indianNames.length]} ${_indianLastNames[(i + 2) % _indianLastNames.length]}';
        int propertyCount =
            (i % 5 == 0)
                ? 12
                : ((i % 3 == 0)
                    ? 7
                    : (i % 4) + 1); // Mix of 1-4, 7, 12 properties
        String plan;
        int maxProps;
        if (propertyCount >= 10) {
          plan = 'Custom Subscription';
          maxProps = propertyCount + 5;
        } else if (propertyCount >= 6) {
          plan = '₹799 Subscription';
          maxProps = 10;
        } else {
          plan = '₹299 Subscription';
          maxProps = 5;
        }

        List<Map<String, String>> properties = List.generate(propertyCount, (
          pIndex,
        ) {
          bool isBooked = (pIndex % 2 == 0); // Alternate booked/available
          return {
            'name': 'Property ${100 + i * 10 + pIndex}',
            'location': 'Block ${String.fromCharCode(65 + pIndex)}, Mumbai',
            'status': isBooked ? 'Booked' : 'Available',
            'tenantName':
                isBooked
                    ? _indianNames[(i + pIndex) % _indianNames.length]
                    : '',
            'tenantPhone': isBooked ? '+91 98765${12345 + i + pIndex}' : '',
            'tenantEmail':
                isBooked
                    ? '${_indianNames[(i + pIndex) % _indianNames.length].toLowerCase()}@example.com'
                    : '',
            'joinedDate': 'Jan 2024',
          };
        });

        return {
          'title': name,
          'detail': 'Plan: $plan',
          'propertyName': 'Multiple Properties ($propertyCount)',
          'landlordName': name,
          'subscriptionPlan': plan,
          'propertyCount': propertyCount,
          'maxProperties': maxProps,
          'usedProperties': propertyCount,
          'totalProperties': maxProps,
          'landlordDetails':
              'Email: ${name.toLowerCase().split(' ')[0]}@example.com\nPhone: +91 98765${43210 + i}',
          'properties': properties,
          'type': 'subscription',
          'status': i % 4 == 0 ? 'Expired' : 'Active',
        };
      }).obs;

  final recentServices = <Map<String, dynamic>>[].obs;

  // Property list — populated from API (properties with active tenancy)
  final propertyList = <Map<String, dynamic>>[].obs;

  Future<void> fetchRecentProperties() async {
    try {
      print('HomeController: fetchRecentProperties starting...');
      final props = await _propertyRepo.getAllProperties();
      print(
        'HomeController: fetchRecentProperties got ${props.length} properties',
      );

      // 1. Take top 10 (no filtering by tenancyStartDate)
      final top10 = props.take(10).toList();

      print(
        'HomeController: fetchRecentProperties showing ${top10.length} properties',
      );

      final mapped =
          top10.map((p) {
            final landlord = p.landlordName.isNotEmpty ? p.landlordName : 'N/A';
            final tenant = p.primaryTenantName ?? '';
            final location =
                p.address.address.isNotEmpty
                    ? p.address.address
                    : 'Location N/A';

            return <String, dynamic>{
              'id': p.id,
              'title': p.name,
              'landlordName': landlord,
              'tenantName': tenant.isNotEmpty ? tenant : 'N/A',
              'location': location,
              'status': p.statusLabel,
              'joinedDate': 'Jan 2024',
              'propertyImages': p.images.isNotEmpty ? p.images : <String>[],
              'type': 'property',
              'detail':
                  'Landlord: $landlord | Location: $location\nStatus: ${p.statusLabel}',
            };
          }).toList();

      if (mapped.isNotEmpty) {
        propertyList.assignAll(mapped);
      }
    } catch (e) {
      print('HomeController.fetchRecentProperties error: $e');
    }
  }

  late final documentList =
      List.generate(
        10,
        (i) => {
          'title': 'Lease_Agreement_${i + 1}.pdf',
          'propertyName': 'Green Villa ${i + 1}',
          'landlordName':
              _indianNames[i % _indianNames.length] +
              ' ' +
              _indianLastNames[(i + 1) % _indianLastNames.length],
          'fileTypes': ['pdf', 'jpg', 'doc', 'svg'].take((i % 4) + 1).toList(),
          'date': 'Oct ${10 + i}, 2023',
          'type': 'document',
          'detail': 'Landlord: John Doe | Tenant: Alex Smith',
        },
      ).obs;

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
    return mockData[label]?[period] ?? '0';
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
}
