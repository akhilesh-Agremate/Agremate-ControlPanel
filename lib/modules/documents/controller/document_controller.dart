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

  List<DocumentModel> get currentDocuments {
    return documents.where((d) => d.parentId == currentParentId.value).toList();
  }

  List<DocumentModel> get currentFolders => currentDocuments.where((d) => d.isFolder).toList();
  List<DocumentModel> get currentFiles => currentDocuments.where((d) => d.isFile).toList();

  @override
  void onInit() {
    super.onInit();
    _generateData();
  }

  void _generateData() {
    isLoading.value = true;
    final docs = <DocumentModel>[];
    final now = DateTime.now();
    // Root folders
    docs.add(DocumentModel(id:'F1',name:'Landlord Documents',type:'folder',ownerId:'admin',ownerName:'Admin',ownerType:'landlord',createdAt:now,modifiedAt:now));
    docs.add(DocumentModel(id:'F2',name:'Tenant Documents',type:'folder',ownerId:'admin',ownerName:'Admin',ownerType:'tenant',createdAt:now,modifiedAt:now));
    // Landlord subfolders
    final llNames = ['Rajesh Sharma','Priya Patel','Amit Kumar','Sunita Gupta','Vikram Singh'];
    final uploaders = ['Rajesh Sharma', 'Suresh Raina', 'Mahendra Singh', 'Virat Kohli', 'Rohit Sharma', 'Priya Patel', 'Ananya Singh'];
    for(int i=0;i<llNames.length;i++){
      final fid='F1_$i';
      docs.add(DocumentModel(id:fid,name:llNames[i],type:'folder',parentId:'F1',ownerId:'L${i+1}',ownerName:llNames[i],ownerType:'landlord',createdAt:now.subtract(Duration(days:_rng.nextInt(90))),modifiedAt:now.subtract(Duration(days:_rng.nextInt(10)))));
      // Files inside
      final fileTypes=['pdf','doc','image','spreadsheet'];
      final fileNames=['Rental Agreement','Property Tax Receipt','ID Proof','Insurance Policy','Bank Statement'];
      for(int j=0;j<fileNames.length;j++){
        docs.add(DocumentModel(id:'${fid}_$j',name:fileNames[j],type:'file',parentId:fid,ownerId:'L${i+1}',ownerName:uploaders[_rng.nextInt(uploaders.length)],ownerType:'landlord',fileType:fileTypes[_rng.nextInt(fileTypes.length)],sizeKb:_rng.nextDouble()*5000+100,createdAt:now.subtract(Duration(days:_rng.nextInt(180))),modifiedAt:now.subtract(Duration(days:_rng.nextInt(30)))));
      }
    }
    // Tenant subfolders
    final tnNames = ['Aarav Menon','Ishika Sen','Rohan Pillai','Diya Chopra','Arjun Saxena'];
    for(int i=0;i<tnNames.length;i++){
      final fid='F2_$i';
      docs.add(DocumentModel(id:fid,name:tnNames[i],type:'folder',parentId:'F2',ownerId:'T${i+1}',ownerName:tnNames[i],ownerType:'tenant',createdAt:now.subtract(Duration(days:_rng.nextInt(90))),modifiedAt:now.subtract(Duration(days:_rng.nextInt(10)))));
      final fileNames=['Lease Agreement','Aadhaar Card','Rent Receipt','Maintenance Bill'];
      final fileTypes=['pdf','doc','image','spreadsheet'];
      for(int j=0;j<fileNames.length;j++){
        docs.add(DocumentModel(id:'${fid}_$j',name:fileNames[j],type:'file',parentId:fid,ownerId:'T${i+1}',ownerName:uploaders[_rng.nextInt(uploaders.length)],ownerType:'tenant',fileType:fileTypes[_rng.nextInt(fileTypes.length)],sizeKb:_rng.nextDouble()*3000+50,createdAt:now.subtract(Duration(days:_rng.nextInt(180))),modifiedAt:now.subtract(Duration(days:_rng.nextInt(30)))));
      }
    }
    documents.value = docs;
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
