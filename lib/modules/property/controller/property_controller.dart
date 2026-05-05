import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/property/model/landlord_model.dart';
import 'package:agremate_admin/modules/tenant/model/tenant_model.dart';
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
  final selectedProperty = Rxn<PropertyModel>();
  final returnTabIndex = Rxn<int>();

  final scrollController = ScrollController();
  static const int perPage = 30;

  int get totalPages {
    if (filteredProperties.isEmpty) return 0;
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

    // Scroll to top when page changes
    ever(currentPage, (_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });

    // Sync search from nav bar
    final nav = Get.find<NavigationController>();
    ever(nav.searchQuery, (String query) {
      if (nav.currentIndex.value == 1) search(query);
    });
  }

  Future<void> fetchProperties() async {
    try {
      isLoading.value = true;
      currentPage.value = 1; // always reset on fresh fetch
      final fetched = await _repository.getAllProperties();
      properties.assignAll(fetched);
      filteredProperties.assignAll(fetched);
      _buildDependentLists();
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
        lList.add(LandlordModel(
          id: prop.landlordId,
          name: prop.landlordName,
          phone: prop.landlordPhone ?? '',
          email: prop.landlordEmail ?? '',
          lastLogin: DateTime.now(),
        ));
      }
      if (prop.primaryTenantName != null &&
          !tList.any((t) => t.name == prop.primaryTenantName)) {
        tList.add(TenantModel(
          id: 'T-${prop.id}',
          name: prop.primaryTenantName!,
          phone: prop.primaryTenantPhone ?? '',
          email: prop.primaryTenantEmail ?? '',
          propertyId: prop.id,
          propertyName: prop.name,
          rentAmount: prop.rentAmount,
          lastLogin: DateTime.now(),
        ));
      }
    }
    landlords.assignAll(lList);
    tenants.assignAll(tList);
  }

  void search(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // reset page on search
    if (query.isEmpty) {
      filteredProperties.assignAll(properties);
    } else {
      filteredProperties.assignAll(properties.where((p) =>
          p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.landlordName.toLowerCase().contains(query.toLowerCase()) ||
          p.address.address.toLowerCase().contains(query.toLowerCase())));
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) currentPage.value = page;
  }

  void deleteLandlord(String id) {
    landlords.removeWhere((l) => l.id == id);
    properties.removeWhere((p) => p.landlordId == id);
    filteredProperties.assignAll(properties);
    currentPage.value = 1;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
