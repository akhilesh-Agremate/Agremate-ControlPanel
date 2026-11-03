import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/documents/model/document_model.dart';
import 'package:agremate_admin/modules/documents/repository/document_repository.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/modules/property/model/property_model.dart';
import 'package:agremate_admin/modules/property/repository/property_repository.dart';
import 'package:agremate_admin/core/utils/app_logger.dart';
import 'package:agremate_admin/core/widgets/app_toast.dart';
import '../model/document_category.dart';

class DocumentController extends GetxController {
  DocumentController(DocumentRepository repository);

  final properties = <PropertyModel>[].obs;
  final documents = <DocumentModel>[].obs;
  final selectedProperty = Rxn<PropertyModel>();
  final currentPath = <Map<String, String>>[].obs;
  final currentParentId = Rxn<String>();
  final isLoading = true.obs;
  final isDetailLoading = false.obs;
  final errorMessage = ''.obs;
  final returnTabIndex = Rxn<int>();

  String get searchQuery => Get.find<NavigationController>().searchQuery.value;

  List<PropertyModel> get visibleProperties {
    final query = searchQuery.toLowerCase();
    if (query.isEmpty) return properties.toList();
    return properties
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.landlordName.toLowerCase().contains(query) ||
              (p.primaryTenantName ?? '').toLowerCase().contains(query),
        )
        .toList();
  }

  List<DocumentModel> get allFiles {
    if (searchQuery.isEmpty) return documents.toList();
    final query = searchQuery.toLowerCase();
    return documents
        .where(
          (d) =>
              d.name.toLowerCase().contains(query) ||
              (d.propertyName?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  List<DocumentModel> get currentFolders => const [];

  List<DocumentModel> get currentFiles => allFiles;

  @override
  void onInit() {
    super.onInit();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    try {
      errorMessage.value = '';
      isLoading.value = true;
      selectedProperty.value = null;
      documents.clear();
      final repo = Get.find<PropertyRepository>();
      properties.assignAll(await repo.getAllProperties());
    } catch (e) {
      errorMessage.value = 'Failed to load properties.';
    } finally {
      isLoading.value = false;
      await _restoreDetailIfNeeded();
    }
  }

  Future<void> _restoreDetailIfNeeded() async {
    if (selectedProperty.value != null) return;
    if (!Get.isRegistered<NavigationController>()) return;
    final id = Get.find<NavigationController>().documentDetailId;
    if (id == null || id.isEmpty) return;
    PropertyModel? match;
    for (final p in properties) {
      if (p.id == id) {
        match = p;
        break;
      }
    }
    if (match != null) {
      await openPropertyDocuments(match);
      return;
    }
    try {
      final repo = Get.find<PropertyRepository>();
      final detail = await repo.getPropertyById(id);
      await openPropertyDocuments(detail);
    } catch (_) {}
  }

  Future<void> openPropertyDocuments(PropertyModel property) async {
    selectedProperty.value = property;
    Get.find<NavigationController>().setDocumentDetailId(property.id);
    AppLogger.i(
      'DocumentController',
      'Open property documents id=${property.id}',
    );
    try {
      isDetailLoading.value = true;
      errorMessage.value = '';
      final repo = Get.find<PropertyRepository>();
      final detail = await repo.getPropertyById(property.id);
      if (selectedProperty.value?.id != property.id) return;
      selectedProperty.value = detail;
      documents.assignAll(_docsFromProperty(detail));
      AppLogger.i(
        'DocumentController',
        'Property documents loaded count=${documents.length}',
      );
    } catch (e) {
      AppLogger.e('DocumentController', 'Load property documents failed', e);
      documents.clear();
      errorMessage.value = 'Failed to load property documents.';
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<bool> uploadDocument({
    required PlatformFile file,
    required DocumentCategory category,
    PropertyModel? property,
  }) async {
    if (category.needsProperty && property == null) {
      AppToast.error('Please select a property.');
      return false;
    }
    try {
      final message = await Get.find<DocumentRepository>().uploadDocument(
        propertyId: category.needsProperty ? property!.id : null,
        category: category.value,
        file: file,
        fileName: file.name,
      );
      AppToast.success(message);
      final open = selectedProperty.value;
      if (open != null && property != null && open.id == property.id) {
        await openPropertyDocuments(open);
      }
      return true;
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> deleteDocument(DocumentModel file) async {
    if (!file.isDeletable) {
      AppToast.error('This document cannot be deleted.');
      return false;
    }
    try {
      final ids = file.candidateIds.isNotEmpty ? file.candidateIds : [file.id];
      print('DELETE candidate ids: $ids');
      final message =
      await Get.find<DocumentRepository>().softDeleteDocument(ids);
      documents.removeWhere((d) => d.id == file.id);
      selectedProperty.refresh();
      AppToast.success(message);
      return true;
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  List<DocumentModel> _docsFromProperty(PropertyModel property) {
    final list = <DocumentModel>[];
    for (final item in property.documents) {
      if (item is Map) {
        print('DOC RAW JSON: $item');
        final json = Map<String, dynamic>.from(item);
        json['propertyName'] ??= property.name;
        list.add(DocumentModel.fromJson(json));
      }
    }
    return list;
  }

  void refreshData() {
    if (selectedProperty.value != null) {
      openPropertyDocuments(selectedProperty.value!);
    } else {
      fetchProperties();
    }
  }

  void openFolder(String folderId, String folderName) {}

  void navigateToBreadcrumb(int index) {}

  void goBack() {
    if (returnTabIndex.value != null && selectedProperty.value == null) {
      final nav = Get.find<NavigationController>();
      nav.currentIndex.value = returnTabIndex.value!;
      returnTabIndex.value = null;
      return;
    }
    selectedProperty.value = null;
    documents.clear();
    errorMessage.value = '';
    Get.find<NavigationController>().setDocumentDetailId(null);
  }

  void navigateToOwnerFolder(
    String rootFolderId,
    String rootFolderName,
    String ownerName,
    String ownerType,
  ) {}
}
