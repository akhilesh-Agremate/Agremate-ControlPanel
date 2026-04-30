import 'package:get/get.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;
  final searchQuery = ''.obs;

  void changePage(int index) {
    currentIndex.value = index;
    searchQuery.value = '';
  }

  bool get showSearch => currentIndex.value < 5;
}
