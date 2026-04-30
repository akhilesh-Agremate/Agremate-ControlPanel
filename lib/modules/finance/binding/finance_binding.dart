import 'package:get/get.dart';
import 'package:agremate_admin/modules/finance/controller/finance_controller.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinanceController>(() => FinanceController());
  }
}

