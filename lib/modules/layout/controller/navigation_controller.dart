import 'package:get/get.dart';
import 'package:agremate_admin/modules/property/controller/property_controller.dart';
import 'package:agremate_admin/modules/services/controller/services_controller.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';
import 'package:agremate_admin/core/utils/browser_url.dart';
import 'package:get_storage/get_storage.dart';
import 'package:agremate_admin/core/widgets/app_toast.dart';

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

  final GetStorage _box = GetStorage();
  static const _kIndex = 'nav.currentIndex';
  static const _kPropertyId = 'nav.propertyDetailId';
  static const _kDocumentId = 'nav.documentDetailId';
  static const _kFinanceId = 'nav.financeDetailId';
  static const _kFinanceName = 'nav.financeDetailName';
  bool _isRestorable(int i) => i >= 0 && i != 8;

  String? get propertyDetailId => _box.read<String>(_kPropertyId);
  String? get documentDetailId => _box.read<String>(_kDocumentId);
  String? get financeDetailId => _box.read<String>(_kFinanceId);
  String? get financeDetailName => _box.read<String>(_kFinanceName);

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read<int>(_kIndex);
    if (saved != null && _isRestorable(saved)) {
      currentIndex.value = saved;
    }
    _readUrl();
    ever<int>(currentIndex, (i) {
      if (_isRestorable(i)) _box.write(_kIndex, i);
      _writeUrl();
    });
  }

  void setPropertyDetailId(String? id) {
    if (id == null || id.isEmpty) {
      _box.remove(_kPropertyId);
    } else {
      _box.write(_kPropertyId, id);
    }
    _writeUrl();
  }

  void setDocumentDetailId(String? id) {
    if (id == null || id.isEmpty) {
      _box.remove(_kDocumentId);
    } else {
      _box.write(_kDocumentId, id);
    }
    _writeUrl();
  }

  void setFinanceDetail(String? id, String? name) {
    if (id == null || id.isEmpty) {
      _box.remove(_kFinanceId);
      _box.remove(_kFinanceName);
    } else {
      _box.write(_kFinanceId, id);
      _box.write(_kFinanceName, name ?? '');
    }
    _writeUrl();
  }

  void _readUrl() {
    final frag = Uri.base.fragment;
    if (!frag.contains('?')) return;
    final q = frag.substring(frag.indexOf('?') + 1);
    final params = Uri.splitQueryString(q);
    final tab = params['tab'] ?? '';
    final id = params['id'] ?? '';
    if (id.isEmpty) return;
    if (tab == 'property') {
      currentIndex.value = 1;
      _box.write(_kPropertyId, id);
    } else if (tab == 'documents') {
      currentIndex.value = 4;
      _box.write(_kDocumentId, id);
    } else if (tab == 'finance') {
      currentIndex.value = 3;
      _box.write(_kFinanceId, id);
      _box.write(_kFinanceName, params['name'] ?? '');
    }
  }

  void _writeUrl() {
    String path = '/dashboard';
    if (currentIndex.value == 1 && (propertyDetailId ?? '').isNotEmpty) {
      path = '/dashboard?tab=property&id=$propertyDetailId';
    } else if (currentIndex.value == 4 && (documentDetailId ?? '').isNotEmpty) {
      path = '/dashboard?tab=documents&id=$documentDetailId';
    } else if (currentIndex.value == 3 && (financeDetailId ?? '').isNotEmpty) {
      path = '/dashboard?tab=finance&id=$financeDetailId';
      final name = financeDetailName ?? '';
      if (name.isNotEmpty) {
        path += '&name=${Uri.encodeQueryComponent(name)}';
      }
    }
    replaceAppHash(path);
  }

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

        final seenIds = <String>{};
        searchResults.assignAll(
          results.where((r) => seenIds.add('${r.type}-${r.id}')).take(15),
        );
        return;
      }

      final isLandlordSearch = 'landlord'.contains(q) && q.length >= 4;
      final isPropertySearch = 'property'.contains(q) && q.length >= 4;
      final isTenantSearch = 'tenant'.contains(q) && q.length >= 4;
      final isLocationSearch = 'location'.contains(q) && q.length >= 4;

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

      final seenIds = <String>{};
      searchResults.assignAll(
        results.where((r) => seenIds.add('${r.type}-${r.id}')).take(15),
      );
    } catch (e) {
      AppLogger.e('NavigationController', 'Search error', e);
    }
  }

  void onResultSelected(GlobalSearchResult result) {
    searchResults.clear();

    final pc = Get.find<PropertyController>();

    switch (result.type) {
      case SearchResultType.property:
      case SearchResultType.location:
        searchQuery.value = '';
        pc.selectedProperty.value = result.originalData;
        currentIndex.value = 1;
        break;
      case SearchResultType.landlord:
        searchQuery.value = '';
        currentIndex.value = 1;
        final matches = pc.properties
            .where(
              (p) =>
                  p.landlordName.toLowerCase() == result.title.toLowerCase(),
            )
            .toList();

        if (matches.length == 1) {
          pc.selectedProperty.value = matches.first;
          pc.search('');
        } else {
          pc.search(result.title);
        }
        break;
      case SearchResultType.tenant:
        searchQuery.value = '';
        currentIndex.value = 1;
        final matches = pc.properties
            .where(
              (p) =>
                  p.primaryTenantName?.toLowerCase() ==
                  result.title.toLowerCase(),
            )
            .toList();

        if (matches.length == 1) {
          pc.selectedProperty.value = matches.first;
          pc.search('');
        } else {
          pc.search(result.title);
        }
        break;
      case SearchResultType.service:
        currentIndex.value = 2;
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
      AppToast.error('No matches found for "$query"');
    }
  }
}
