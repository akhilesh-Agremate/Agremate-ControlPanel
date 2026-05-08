import 'package:get/get.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;
  final searchQuery = ''.obs;

  void changePage(int index) {
    currentIndex.value = index;
    searchQuery.value = '';
  }

  bool get showSearch => currentIndex.value <= 6;

  void performGlobalSearch(String query) {
    if (query.isEmpty) return;
    
    // Lazy find to avoid circular dependency issues at start
    try {
      final pc = Get.find<PropertyController>();
      
      // 1. Search for tenant by name or phone
      final tenant = pc.tenants.firstWhereOrNull(
        (t) => t.name.toLowerCase().contains(query.toLowerCase()) ||
               t.phone.contains(query)
      );
      
      if (tenant != null) {
        pc.viewTenantDetails(tenant.id);
        return;
      }
      
      // 2. Search for property by name
      final property = pc.properties.firstWhereOrNull(
        (p) => p.name.toLowerCase().contains(query.toLowerCase())
      );
      
      if (property != null) {
        pc.selectedProperty.value = property;
        currentIndex.value = 1; // Nav to Property tab
        return;
      }
      
      // 3. Search for landlord by name
      final landlord = pc.landlords.firstWhereOrNull(
        (l) => l.name.toLowerCase().contains(query.toLowerCase())
      );
      
      if (landlord != null) {
        currentIndex.value = 6; // Nav to User Management tab
        return;
      }

      Get.snackbar(
        'Search', 
        'No matches found for "$query"',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Global search error: $e');
    }
  }
}
