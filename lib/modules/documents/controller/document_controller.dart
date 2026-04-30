import 'dart:math';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/documents/model/document_model.dart';

class DocumentController extends GetxController {
  final documents = <DocumentModel>[].obs;
  final currentPath = <Map<String, String>>[].obs; // breadcrumb
  final currentParentId = Rxn<String>();
  final isLoading = true.obs;
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
    for(int i=0;i<llNames.length;i++){
      final fid='F1_$i';
      docs.add(DocumentModel(id:fid,name:llNames[i],type:'folder',parentId:'F1',ownerId:'L${i+1}',ownerName:llNames[i],ownerType:'landlord',createdAt:now.subtract(Duration(days:_rng.nextInt(90))),modifiedAt:now.subtract(Duration(days:_rng.nextInt(10)))));
      // Files inside
      final fileTypes=['pdf','doc','image','spreadsheet'];
      final fileNames=['Rental Agreement','Property Tax Receipt','ID Proof','Insurance Policy','Bank Statement'];
      for(int j=0;j<fileNames.length;j++){
        docs.add(DocumentModel(id:'${fid}_$j',name:fileNames[j],type:'file',parentId:fid,ownerId:'L${i+1}',ownerName:llNames[i],ownerType:'landlord',fileType:fileTypes[_rng.nextInt(fileTypes.length)],sizeKb:_rng.nextDouble()*5000+100,createdAt:now.subtract(Duration(days:_rng.nextInt(180))),modifiedAt:now.subtract(Duration(days:_rng.nextInt(30)))));
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
        docs.add(DocumentModel(id:'${fid}_$j',name:fileNames[j],type:'file',parentId:fid,ownerId:'T${i+1}',ownerName:tnNames[i],ownerType:'tenant',fileType:fileTypes[_rng.nextInt(fileTypes.length)],sizeKb:_rng.nextDouble()*3000+50,createdAt:now.subtract(Duration(days:_rng.nextInt(180))),modifiedAt:now.subtract(Duration(days:_rng.nextInt(30)))));
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
    if (currentPath.isNotEmpty) {
      currentPath.removeLast();
      currentParentId.value = currentPath.isNotEmpty ? currentPath.last['id'] : null;
    }
  }
}
