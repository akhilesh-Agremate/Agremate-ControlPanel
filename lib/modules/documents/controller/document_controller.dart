import 'dart:math';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/documents/model/document_model.dart';

import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';

class DocumentController extends GetxController {
  final documents = <DocumentModel>[].obs;
  final currentPath = <Map<String, String>>[].obs; // breadcrumb
  final currentParentId = Rxn<String>();
  final isLoading = true.obs;
  final returnTabIndex = Rxn<int>();
  final _rng = Random(42);

  String get searchQuery => Get.find<NavigationController>().searchQuery.value;

  List<DocumentModel> get allFiles {
    if (searchQuery.isEmpty) {
      return documents.where((d) => d.isFile).toList();
    }
    final query = searchQuery.toLowerCase();
    return documents.where((d) => 
      d.isFile && (
        d.name.toLowerCase().contains(query) ||
        (d.propertyName?.toLowerCase().contains(query) ?? false) ||
        d.ownerName.toLowerCase().contains(query)
      )
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _generateData();
  }

  void refreshData() {
    _generateData();
  }

  void _generateData() {
    isLoading.value = true;
    final docs = <DocumentModel>[];
    final now = DateTime.now();
    final uploaders = ['Rajesh Sharma', 'Suresh Raina', 'Mahendra Singh', 'Virat Kohli', 'Rohit Sharma', 'Priya Patel', 'Ananya Singh', 'Aarav Menon', 'Ishika Sen', 'Rohan Pillai', 'Diya Chopra', 'Arjun Saxena'];
    final properties = ['Green Villa', 'Andheri Apt 1', 'Powai Studio 5', 'Bandra Villa 3', 'Juhu Penthouse', 'Cyber Hub Apt', 'Malad Residency', 'Worli Sea Link', 'Tansen Heights', 'Imperial Towers'];
    final fileNames = ['Rental Agreement', 'Property Tax Receipt', 'ID Proof', 'Insurance Policy', 'Bank Statement', 'Aadhaar Card', 'Lease Agreement', 'Rent Receipt', 'Utility Bill', 'NoC Certificate'];
    final fileTypes = ['pdf', 'doc', 'image', 'spreadsheet'];

    for (int i = 0; i < 40; i++) {
      final isLandlord = _rng.nextBool();
      final property = properties[i % properties.length];
      final uploader = uploaders[i % uploaders.length];
      
      docs.add(DocumentModel(
        id: 'D$i',
        name: fileNames[_rng.nextInt(fileNames.length)],
        type: 'file',
        ownerId: 'O$i',
        ownerName: uploader,
        ownerType: isLandlord ? 'landlord' : 'tenant',
        propertyName: property,
        fileType: fileTypes[_rng.nextInt(fileTypes.length)],
        sizeKb: _rng.nextDouble() * 5000 + 100,
        createdAt: now.subtract(Duration(days: _rng.nextInt(180))),
        modifiedAt: now.subtract(Duration(days: _rng.nextInt(30))),
      ));
    }
    documents.assignAll(docs);
    isLoading.value = false;
  }

  void openFolder(String folderId, String folderName) {
    currentPath.add({'id': folderId, 'name': folderName});
    currentParentId.value = folderId;
  }

  void navigateToBreadcrumb(int index) {
    if (index < 0) {
      currentPath.clear();
      currentParentId.value = null;
    } else {
      final target = currentPath[index];
      currentPath.value = currentPath.sublist(0, index + 1);
      currentParentId.value = target['id'];
    }
  }

  void goBack() {
    if (returnTabIndex.value != null) {
      final nav = Get.find<NavigationController>();
      nav.currentIndex.value = returnTabIndex.value!;
      returnTabIndex.value = null;
      return;
    }

    if (currentPath.isNotEmpty) {
      currentPath.removeLast();
      currentParentId.value = currentPath.isNotEmpty ? currentPath.last['id'] : null;
    }
  }

  void navigateToOwnerFolder(String rootFolderId, String rootFolderName, String ownerName, String ownerType) {
    var folder = documents.firstWhereOrNull(
      (d) => d.parentId == rootFolderId && d.name == ownerName && d.isFolder
    );

    if (folder == null) {
      final newFolderId = '${rootFolderId}_dynamic_${DateTime.now().millisecondsSinceEpoch}';
      folder = DocumentModel(
        id: newFolderId,
        name: ownerName,
        type: 'folder',
        parentId: rootFolderId,
        ownerId: ownerType == 'landlord' ? 'L_dyn' : 'T_dyn',
        ownerName: ownerName,
        ownerType: ownerType,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );
      documents.add(folder);
      
      documents.add(DocumentModel(
        id: '${newFolderId}_f1',
        name: ownerType == 'landlord' ? 'Property Ownership Proof' : 'Lease Agreement',
        type: 'file',
        parentId: newFolderId,
        ownerId: folder.ownerId,
        ownerName: ownerName,
        ownerType: ownerType,
        fileType: 'pdf',
        sizeKb: 1250.0,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      ));
    }

    currentPath.value = [
      {'id': rootFolderId, 'name': rootFolderName},
      {'id': folder.id, 'name': folder.name},
    ];
    currentParentId.value = folder.id;
  }
}
