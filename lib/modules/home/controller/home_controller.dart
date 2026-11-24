import 'package:get/get.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/modules/service_request/model/service_request_model.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/services/repository/services_repository.dart';
import 'package:intl/intl.dart';
import '../model/dashboard_overview_model.dart';
import '../model/registered_user_models.dart';
import '../model/rent_collection_model.dart';
import '../model/rental_agreement_item.dart';
import '../model/subscription_model.dart';
import '../model/support_ticket_model.dart';
import '../repository/dashboard_repository.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';
import 'package:agremate_admin/core/constants/app_strings.dart';
import '../repository/rental_agreement_repository.dart';
import '../repository/support_ticket_repository.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  final _dashboardRepo = DashboardRepository();
  final overview = Rxn<DashboardOverviewModel>();
  final useLandlordKpis = false.obs;
  final landlordRegisteredUsers = 0.obs;
  final landlordActiveSupport = 0.obs;
  final landlordContactOwner = 0.obs;
  final landlordRentalAgreements = 0.obs;
  final isOverviewLoading = true.obs;
  final showRentCollectionDetails = false.obs;
  final rentCollections = <RentCollectionModel>[].obs;
  final isRentCollectionsLoading = false.obs;
  final rentCollectionsError = ''.obs;
  final showPendingPaymentDetails = false.obs;
  final pendingPayments = <RentCollectionModel>[].obs;
  final isPendingPaymentsLoading = false.obs;
  final pendingPaymentsError = ''.obs;
  final showSubscriptionDetails = false.obs;
  final subscriptions = <SubscriptionModel>[].obs;
  final isSubscriptionsLoading = false.obs;
  final subscriptionsError = ''.obs;
  final showExpiredSubscriptionDetails = false.obs;
  final expiredSubscriptions = <SubscriptionModel>[].obs;
  final isExpiredSubscriptionsLoading = false.obs;
  final expiredSubscriptionsError = ''.obs;
  final showRegisteredUsersDetails = false.obs;
  final registeredUsersTab = 1.obs;
  final registeredLandlords = <RegisteredLandlordItem>[].obs;
  final registeredTenants = <RegisteredTenantItem>[].obs;
  final isRegisteredUsersLoading = false.obs;
  final registeredUsersError = ''.obs;
  final isLoadingMoreTenants = false.obs;
  final isLoadingMoreLandlords = false.obs;
  int _tenantsLoadToken = 0;
  static const tenantPageSize = 50;
  static const landlordPageSize = 50;
  static const _maxPages = 1000;
  static const _zeroGuid = '00000000-0000-0000-0000-000000000000';
  final _rentalRepo = RentalAgreementRepository();
  final rentalAgreements = <RentalAgreementItem>[].obs;
  final isRentalAgreementsLoading = false.obs;
  final rentalAgreementsError = ''.obs;
  final showRentalAgreements = false.obs;
  final rentalAgreementFilter = 'All'.obs;

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

  void openRentalAgreementDetails() {
    rentalAgreementFilter.value = 'All';
    showRentalAgreements.value = true;
    fetchRentalAgreements();
  }

  void closeRentalAgreementDetails() => showRentalAgreements.value = false;

  final _supportRepo = SupportTicketRepository();
  final showSupportDetails = false.obs;
  final supportTickets = <SupportTicketModel>[].obs;
  final supportSummary = Rxn<SupportSummary>();
  final isSupportLoading = false.obs;
  final supportError = ''.obs;
  final supportStatusFilter = RxnInt();
  final supportSearch = ''.obs;
  final supportPage = 1.obs;
  final supportTotal = 0.obs;
  static const supportPageSize = 20;

  final selectedTicket = Rxn<SupportTicketDetail>();
  final isTicketLoading = false.obs;
  final isTicketSending = false.obs;

  static const ticketStatuses = [
    'Open', 'Assigned', 'In Progress', 'Waiting On User',
    'Escalated', 'Resolved', 'Closed', 'Reopened',
  ];

  bool get isSupportStaff =>
      Get.isRegistered<AuthController>() &&
          !Get.find<AuthController>().isRestrictedRole;

  Future<void> openSupportDetails() async {
    supportStatusFilter.value = null;
    supportSearch.value = '';
    supportPage.value = 1;
    showSupportDetails.value = true;
    await fetchSupportTickets();
  }

  void closeSupportDetails() {
    showSupportDetails.value = false;
    supportError.value = '';
  }

  void setSupportStatus(int? status) {
    supportStatusFilter.value = status;
    supportPage.value = 1;
    fetchSupportTickets();
  }

  void setSupportSearch(String q) {
    supportSearch.value = q.trim();
    supportPage.value = 1;
    fetchSupportTickets();
  }

  void setSupportPage(int p) {
    supportPage.value = p;
    fetchSupportTickets();
  }

  Future<void> fetchSupportTickets() async {
    try {
      isSupportLoading.value = true;
      supportError.value = '';
      final result = isSupportStaff
          ? await _supportRepo.getAll(
        status: supportStatusFilter.value,
        search: supportSearch.value,
        page: supportPage.value,
        pageSize: supportPageSize,
      )
          : await _supportRepo.getMy(status: supportStatusFilter.value);
      supportTickets.assignAll(result.tickets);
      supportSummary.value = result.summary;
      supportTotal.value = result.totalFiltered;
    } catch (e, st) {
      AppLogger.e('HomeController', 'Fetch support tickets failed', e, st);
      supportError.value = 'Failed: $e';
      supportTickets.clear();
    } finally {
      isSupportLoading.value = false;
    }
  }

  Future<void> openTicket(String id) async {
    try {
      selectedTicket.value = null;
      isTicketLoading.value = true;
      selectedTicket.value = await _supportRepo.getDetail(id);
      _supportRepo.markSeen(id).catchError((_) {});
    } catch (e, st) {
      AppLogger.e('HomeController', 'Fetch ticket failed', e, st);
    } finally {
      isTicketLoading.value = false;
    }
  }

  Future<String?> sendTicketMessage(String id, String text,
      {bool internal = false}) async {
    try {
      isTicketSending.value = true;
      await _supportRepo.sendMessage(id, text, isInternal: internal);
      selectedTicket.value = await _supportRepo.getDetail(id);
      fetchSupportTickets();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      isTicketSending.value = false;
    }
  }

  Future<String?> changeTicketStatus(String id, int newStatus,
      {String? notes, String? resolutionNote}) async {
    try {
      await _supportRepo.updateStatus(id, newStatus,
          notes: notes, resolutionNote: resolutionNote);
      selectedTicket.value = await _supportRepo.getDetail(id);
      fetchSupportTickets();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchOverview();
    fetchRecentActivity();
  }

  Future<void> fetchOverview() async {
    try {
      AppLogger.i('HomeController', 'Fetch overview started');
      isOverviewLoading.value = true;
      overview.value = await _dashboardRepo.getOverview();
      if (Get.isRegistered<AuthController>() &&
          Get.find<AuthController>().isLandlord) {
        useLandlordKpis.value = true;
        landlordRegisteredUsers.value = 0;
        landlordActiveSupport.value = 0;
        landlordContactOwner.value = 0;
        landlordRentalAgreements.value = 0;
        await _loadLandlordKpis();
      } else {
        useLandlordKpis.value = false;
      }
      AppLogger.i('HomeController', 'Fetch overview success');
    } catch (e, st) {
      AppLogger.e('HomeController', 'Fetch overview failed', e, st);
      overview.value = null;
    } finally {
      isOverviewLoading.value = false;
    }
  }

  Future<void> fetchRentalAgreements() async {
    try {
      rentalAgreementsError.value = '';
      isRentalAgreementsLoading.value = true;
      rentalAgreements.assignAll(await _rentalRepo.getRentalAgreements());
    } catch (e, st) {
      AppLogger.e('HomeController', 'Fetch rental agreements failed', e, st);
      rentalAgreementsError.value = 'Failed to load rental agreements.';
    } finally {
      isRentalAgreementsLoading.value = false;
    }
  }

  Future<void> fetchRecentActivity() async {
    try {
      AppLogger.i('HomeController', 'Fetch recent activity started');
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
              'detail': item['planName'] ?? '',
              'subscriptionDate': _formatDateString(item['subscriptionDate']),
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
      AppLogger.i('HomeController', 'Fetch recent activity success');
    } catch (e) {
      AppLogger.e('HomeController', 'Fetch recent activity failed', e);
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

  final recentSubs = <Map<String, dynamic>>[].obs;
  final recentServices = <Map<String, dynamic>>[].obs;
  final propertyList = <Map<String, dynamic>>[].obs;
  final documentList = <Map<String, dynamic>>[].obs;
  final supportList = <Map<String, dynamic>>[].obs;
  String _fmt(num v) => NumberFormat.decimalPattern('en_IN').format(v);

  String getAmount(String label, String period) {
    if (useLandlordKpis.value) {
      switch (label) {
        case AppStrings.registeredUsers:
          return _fmt(landlordRegisteredUsers.value);
        case AppStrings.activeSupport:
          return _fmt(landlordActiveSupport.value);
        case AppStrings.contactOwner:
          return _fmt(landlordContactOwner.value);
        case AppStrings.rentalAgreement:
          return _fmt(landlordRentalAgreements.value);
        default:
          return '0';
      }
    }

    final o = overview.value;
    if (o == null) return '0';

    switch (label) {
      case AppStrings.registeredUsers:
        return _fmt(o.registeredUsersCount);
      case AppStrings.activeSupport:
        return _fmt(o.activeSupportCount);
      case AppStrings.contactOwner:
        return _fmt(o.contactOwnerCount);
      case AppStrings.rentalAgreement:
        return _fmt(o.rentalAgreementCount);
      default:
        return '0';
    }
  }

  String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  bool _samePhone(String a, String b) {
    final x = _digits(a);
    final y = _digits(b);
    if (x.isEmpty || y.isEmpty) return false;
    final left = x.length > 10 ? x.substring(x.length - 10) : x;
    final right = y.length > 10 ? y.substring(y.length - 10) : y;
    return left == right;
  }

  Future<void> _loadLandlordKpis() async {
    final auth = Get.find<AuthController>();
    final phone = auth.userPhone.value.trim().isNotEmpty
        ? auth.userPhone.value.trim()
        : auth.phoneNumber.value.trim();
    final userName = auth.userName.value.trim().toLowerCase();

    final propertyNames = <String>{};
    final propertyIds = <String>{};
    if (Get.isRegistered<PropertyController>()) {
      for (final p in Get.find<PropertyController>().properties) {
        if (p.id.isNotEmpty) propertyIds.add(p.id);
        if (p.name.trim().isNotEmpty) {
          propertyNames.add(p.name.trim().toLowerCase());
        }
      }
    }

    var userCount = 0;
    try {
      final landlords =
          await _dashboardRepo.getRegisteredLandlords(pageSize: 500);
      RegisteredLandlordItem? mine;
      for (final landlord in landlords) {
        if (_samePhone(landlord.phone, phone) ||
            (userName.isNotEmpty &&
                landlord.name.trim().toLowerCase() == userName)) {
          mine = landlord;
          break;
        }
      }
      if (mine != null) {
        userCount = 1;
        for (final property in mine.properties) {
          if (property.name.trim().isNotEmpty) {
            propertyNames.add(property.name.trim().toLowerCase());
          }
        }
        final seen = <String>{};
        for (final tenant in mine.tenants) {
          final key = tenant.phone.trim().isNotEmpty
              ? _digits(tenant.phone)
              : tenant.id;
          if (key.isNotEmpty && seen.add(key)) userCount++;
        }
      }

      final tenants = await _dashboardRepo.getRegisteredTenants(pageSize: 500);
      final seenTenants = <String>{};
      if (mine != null) {
        for (final tenant in mine.tenants) {
          final key = tenant.phone.trim().isNotEmpty
              ? _digits(tenant.phone)
              : tenant.id;
          if (key.isNotEmpty) seenTenants.add(key);
        }
      }
      for (final tenant in tenants) {
        final name = tenant.propertyName.trim().toLowerCase();
        if (name.isEmpty || !propertyNames.contains(name)) continue;
        final key = tenant.phone.trim().isNotEmpty
            ? _digits(tenant.phone)
            : tenant.id;
        if (key.isNotEmpty && seenTenants.add(key)) userCount++;
      }
      if (userCount == 0 && (mine != null || propertyNames.isNotEmpty)) {
        userCount = 1;
      }
    } catch (e) {
      AppLogger.e('HomeController', 'Landlord user count failed', e);
    }

    var supportCount = 0;
    var contactCount = 0;
    try {
      final data = await ServicesRepository().getDashboardServices();
      final requests = data['requests'];
      if (requests is List<ServiceRequestModel>) {
        for (final request in requests) {
          final propertyName = request.propertyName.trim().toLowerCase();
          final matchesProperty =
              (request.propertyId.isNotEmpty &&
                  propertyIds.contains(request.propertyId)) ||
              (propertyName.isNotEmpty && propertyNames.contains(propertyName));
          final matchesName = userName.isNotEmpty &&
              request.landlordName.trim().toLowerCase() == userName;
          if (!matchesProperty && !matchesName) continue;
          final status = request.status.trim().toLowerCase();
          final done = status == 'completed' ||
              status == 'closed' ||
              status == 'cancelled' ||
              status == 'resolved';
          if (!done) supportCount++;
          final type = request.serviceType.toLowerCase();
          if (type.contains('contact')) contactCount++;
        }
      }
    } catch (e) {
      AppLogger.e('HomeController', 'Landlord support count failed', e);
    }

    var agreementCount = 0;
    try {
      final agreements =
          await _rentalRepo.getRentalAgreements(page: 1, pageSize: 500);
      for (final agreement in agreements) {
        final propertyName = agreement.propertyName.trim().toLowerCase();
        final landlordName = agreement.landlordName.trim().toLowerCase();
        if (propertyName.isNotEmpty && propertyNames.contains(propertyName)) {
          agreementCount++;
        } else if (userName.isNotEmpty && landlordName == userName) {
          agreementCount++;
        }
      }
    } catch (e) {
      AppLogger.e('HomeController', 'Landlord agreement count failed', e);
    }

    landlordRegisteredUsers.value = userCount;
    landlordActiveSupport.value = supportCount;
    landlordContactOwner.value = contactCount;
    landlordRentalAgreements.value = agreementCount;
    useLandlordKpis.value = true;
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

  Future<void> openSubscriptionDetails() async {
    showSubscriptionDetails.value = true;
    await fetchSubscriptions();
  }

  void closeSubscriptionDetails() {
    showSubscriptionDetails.value = false;
    subscriptionsError.value = '';
  }

  Future<void> fetchSubscriptions() async {
    try {
      isSubscriptionsLoading.value = true;
      subscriptionsError.value = '';
      final fetched = await _dashboardRepo.getSubscriptions();
      subscriptions.assignAll(fetched);
    } catch (e) {
      subscriptionsError.value = 'Failed to load subscriptions.';
      subscriptions.clear();
    } finally {
      isSubscriptionsLoading.value = false;
    }
  }

  Future<void> openExpiredSubscriptionDetails() async {
    showExpiredSubscriptionDetails.value = true;
    await fetchExpiredSubscriptions();
  }

  void closeExpiredSubscriptionDetails() {
    showExpiredSubscriptionDetails.value = false;
    expiredSubscriptionsError.value = '';
  }

  Future<void> fetchExpiredSubscriptions() async {
    try {
      isExpiredSubscriptionsLoading.value = true;
      expiredSubscriptionsError.value = '';
      final fetched = await _dashboardRepo.getExpiredSubscriptions();
      expiredSubscriptions.assignAll(fetched);
    } catch (e) {
      expiredSubscriptionsError.value = 'Failed to load expired subscriptions.';
      expiredSubscriptions.clear();
    } finally {
      isExpiredSubscriptionsLoading.value = false;
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

  int get registeredLandlordCount {
    if (_isLoggedInLandlord) return registeredLandlords.length;
    final api = overview.value?.landlordCount ?? 0;
    return api > registeredLandlords.length ? api : registeredLandlords.length;
  }

  int get registeredTenantCount {
    if (_isLoggedInLandlord) return registeredTenants.length;
    final api = overview.value?.tenantCount ?? 0;
    return api > registeredTenants.length ? api : registeredTenants.length;
  }

  int get registeredUsersTotalCount {
    if (_isLoggedInLandlord) {
      return registeredLandlordCount + registeredTenantCount;
    }
    final api = overview.value?.registeredUsersCount ?? 0;
    final sum = registeredLandlordCount + registeredTenantCount;
    return api > sum ? api : sum;
  }

  bool get _isLoggedInLandlord =>
      Get.isRegistered<AuthController>() &&
      Get.find<AuthController>().isLandlord;

  Future<void> openRegisteredUsersDetails() async {
    showRegisteredUsersDetails.value = true;
    registeredUsersTab.value = 1;
    await fetchRegisteredUsers();
  }

  final isTabSwitching = false.obs;

  Future<void> switchRegisteredUsersTab(int tab) async {
    if (registeredUsersTab.value == tab) return;
    isTabSwitching.value = true;
    await Future.delayed(const Duration(milliseconds: 150));
    registeredUsersTab.value = tab;
    isTabSwitching.value = false;
  }

  void closeRegisteredUsersDetails() {
    _tenantsLoadToken++;
    isLoadingMoreLandlords.value = false;
    isLoadingMoreTenants.value = false;
    showRegisteredUsersDetails.value = false;
    registeredUsersError.value = '';
  }

  Future<void> fetchRegisteredUsers() async {
    final token = ++_tenantsLoadToken;
    final all = <RegisteredTenantItem>[];
    final seen = <String>{};
    final allLandlords = <RegisteredLandlordItem>[];
    final seenLandlords = <String>{};
    var hasMore = false;
    var hasMoreLandlords = false;
    try {
      isRegisteredUsersLoading.value = true;
      isLoadingMoreTenants.value = false;
      isLoadingMoreLandlords.value = false;
      registeredUsersError.value = '';
      registeredTenants.clear();

      hasMoreLandlords = await _loadLandlordPage(1, allLandlords, seenLandlords);
      if (_isLoggedInLandlord) {
        for (var page = 2; hasMoreLandlords && page <= _maxPages; page++) {
          hasMoreLandlords = await _loadLandlordPage(
            page,
            allLandlords,
            seenLandlords,
          );
        }
        hasMoreLandlords = false;
      }
      registeredLandlords.assignAll(allLandlords);

      try {
        hasMore = await _loadTenantPage(1, all, seen);
        if (_isLoggedInLandlord) {
          for (var page = 2; hasMore && page <= _maxPages; page++) {
            hasMore = await _loadTenantPage(page, all, seen);
          }
          hasMore = false;
        }
      } catch (_) {
        all.clear();
        hasMore = false;
      }

      registeredTenants.assignAll(all);
      if (registeredTenants.isEmpty) {
        registeredTenants.assignAll(_uniqueTenantsFromLandlords());
      }
      _keepLoggedInLandlord();
    } catch (e, st) {
      AppLogger.e('HomeController', 'Fetch registered users failed', e, st);
      registeredUsersError.value = 'Unable to load registered users.';
      registeredLandlords.clear();
      registeredTenants.clear();
      hasMore = false;
      hasMoreLandlords = false;
    } finally {
      isRegisteredUsersLoading.value = false;
    }

    if (hasMore && token == _tenantsLoadToken) {
      _loadRemainingTenants(token, all, seen);
    }
    if (hasMoreLandlords && token == _tenantsLoadToken) {
      _loadRemainingLandlords(token, allLandlords, seenLandlords);
    }
  }

  Future<bool> _loadLandlordPage(
      int page,
      List<RegisteredLandlordItem> all,
      Set<String> seen,
      ) async {
    final items = await _dashboardRepo.getRegisteredLandlords(
      page: page,
      pageSize: landlordPageSize,
    );
    var added = 0;
    for (final l in items) {
      final key = '${l.id}|${_digits(l.phone)}|${l.name.trim().toLowerCase()}';
      if (seen.add(key)) {
        all.add(l);
        added++;
      }
    }
    AppLogger.i(
      'HomeController',
      'landlords page=$page got=${items.length} added=$added total=${all.length}',
    );
    return items.isNotEmpty && added > 0;
  }

  Future<void> _loadRemainingLandlords(
      int token,
      List<RegisteredLandlordItem> all,
      Set<String> seen,
      ) async {
    isLoadingMoreLandlords.value = true;
    try {
      for (var page = 2; page <= _maxPages; page++) {
        if (token != _tenantsLoadToken) return;
        final more = await _loadLandlordPage(page, all, seen);
        if (token != _tenantsLoadToken) return;
        registeredLandlords.assignAll(all);
        if (!more) break;
      }
    } catch (e, st) {
      AppLogger.e('HomeController', 'Load more landlords failed', e, st);
    } finally {
      if (token == _tenantsLoadToken) isLoadingMoreLandlords.value = false;
    }
  }

  Future<bool> _loadTenantPage(
      int page,
      List<RegisteredTenantItem> all,
      Set<String> seen,
      ) async {
    final items = await _dashboardRepo.getRegisteredTenants(
      page: page,
      pageSize: tenantPageSize,
    );
    var added = 0;
    for (final t in items) {
      if (seen.add(_tenantListKey(t))) {
        all.add(t);
        added++;
      }
    }
    AppLogger.i(
      'HomeController',
      'tenants page=$page got=${items.length} added=$added total=${all.length}',
    );
    return items.isNotEmpty && added > 0;
  }

  Future<void> _loadRemainingTenants(
      int token,
      List<RegisteredTenantItem> all,
      Set<String> seen,
      ) async {
    isLoadingMoreTenants.value = true;
    try {
      for (var page = 2; page <= _maxPages; page++) {
        if (token != _tenantsLoadToken) return;
        final more = await _loadTenantPage(page, all, seen);
        if (token != _tenantsLoadToken) return;
        registeredTenants.assignAll(all);
        if (!more) break;
      }
    } catch (e, st) {
      AppLogger.e('HomeController', 'Load more tenants failed', e, st);
    } finally {
      if (token == _tenantsLoadToken) isLoadingMoreTenants.value = false;
    }
  }

  void _keepLoggedInLandlord() {
    if (!_isLoggedInLandlord) return;
    final auth = Get.find<AuthController>();
    final phone = auth.userPhone.value.trim().isNotEmpty
        ? auth.userPhone.value.trim()
        : auth.phoneNumber.value.trim();
    final name = auth.userName.value.trim().toLowerCase();

    final mine = registeredLandlords.where((landlord) {
      if (phone.isNotEmpty && _samePhone(landlord.phone, phone)) return true;
      if (name.isNotEmpty && landlord.name.trim().toLowerCase() == name) {
        return true;
      }
      return false;
    }).toList();
    registeredLandlords.assignAll(mine);

    final propertyNames = <String>{};
    for (final landlord in mine) {
      for (final property in landlord.properties) {
        if (property.name.trim().isNotEmpty) {
          propertyNames.add(property.name.trim().toLowerCase());
        }
      }
    }
    if (Get.isRegistered<PropertyController>()) {
      for (final property in Get.find<PropertyController>().properties) {
        if (property.name.trim().isNotEmpty) {
          propertyNames.add(property.name.trim().toLowerCase());
        }
      }
    }

    registeredTenants.assignAll(
      registeredTenants.where((tenant) {
        final propertyName = tenant.propertyName.trim().toLowerCase();
        return propertyName.isNotEmpty && propertyNames.contains(propertyName);
      }).toList(),
    );
    if (registeredTenants.isEmpty && mine.isNotEmpty) {
      registeredTenants.assignAll(_uniqueTenantsFromLandlords());
    }
  }

  List<RegisteredTenantItem> _uniqueTenantsFromLandlords() {
    final nested = <RegisteredTenantItem>[];
    for (final landlord in registeredLandlords) {
      nested.addAll(landlord.tenants);
    }
    return _uniqueTenants(nested);
  }

  String _tenantKey(RegisteredTenantItem t) {
    if (t.userId.isNotEmpty) return 'u:${t.userId}';
    if (t.id.isNotEmpty && t.id != _zeroGuid) return 't:${t.id}';
    final phone = _digits(t.phone);
    if (phone.isNotEmpty) return 'p:$phone';
    return 'n:${t.name}';
  }
  String _tenantListKey(RegisteredTenantItem t) =>
      '${t.id}|${t.userId}|${_digits(t.phone)}|'
          '${t.propertyName.trim().toLowerCase()}|${t.name.trim().toLowerCase()}';

  List<RegisteredTenantItem> _uniqueTenants(List<RegisteredTenantItem> items) {
    final seen = <String>{};
    final unique = <RegisteredTenantItem>[];
    for (final tenant in items) {
      if (seen.add(_tenantKey(tenant))) unique.add(tenant);
    }
    return unique;
  }
}
