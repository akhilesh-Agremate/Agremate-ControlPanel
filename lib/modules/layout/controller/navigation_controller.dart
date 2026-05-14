import 'package:get/get.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/services/controller/services_controller.dart';

enum SearchResultType { property, landlord, tenant, location, service }

class GlobalSearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final dynamic originalData;

  GlobalSearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.originalData,
  });
}

class NavigationController extends GetxController {
  final currentIndex = 0.obs;
  final searchQuery = ''.obs;
  final searchResults = <GlobalSearchResult>[].obs;

  void changePage(int index) {
    currentIndex.value = index;
    searchQuery.value = '';
    searchResults.clear();
  }

  bool get showSearch => currentIndex.value <= 6;

  void updateSearchResults(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      final pc = Get.find<PropertyController>();
      final results = <GlobalSearchResult>[];
      final q = query.toLowerCase();

      // IF ON SERVICES PAGE: Only search services
      if (currentIndex.value == 2) {
        if (Get.isRegistered<ServicesController>()) {
          final sc = Get.find<ServicesController>();
          final serviceMatches = sc.serviceRequests
              .where((s) =>
                  s.propertyName.toLowerCase().contains(q) ||
                  s.tenantName.toLowerCase().contains(q) ||
                  s.description.toLowerCase().contains(q) ||
                  s.serviceType.toLowerCase().contains(q))
              .map(
                (s) => GlobalSearchResult(
                  id: s.id,
                  title: s.description,
                  subtitle: 'Service • ${s.propertyName} (${s.serviceType})',
                  type: SearchResultType.service,
                  originalData: s,
                ),
              );
          results.addAll(serviceMatches);
        }
        
        // Remove duplicates and limit results
        final seenIds = <String>{};
        searchResults.assignAll(
          results.where((r) => seenIds.add('${r.type}-${r.id}')).take(15),
        );
        return;
      }

      // OTHERWISE: Global property search logic
      // Special Keyword Check
      final isLandlordSearch = 'landlord'.contains(q) && q.length >= 4;
      final isPropertySearch = 'property'.contains(q) && q.length >= 4;
      final isTenantSearch = 'tenant'.contains(q) && q.length >= 4;
      final isLocationSearch = 'location'.contains(q) && q.length >= 4;

      // 1. Search Properties
      final propertyMatches = pc.properties
          .where((p) => p.name.toLowerCase().contains(q) || isPropertySearch)
          .map(
            (p) => GlobalSearchResult(
              id: p.id,
              title: p.name,
              subtitle: 'Property • ${p.landlordName}',
              type: SearchResultType.property,
              originalData: p,
            ),
          );
      results.addAll(propertyMatches);

      // 2. Search Landlords
      final landlordMatches = pc.landlords
          .where((l) => l.name.toLowerCase().contains(q) || isLandlordSearch)
          .map(
            (l) => GlobalSearchResult(
              id: l.id,
              title: l.name,
              subtitle: 'Landlord • ${l.phone.isNotEmpty ? l.phone : 'Agremate Landlord'}',
              type: SearchResultType.landlord,
              originalData: l,
            ),
          );
      results.addAll(landlordMatches);

      // 3. Search Tenants
      final tenantMatches = pc.tenants
          .where(
            (t) =>
                t.name.toLowerCase().contains(q) ||
                t.phone.contains(q) ||
                isTenantSearch,
          )
          .map(
            (t) => GlobalSearchResult(
              id: t.id,
              title: t.name,
              subtitle: 'Tenant • ${t.propertyName ?? 'Agremate Tenant'}',
              type: SearchResultType.tenant,
              originalData: t,
            ),
          );
      results.addAll(tenantMatches);

      // 4. Search Locations (Addresses)
      final locationMatches = pc.properties
          .where(
            (p) =>
                p.address.address.toLowerCase().contains(q) || isLocationSearch,
          )
          .map(
            (p) => GlobalSearchResult(
              id: 'loc-${p.id}',
              title: p.address.address,
              subtitle: 'Location • ${p.name}',
              type: SearchResultType.location,
              originalData: p,
            ),
          );
      results.addAll(locationMatches);
      
      // 5. Search Services (Maintenance Requests)
      try {
        if (Get.isRegistered<ServicesController>()) {
          final sc = Get.find<ServicesController>();
          final serviceMatches = sc.serviceRequests
              .where((s) =>
                  s.propertyName.toLowerCase().contains(q) ||
                  s.tenantName.toLowerCase().contains(q) ||
                  s.description.toLowerCase().contains(q) ||
                  s.serviceType.toLowerCase().contains(q))
              .map(
                (s) => GlobalSearchResult(
                  id: s.id,
                  title: s.description,
                  subtitle: 'Service • ${s.propertyName} (${s.serviceType})',
                  type: SearchResultType.service,
                  originalData: s,
                ),
              );
          results.addAll(serviceMatches);
        }
      } catch (_) {}

      // Remove duplicates and limit results
      final seenIds = <String>{};
      searchResults.assignAll(
        results.where((r) => seenIds.add('${r.type}-${r.id}')).take(15),
      );
    } catch (e) {
      print('Search error: $e');
    }
  }

  void onResultSelected(GlobalSearchResult result) {
    searchResults.clear();

    final pc = Get.find<PropertyController>();

    switch (result.type) {
      case SearchResultType.property:
      case SearchResultType.location:
        searchQuery.value = ''; // Clear for property navigation
        pc.selectedProperty.value = result.originalData;
        currentIndex.value = 1; // Navigation to Property page
        break;
      case SearchResultType.landlord:
        searchQuery.value = ''; // Clear for property navigation
        currentIndex.value = 1; // Property page
        // Find if this landlord has exactly one property
        final matches = pc.properties
            .where(
              (p) =>
                  p.landlordName.toLowerCase() == result.title.toLowerCase(),
            )
            .toList();

        if (matches.length == 1) {
          pc.selectedProperty.value = matches.first;
          pc.search(''); // clear search filter so back button shows all
        } else {
          pc.search(result.title);
        }
        break;
      case SearchResultType.tenant:
        searchQuery.value = ''; // Clear for property navigation
        currentIndex.value = 1; // Property page
        // Find if this tenant has exactly one property
        final matches = pc.properties
            .where(
              (p) =>
                  p.primaryTenantName?.toLowerCase() ==
                  result.title.toLowerCase(),
            )
            .toList();

        if (matches.length == 1) {
          pc.selectedProperty.value = matches.first;
          pc.search(''); // clear search filter so back button shows all
        } else {
          pc.search(result.title);
        }
        break;
      case SearchResultType.service:
        currentIndex.value = 2; // Services page
        // Update searchQuery to the specific title so it filters the list below
        searchQuery.value = result.title;
        break;
    }
  }

  void performGlobalSearch(String query) {
    if (query.isEmpty) return;
    updateSearchResults(query);
    if (searchResults.isNotEmpty) {
      onResultSelected(searchResults.first);
    } else {
      Get.snackbar(
        'Search',
        'No matches found for "$query"',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
