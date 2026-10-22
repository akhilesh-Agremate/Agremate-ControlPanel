import 'package:get/get.dart';
import 'package:agremate_admin/modules/documents/repository/document_repository.dart';
import 'package:agremate_admin/modules/documents/controller/document_controller.dart';

class DocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentRepository>(() => DocumentRepository());
    Get.lazyPut<DocumentController>(
      () => DocumentController(Get.find<DocumentRepository>()),
    );
  }
}
