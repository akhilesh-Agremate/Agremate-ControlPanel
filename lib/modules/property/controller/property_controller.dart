import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/property/model/landlord_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_details_model.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/model/property_stats_model.dart';
import 'package:agremate_admin/modules/property/repository/property_repository.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../network_utils/app_end_points.dart';
import '../../../network_utils/dio_client.dart';
import '../model/amenity_model.dart';
import '../view/components/property_type_dialog.dart';

enum PropertyCategoryFilter { all, pg, individual }

class PropertyController extends GetxController {
  final PropertyRepository _repository;
  PropertyController(this._repository);

  final landlords = <LandlordModel>[].obs;
  final tenants = <TenantModel>[].obs;
  final properties = <PropertyModel>[].obs;
  final filteredProperties = <PropertyModel>[].obs;
  final selectedCategoryFilter = PropertyCategoryFilter.all.obs;
  final currentPage = 1.obs;
  final searchQuery = ''.obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final selectedProperty = Rxn<PropertyModel>();
  final isDetailLoading = false.obs;
  final selectedTenantDetails = Rxn<TenantDetailsModel>();
  final returnTabIndex = Rxn<int>();
  final stats = Rxn<PropertyStatsModel>();
  final kpiStats = PropertyStatsModel.empty().obs;
  final isAddOpen = false.obs;
  final addType = PropertyAddType.individual.obs;
  final amenities = <AmenityModel>[].obs;
  final isAmenitiesLoading = false.obs;
  final featureOptions = <AmenityModel>[].obs;
  final isFeaturesLoading = false.obs;

  final scrollController = ScrollController();
  static const int perPage = 32;
  final bhkTypes = <Map<String, dynamic>>[].obs;
  final isBhkLoading = false.obs;

  Future<void> fetchBhkTypes() async {
    if (bhkTypes.isNotEmpty || isBhkLoading.value) return;
    try {
      isBhkLoading.value = true;
      final res = await DioClient.instance.get(AppEndpoints.bhkTypes);
      final data = res.data;
      final raw = data is Map && data['result'] is List ? data['result'] as List : const [];
      bhkTypes.assignAll([
        for (final e in raw)
          if (e is Map && e['code'] != null)
            {
              'id': e['id'],
              'code': e['code'].toString(),
              'name': (e['name'] ?? e['code']).toString(),
              'bedrooms': e['bedrooms'],
            }
      ]);
    } catch (e) {
      AppLogger.e('PropertyController', 'Error fetching BHK types', e);
    } finally {
      isBhkLoading.value = false;
    }
  }

  /// "2bhk", "2 BHK", "1-rk" -> "2BHK", "1RK"
  String normalizeBhk(String? t) =>
      (t ?? '').replaceAll(RegExp(r'[\s\-_]+'), '').toUpperCase();

  String? matchBhkCode(String? stored) {
    final n = normalizeBhk(stored);
    if (n.isEmpty) return null;
    for (final t in bhkTypes) {
      if (t['code'] == n) return n;
    }
    return null;
  }

  /// Name for display; falls back to the stored text if there is no match.
  String bhkDisplayName(String? stored) {
    final n = normalizeBhk(stored);
    for (final t in bhkTypes) {
      if (t['code'] == n) return t['name'].toString();
    }
    return (stored ?? '').trim();
  }

  final propertyTypes = <Map<String, dynamic>>[].obs;

  Future<void> fetchPropertyTypes() async {
    if (propertyTypes.isNotEmpty) return;
    try {
      final res = await DioClient.instance.get(AppEndpoints.propertyTypes);
      final data = res.data;
      final raw = data is Map && data['result'] is List ? data['result'] as List : const [];
      propertyTypes.assignAll([
        for (final e in raw)
          if (e is Map && e['name'] != null)
            {'id': e['id'].toString(), 'name': e['name'].toString()}
      ]);
    } catch (e) {
      AppLogger.e('PropertyController', 'Error fetching property types', e);
    }
  }

  /// Accepts an id ("1") or a name ("Apartment"). Returns '' if it can't be resolved.
  String propertyTypeName(dynamic stored) {
    final s = stored?.toString().trim() ?? '';
    if (s.isEmpty) return '';
    for (final t in propertyTypes) {
      if (t['id'] == s || t['name'].toString().toLowerCase() == s.toLowerCase()) {
        return t['name'].toString();
      }
    }
    return int.tryParse(s) == null ? s : '';
  }

  Timer? _autoRefreshTimer;
  bool _usersLoading = false;
  bool _usersLoaded = false;
  final isLandlordsLoading = false.obs;
  final isTenantsLoading = false.obs;

  Future<void> loadUsersIfNeeded() async {
    if (_usersLoaded || _usersLoading) return;
    _usersLoaded = true;
    await _loadUsersInBackground();
  }

  int get totalPropertiesCount => properties.length;
  int get pgPropertiesCount => properties.where((p) => p.isPg).length;
  int get individualPropertiesCount =>
      properties.where((p) => p.isIndividual).length;

  int get totalPages {
    if (filteredProperties.isEmpty) return 1;
    return (filteredProperties.length / perPage).ceil();
  }

  List<PropertyModel> get currentPageProperties {
    final total = filteredProperties.length;
    if (total == 0) return [];

    final start = (currentPage.value - 1) * perPage;
    if (start >= total) return [];

    final end = min(start + perPage, total);
    return filteredProperties.sublist(start, end);
  }

  void setCategoryFilter(PropertyCategoryFilter filter) {
    if (selectedCategoryFilter.value == filter) return;
    selectedCategoryFilter.value = filter;
    _applyFilters();
  }

  void _applyFilters() {
    var result = properties.toList();

    if (selectedCategoryFilter.value == PropertyCategoryFilter.pg) {
      result = result.where((p) => p.isPg).toList();
    } else if (selectedCategoryFilter.value ==
        PropertyCategoryFilter.individual) {
      result = result.where((p) => p.isIndividual).toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.landlordName.toLowerCase().contains(query) ||
            (p.primaryTenantName?.toLowerCase().contains(query) ?? false) ||
            p.address.address.toLowerCase().contains(query);
      }).toList();
    }

    filteredProperties.assignAll(result);
    currentPage.value = 1;
  }

  @override
  void onInit() {
    super.onInit();
    fetchProperties();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshProperties();
    });
    ever(currentPage, (_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    final nav = Get.find<NavigationController>();
    ever(nav.searchQuery, (String query) {
      if (nav.currentIndex.value == 1) search(query);
    });
  }

  Future<void> refreshProperties() async {
    try {
      isRefreshing.value = true;
      final fetched = await _repository.getAllProperties();
      final prevCount = properties.length;
      properties.assignAll(fetched);
      _applyFilters();
      _buildDependentLists();
      await fetchStats();
      _refreshKpiStats();
      if (_usersLoaded) unawaited(_refreshUsersQuick());
      if (currentPage.value > totalPages) currentPage.value = totalPages;
      if (fetched.length > prevCount) {
        AppToast.success(
          '${fetched.length - prevCount} new propert${fetched.length - prevCount == 1 ? "y" : "ies"} added',
        );
      }
    } catch (_) {
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> fetchAmenities() async {
    try {
      isAmenitiesLoading.value = true;
      amenities.assignAll(await _repository.getAmenities());
    } catch (e) {
      AppLogger.e('PropertyController', 'Error fetching amenities', e);
    } finally {
      isAmenitiesLoading.value = false;
    }
  }

  Future<void> fetchFeatures() async {
    try {
      isFeaturesLoading.value = true;
      featureOptions.assignAll(await _repository.getFeatures());
    } catch (e) {
      AppLogger.e('PropertyController', 'Error fetching features', e);
    } finally {
      isFeaturesLoading.value = false;
    }
  }

  Future<void> updateProperty(PropertyModel property, Map<String, dynamic> data) async {
    final auth = Get.find<AuthController>();
    if (!(auth.isSuperAdmin || auth.isLandlord)) {
      throw Exception('You do not have permission to edit properties');
    }
    final fresh = await _repository.getPropertyById(property.id);
    await _repository.updateProperty(fresh, data);
    selectedProperty.value = await _repository.getPropertyById(property.id);
    unawaited(refreshProperties());
    AppToast.success('Property updated');
  }

  Future<void> setCoverImage(PropertyModel property, String documentId) async {
    if (documentId.isEmpty) {
      AppToast.error('Selected image not found. Please refresh.');
      return;
    }
    try {
      await _repository.setCoverImage(property.id, documentId);
      final detail = await _repository.getPropertyById(property.id);
      if (property.isDeleted) detail.isDeleted = true;
      selectedProperty.value = detail;
      unawaited(refreshProperties());
      AppToast.success('Cover image updated');
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteProperty(String id) async {
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      if (auth.isTenant) {
        AppToast.error(
          'You do not have permission to delete properties',
        );
        return;
      }
    }
    try {
      final message = await _repository.deleteProperty(id);
      properties.removeWhere((p) => p.id == id);
      _applyFilters();
      await refreshProperties();
      closePropertyDetails();
      AppToast.success(message);
    } catch (e) {
      AppToast.error('Failed to delete property: $e');
      rethrow;
    }
  }

  void openAddProperty({PropertyAddType type = PropertyAddType.individual}) {
    addType.value = type;
    isAddOpen.value = true;
    if (amenities.isEmpty) fetchAmenities();
    if (featureOptions.isEmpty) fetchFeatures();
    fetchBhkTypes();
  }

  Future<void> fetchProperties() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      final fetched = await _repository.getAllProperties();
      properties.assignAll(fetched);
      _applyFilters();
      _buildDependentLists();
      await fetchStats();
      _refreshKpiStats();
    } catch (e) {
      AppToast.error('Failed to fetch properties: $e');
    } finally {
      isLoading.value = false;
      await _restoreDetailIfNeeded();
    }
  }

  Future<void> _restoreDetailIfNeeded() async {
    if (selectedProperty.value != null) return;
    if (!Get.isRegistered<NavigationController>()) return;
    final id = Get.find<NavigationController>().propertyDetailId;
    if (id == null || id.isEmpty) return;
    PropertyModel? match;
    for (final p in properties) {
      if (p.id == id) {
        match = p;
        break;
      }
    }
    if (match != null) {
      await openPropertyDetails(match);
      return;
    }
    try {
      final detail = await _repository.getPropertyById(id);
      selectedProperty.value = detail;
    } catch (_) {}
  }

  Future<void> createProperty(Map<String, dynamic> data) async {
    AppLogger.i('PropertyController', 'Create property started');
    try {
      await _repository.createProperty(data);
      await refreshProperties();
      AppLogger.i('PropertyController', 'Create property success');
      AppToast.success('Property created successfully');
    } catch (e) {
      AppLogger.e('PropertyController', 'Create property failed', e);
      rethrow;
    }
  }

  Future<void> createPgProperty(Map<String, dynamic> data) async {
    AppLogger.i('PropertyController', 'Create PG property started');
    try {
      await _repository.createPgProperty(data);
      await refreshProperties();
      AppLogger.i('PropertyController', 'Create PG property success');
      AppToast.success('PG Property created successfully');
    } catch (e) {
      AppLogger.e('PropertyController', 'Create PG property failed', e);
      rethrow;
    }
  }

  Future<void> updatePgProperty(String propertyId, Map<String, dynamic> data) async {
    AppLogger.i('PropertyController', 'Update PG property started id=$propertyId');
    try {
      await _repository.updatePgProperty(propertyId, data);
      await refreshProperties();
      AppLogger.i('PropertyController', 'Update PG property success');
      AppToast.success('PG Property updated successfully');
    } catch (e) {
      AppLogger.e('PropertyController', 'Update PG property failed', e);
      rethrow;
    }
  }

  void _buildDependentLists() {
  }

  Future<void> fetchStats() async {
    try {
      stats.value = await _repository.getPropertyStats();
    } catch (e) {
      AppLogger.e('PropertyController', 'Error fetching property stats', e);
    }
  }

  bool get _isLandlordOrTenant {
    if (!Get.isRegistered<AuthController>()) return false;
    return Get.find<AuthController>().isRestrictedRole;
  }

  void _refreshKpiStats() {
    if (_isLandlordOrTenant) {
      final fromProps = _statsFromAssociatedProperties();
      kpiStats.value = PropertyStatsModel(
        totalProperties: fromProps.totalProperties,
        rentedCount: fromProps.rentedCount,
        availableCount: fromProps.availableCount,
        maintenanceCount: fromProps.maintenanceCount,
        totalLandlords: landlords.length,
        activeLandlordCount: landlords.where((l) => l.isActive).length,
        totalTenants: tenants.length,
        tenantsAcrossProperties: fromProps.tenantsAcrossProperties,
        totalRevenue: fromProps.totalRevenue,
        propertiesSparkline: fromProps.propertiesSparkline,
        landlordsSparkline: fromProps.landlordsSparkline,
        tenantsSparkline: fromProps.tenantsSparkline,
        revenueSparkline: fromProps.revenueSparkline,
        chartLabels: fromProps.chartLabels,
      );
      return;
    }
    kpiStats.value = stats.value ?? PropertyStatsModel.empty();
  }

  PropertyStatsModel get displayStats => kpiStats.value;

  static const _createdKeys = [
    'createdAt', 'createdDate', 'createdOn', 'createdTime',
    'creationDate', 'addedOn', 'dateCreated',
  ];

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  DateTime? _createdDate(PropertyModel p) {
    for (final k in _createdKeys) {
      final d = _parseDate(p.rawJson[k]);
      if (d != null) return d;
    }
    return null;
  }

  DateTime? _tenancyStart(PropertyModel p) =>
      p.tenancyStartDate ?? _parseDate(p.rawJson['tenancyStartDate']);

  List<DateTime> _last12Months() {
    final now = DateTime.now();
    return List.generate(12, (i) => DateTime(now.year, now.month - 11 + i));
  }

  List<double> _bucketByMonth(
      Iterable<MapEntry<DateTime?, double>> items,
      List<DateTime> months,
      ) {
    final out = List<double>.filled(months.length, 0);
    for (final e in items) {
      final d = e.key?.toLocal();
      if (d == null) continue;
      for (var i = 0; i < months.length; i++) {
        if (d.year == months[i].year && d.month == months[i].month) {
          out[i] += e.value;
          break;
        }
      }
    }
    return out;
  }

  PropertyStatsModel _statsFromAssociatedProperties() {
    final months = _last12Months();
    final uniqueTenants = <String>{};
    final landlordFirstSeen = <String, DateTime?>{};
    final propertyItems = <MapEntry<DateTime?, double>>[];
    final tenantItems = <MapEntry<DateTime?, double>>[];
    final revenueItems = <MapEntry<DateTime?, double>>[];
    var rented = 0;
    var available = 0;
    var maintenance = 0;
    var tenantsAcross = 0;
    num revenue = 0;

    for (final p in properties) {
      if (p.isRented) rented++;
      if (p.status == PropertyStatus.available) available++;
      if (p.status == PropertyStatus.maintenance) maintenance++;

      final created = _createdDate(p);
      propertyItems.add(MapEntry(created, 1));

      final landlordKey = (p.landlordId.isNotEmpty
          ? p.landlordId
          : p.landlordName.trim())
          .toLowerCase();
      if (landlordKey.isNotEmpty) {
        final prev = landlordFirstSeen[landlordKey];
        if (!landlordFirstSeen.containsKey(landlordKey) ||
            (created != null && (prev == null || created.isBefore(prev)))) {
          landlordFirstSeen[landlordKey] = created;
        }
      }

      final tenantKey = (p.tenantIds.isNotEmpty
          ? p.tenantIds.first
          : (p.primaryTenantName ?? '').trim())
          .toLowerCase();
      if (tenantKey.isNotEmpty) {
        tenantsAcross++;
        if (uniqueTenants.add(tenantKey)) {
          tenantItems.add(MapEntry(_tenancyStart(p), 1));
        }
      }

      if (p.isRented) {
        revenue += p.rentAmount;
        revenueItems.add(MapEntry(_tenancyStart(p), p.rentAmount.toDouble()));
      }
    }

    final dated = propertyItems.where((e) => e.key != null).length;
    AppLogger.i('PropertyController',
        'KPI sparkline: $dated/${properties.length} properties have a created date');

    return PropertyStatsModel(
      totalProperties: properties.length,
      rentedCount: rented,
      availableCount: available,
      maintenanceCount: maintenance,
      totalLandlords: landlordFirstSeen.length,
      activeLandlordCount: landlordFirstSeen.length,
      totalTenants: uniqueTenants.length,
      tenantsAcrossProperties: tenantsAcross,
      totalRevenue: revenue,
      propertiesSparkline: _bucketByMonth(propertyItems, months),
      landlordsSparkline: _bucketByMonth(
        landlordFirstSeen.values.map((d) => MapEntry<DateTime?, double>(d, 1)),
        months,
      ),
      tenantsSparkline: _bucketByMonth(tenantItems, months),
      revenueSparkline: _bucketByMonth(revenueItems, months),
      chartLabels: months.map((m) => DateFormat('MMM').format(m)).toList(),
    );
  }

  String _landlordKey(LandlordModel l) =>
      '${l.id}|${l.phone.replaceAll(RegExp(r'\D'), '')}|${l.name.trim().toLowerCase()}';
  String _tenantKey(TenantModel t) =>
      '${t.id}|${t.phone.replaceAll(RegExp(r'\D'), '')}|${t.propertyName}|${t.name}';

  List<LandlordModel> _applyLandlordRules(List<LandlordModel> list) {
    var out = _repository.filterLandlords(list);
    if (Get.isRegistered<AuthController>() && Get.find<AuthController>().isTenant) {
      final names = properties.map((p) => p.landlordName.toLowerCase()).toSet();
      final ids = properties.map((p) => p.landlordId).toSet();
      out = out
          .where((l) => ids.contains(l.id) || names.contains(l.name.toLowerCase()))
          .toList();
    }
    return out;
  }

  List<TenantModel> _applyTenantRules(List<TenantModel> list) {
    var out = _repository.filterTenants(list);
    if (Get.isRegistered<AuthController>() && Get.find<AuthController>().isLandlord) {
      final names = properties.map((p) => p.name.toLowerCase()).toSet();
      out = out.where((t) => names.contains(t.propertyName.toLowerCase())).toList();
    }
    return out;
  }

  Future<void> _loadUsersInBackground() async {
    if (_usersLoading) return;
    _usersLoading = true;
    try {
      await Future.wait([_loadLandlordsProgressive(), _loadTenantsProgressive()]);
      _refreshKpiStats();
    } finally {
      _usersLoading = false;
    }
  }

  Future<void> _loadLandlordsProgressive() async {
    isLandlordsLoading.value = true;
    final all = <LandlordModel>[];
    final seen = <String>{};
    try {
      for (var page = 1; page <= 1000; page++) {
        final items = await _repository.getLandlordsPage(page: page);
        var added = 0;
        for (final l in items) {
          if (seen.add(_landlordKey(l))) {
            all.add(l);
            added++;
          }
        }
        if (page == 1 || page % 3 == 0) {
          landlords.assignAll(_applyLandlordRules(all));
        }
        await Future.delayed(const Duration(milliseconds: 60));
        AppLogger.i('PropertyController',
            'landlords page=$page got=${items.length} added=$added total=${all.length}');
        if (items.isEmpty || added == 0) break;
      }
    } catch (e) {
      AppLogger.e('PropertyController', 'Error fetching landlords', e);
    } finally {
      landlords.assignAll(_applyLandlordRules(all));
      isLandlordsLoading.value = false;
    }
  }

  Future<void> _loadTenantsProgressive() async {
    isTenantsLoading.value = true;
    final all = <TenantModel>[];
    final seen = <String>{};
    try {
      for (var page = 1; page <= 1000; page++) {
        final items = await _repository.getTenantsPage(page: page);
        var added = 0;
        for (final t in items) {
          if (seen.add(_tenantKey(t))) {
            all.add(t);
            added++;
          }
        }
        if (page == 1 || page % 3 == 0) {
          tenants.assignAll(_applyTenantRules(all));
        }
        await Future.delayed(const Duration(milliseconds: 60));
        AppLogger.i('PropertyController',
            'tenants page=$page got=${items.length} added=$added total=${all.length}');
        if (items.isEmpty || added == 0) break;
      }
    } catch (e) {
      AppLogger.e('PropertyController', 'Error fetching tenants', e);
    } finally {
      tenants.assignAll(_applyTenantRules(all));
      isTenantsLoading.value = false;
    }
  }

  Future<void> _refreshUsersQuick() async {
    if (_usersLoading) return;
    if (landlords.isEmpty && tenants.isEmpty) {
      await _loadUsersInBackground();
      return;
    }
    try {
      final knownL = landlords.map(_landlordKey).toSet();
      final freshL = _applyLandlordRules(await _repository.getLandlordsPage(page: 1))
          .where((l) => !knownL.contains(_landlordKey(l)))
          .toList();
      if (freshL.isNotEmpty) landlords.insertAll(0, freshL);

      final knownT = tenants.map(_tenantKey).toSet();
      final freshT = _applyTenantRules(await _repository.getTenantsPage(page: 1))
          .where((t) => !knownT.contains(_tenantKey(t)))
          .toList();
      if (freshT.isNotEmpty) tenants.insertAll(0, freshT);
    } catch (_) {}
  }

  Future<void> fetchTenants() async {
    isTenantsLoading.value = true;
    try {
      var fetchedTenants = await _repository.getAllTenants();
      if (Get.isRegistered<AuthController>() &&
          Get.find<AuthController>().isLandlord) {
        final names = properties.map((p) => p.name.toLowerCase()).toSet();
        fetchedTenants = fetchedTenants
            .where((t) => names.contains(t.propertyName.toLowerCase()))
            .toList();
      }
      tenants.assignAll(fetchedTenants);
    } catch (e) {
      AppLogger.e('PropertyController', 'Error fetching tenants', e);
    } finally {
      isTenantsLoading.value = false;
    }
  }

  Future<void> fetchLandlords() async {
    isLandlordsLoading.value = true;
    try {
      var fetchedLandlords = await _repository.getAllLandlords();
      if (Get.isRegistered<AuthController>() &&
          Get.find<AuthController>().isTenant) {
        final names = properties.map((p) => p.landlordName.toLowerCase()).toSet();
        final ids = properties.map((p) => p.landlordId).toSet();
        fetchedLandlords = fetchedLandlords
            .where((l) => ids.contains(l.id) || names.contains(l.name.toLowerCase()))
            .toList();
      }
      landlords.assignAll(fetchedLandlords);
    } catch (e) {
      AppLogger.e('PropertyController', 'Error fetching landlords', e);
    } finally {
      isLandlordsLoading.value = false;
    }
  }

  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void goToPage(int page) {
    if (page >= 1) currentPage.value = page;
  }

  Future<void> openPropertyDetails(PropertyModel property) async {
    selectedProperty.value = property;
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().setPropertyDetailId(property.id);
    }
    try {
      isDetailLoading.value = true;
      final detail = await _repository.getPropertyById(property.id);
      if (selectedProperty.value?.id == property.id) {
        if (property.isDeleted) detail.isDeleted = true;
        selectedProperty.value = detail;
      }
    } catch (e) {
      AppToast.error('Failed to load property details');
    } finally {
      isDetailLoading.value = false;
    }
  }

  void closePropertyDetails() {
    selectedProperty.value = null;
    isDetailLoading.value = false;
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().setPropertyDetailId(null);
    }
  }

  void deleteLandlord(String id) {
    landlords.removeWhere((l) => l.id == id);
    properties.removeWhere((p) => p.landlordId == id);
    _applyFilters();
  }

  void addLandlord(String name, String phone, String email) {
    final newLandlord = LandlordModel(
      id: 'L-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      address: '',
    );
    landlords.insert(0, newLandlord);
    AppToast.success('Landlord $name added successfully');
  }

  Future<void> viewTenantDetails(String userId) async {
    try {
      isLoading.value = true;
      final details = await _repository.getTenantDetails(userId);
      selectedTenantDetails.value = details;
      final nav = Get.find<NavigationController>();
      nav.currentIndex.value =
          8;
    } catch (e) {
      AppToast.error('Failed to fetch tenant details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
