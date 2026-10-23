import 'package:get/get.dart';

class SidebarController extends GetxController {
  static const double minWidth = 72;
  static const double maxWidth = 360;
  static const double defaultWidth = 260;
  static const double collapseThreshold = 150;

  final width = defaultWidth.obs;
  final isDragging = false.obs;

  bool isCollapsedFor(double w) => w < collapseThreshold;

  double maxFor(double screenWidth) =>
      (screenWidth * 0.4).clamp(minWidth, maxWidth).toDouble();

  void resize(double delta, double screenWidth) {
    width.value =
        (width.value + delta).clamp(minWidth, maxFor(screenWidth)).toDouble();
  }

  void reset() => width.value = defaultWidth;
}