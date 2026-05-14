import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/property/model/landlord_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_details_model.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
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
  final selectedTenantDetails = Rxn<TenantDetailsModel>();
  final returnTabIndex = Rxn<int>();

  final scrollController = ScrollController();
  static const int perPage = 30;

  Timer? _autoRefreshTimer;

  int get totalPages {
    if (filteredProperties.isEmpty) return 1; // always show at least page 1
    return (filteredProperties.length / perPage).ceil();
  }

  /// Computes the slice for the current page directly — no caching, no stale state.
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

    // Auto-refresh every 30 seconds so new landlord properties appear
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshProperties();
    });

    // Scroll to top when page changes
    ever(currentPage, (_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Sync search from nav bar
    final nav = Get.find<NavigationController>();
    ever(nav.searchQuery, (String query) {
      if (nav.currentIndex.value == 1) search(query);
    });
  }

  /// Manual refresh — silently re-fetches without showing the full loading spinner.
  Future<void> refreshProperties() async {
    try {
      isRefreshing.value = true;
      final fetched = await _repository.getAllProperties();
      final prevCount = properties.length;
      properties.assignAll(fetched);
      // Re-apply current search filter
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
      await fetchTenants();
      await fetchLandlords();
      // Clamp page if new total is fewer pages
      if (currentPage.value > totalPages) currentPage.value = totalPages;
      if (fetched.length > prevCount) {
        Get.snackbar(
          'Updated',
          '${fetched.length - prevCount} new propert${fetched.length - prevCount == 1 ? "y" : "ies"} added',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (_) {
      // Silently ignore auto-refresh errors
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> fetchProperties() async {
    try {
      isLoading.value = true;
      currentPage.value = 1; // always reset on fresh fetch
      final fetched = await _repository.getAllProperties();
      properties.assignAll(fetched);
      filteredProperties.assignAll(fetched);
      _buildDependentLists();
      await fetchTenants();
      await fetchLandlords();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch properties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _buildDependentLists() {
    final lList = <LandlordModel>[];
    final tList = <TenantModel>[];
    for (final prop in properties) {
      if (!lList.any((l) => l.id == prop.landlordId)) {
        lList.add(
          LandlordModel(
            id: prop.landlordId,
            name: prop.landlordName,
            phone: prop.landlordPhone ?? '',
            email: prop.landlordEmail ?? '',
            lastLogin: DateTime.now(),
          ),
        );
      }
      if (prop.primaryTenantName != null &&
          !tList.any((t) => t.name == prop.primaryTenantName)) {
        tList.add(
          TenantModel(
            id: 'T-${prop.id}',
            name: prop.primaryTenantName!,
            phone: prop.primaryTenantPhone ?? '',
            email: prop.primaryTenantEmail ?? '',
            propertyId: prop.id,
            propertyName: prop.name,
            rentAmount: prop.rentAmount,
            lastLogin: DateTime.now(),
          ),
        );
      }
    }
    // landlords.assignAll(lList);
    if (landlords.isEmpty) {
      landlords.assignAll(lList);
    }
    // Only add tenants from properties if they are not already in the list (or just keep API tenants as primary)
    // For now, let's keep the API tenants as the primary list if available
    if (tenants.isEmpty) {
      tenants.assignAll(tList);
    }
  }

  Future<void> fetchTenants() async {
    try {
      final fetchedTenants = await _repository.getAllTenants();
      if (fetchedTenants.isNotEmpty) {
        tenants.assignAll(fetchedTenants);
      }
    } catch (e) {
      print('Error fetching tenants: $e');
    }
  }

  Future<void> fetchLandlords() async {
    try {
      final fetchedLandlords = await _repository.getAllLandlords();
      if (fetchedLandlords.isNotEmpty) {
        landlords.assignAll(fetchedLandlords);
      }
    } catch (e) {
      print('Error fetching landlords: $e');
    }
  }

  void search(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // reset page on search
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
    if (page >= 1) currentPage.value = page; // allow navigating to any page
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
      lastLogin: DateTime.now(),
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
          8; // Assuming 8 is the new TenantDetailView index
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
