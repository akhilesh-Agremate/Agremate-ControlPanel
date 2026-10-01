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

class PropertyController extends GetxController {
  final PropertyRepository _repository;
  PropertyController(this._repository);

  final landlords = <LandlordModel>[].obs;
  final tenants = <TenantModel>[].obs;
  final properties = <PropertyModel>[].obs;
  final filteredProperties = <PropertyModel>[].obs;
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

  final scrollController = ScrollController();
  static const int perPage = 30;

  Timer? _autoRefreshTimer;

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
      if (searchQuery.value.isEmpty) {
        filteredProperties.assignAll(fetched);
      } else {
        filteredProperties.assignAll(
          fetched.where(
            (p) =>
                p.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                p.landlordName.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (p.primaryTenantName?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
                p.address.address.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
          ),
        );
      }
      _buildDependentLists();
      await fetchStats();
      await fetchTenants();
      await fetchLandlords();
      _refreshKpiStats();
      if (currentPage.value > totalPages) currentPage.value = totalPages;
      if (fetched.length > prevCount) {
        Get.snackbar(
          'Updated',
          '${fetched.length - prevCount} new propert${fetched.length - prevCount == 1 ? "y" : "ies"} added',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (_) {
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> fetchProperties() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      final fetched = await _repository.getAllProperties();
      properties.assignAll(fetched);
      filteredProperties.assignAll(fetched);
      _buildDependentLists();
      await fetchStats();
      await fetchTenants();
      await fetchLandlords();
      _refreshKpiStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch properties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _buildDependentLists() {
  }

  Future<void> fetchStats() async {
    try {
      stats.value = await _repository.getPropertyStats();
    } catch (e) {
      print('Error fetching property stats: $e');
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
      );
      return;
    }

    final api = stats.value ?? PropertyStatsModel.empty();
    kpiStats.value = PropertyStatsModel(
      totalProperties: api.totalProperties,
      rentedCount: api.rentedCount,
      availableCount: api.availableCount,
      maintenanceCount: api.maintenanceCount,
      totalLandlords: landlords.length,
      activeLandlordCount: landlords.where((l) => l.isActive).length,
      totalTenants: tenants.length,
      tenantsAcrossProperties: api.tenantsAcrossProperties,
      totalRevenue: api.totalRevenue,
    );
  }

  PropertyStatsModel get displayStats => kpiStats.value;

  PropertyStatsModel _statsFromAssociatedProperties() {
    final uniqueLandlords = <String>{};
    final uniqueTenants = <String>{};
    var rented = 0;
    var available = 0;
    var maintenance = 0;
    var tenantsAcross = 0;
    num revenue = 0;

    for (final p in properties) {
      if (p.isRented) rented++;
      if (p.status == PropertyStatus.available) available++;
      if (p.status == PropertyStatus.maintenance) maintenance++;
      revenue += p.rentAmount;

      final landlordKey =
          p.landlordId.isNotEmpty ? p.landlordId : p.landlordName.trim();
      if (landlordKey.isNotEmpty) uniqueLandlords.add(landlordKey.toLowerCase());

      final tenantKey = (p.tenantIds.isNotEmpty
              ? p.tenantIds.first
              : (p.primaryTenantName ?? '').trim());
      if (tenantKey.isNotEmpty) {
        uniqueTenants.add(tenantKey.toLowerCase());
        tenantsAcross++;
      }
    }

    return PropertyStatsModel(
      totalProperties: properties.length,
      rentedCount: rented,
      availableCount: available,
      maintenanceCount: maintenance,
      totalLandlords: uniqueLandlords.length,
      activeLandlordCount: uniqueLandlords.length,
      totalTenants: uniqueTenants.length,
      tenantsAcrossProperties: tenantsAcross,
      totalRevenue: revenue,
    );
  }

  Future<void> fetchTenants() async {
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
      print('Error fetching tenants: $e');
    }
  }

  Future<void> fetchLandlords() async {
    try {
      var fetchedLandlords = await _repository.getAllLandlords();
      if (Get.isRegistered<AuthController>() &&
          Get.find<AuthController>().isTenant) {
        final names = properties.map((p) => p.landlordName.toLowerCase()).toSet();
        final ids = properties.map((p) => p.landlordId).toSet();
        fetchedLandlords = fetchedLandlords
            .where(
              (l) =>
                  ids.contains(l.id) || names.contains(l.name.toLowerCase()),
            )
            .toList();
      }
      landlords.assignAll(fetchedLandlords);
    } catch (e) {
      print('Error fetching landlords: $e');
    }
  }

  void search(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    if (query.isEmpty) {
      filteredProperties.assignAll(properties);
    } else {
      filteredProperties.assignAll(
        properties.where(
          (p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.landlordName.toLowerCase().contains(query.toLowerCase()) ||
              (p.primaryTenantName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              p.address.address.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void goToPage(int page) {
    if (page >= 1) currentPage.value = page;
  }

  Future<void> openPropertyDetails(PropertyModel property) async {
    selectedProperty.value = property;
    try {
      isDetailLoading.value = true;
      final detail = await _repository.getPropertyById(property.id);
      if (selectedProperty.value?.id == property.id) {
        selectedProperty.value = detail;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load property details');
    } finally {
      isDetailLoading.value = false;
    }
  }

  void closePropertyDetails() {
    selectedProperty.value = null;
    isDetailLoading.value = false;
  }

  void deleteLandlord(String id) {
    landlords.removeWhere((l) => l.id == id);
    properties.removeWhere((p) => p.landlordId == id);
    filteredProperties.assignAll(properties);
    currentPage.value = 1;
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
    Get.snackbar(
      'Success',
      'Landlord $name added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
    );
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
      Get.snackbar('Error', 'Failed to fetch tenant details: $e');
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
