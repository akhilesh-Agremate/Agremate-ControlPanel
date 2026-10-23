import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/modules/layout/controller/sidebar_controller.dart';

import '../../../../core/theme/theme.dart';

class ResizableSidebarLayout extends StatelessWidget {
  const ResizableSidebarLayout({
    super.key,
    required this.sidebarBuilder,
    required this.body,
    this.mobileBreakpoint = 800,
  });

  final Widget Function(BuildContext context, bool collapsed) sidebarBuilder;
  final Widget body;
  final double mobileBreakpoint;

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<SidebarController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        if (screenWidth < mobileBreakpoint) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            drawer: Drawer(
              width: 280,
              backgroundColor: Colors.white,
              child: sidebarBuilder(context, false),
            ),
            body: body,
          );
        }

        return Row(
          children: [
            Obx(() {
              final w = sc.width.value
                  .clamp(SidebarController.minWidth, sc.maxFor(screenWidth))
                  .toDouble();
              return AnimatedContainer(
                duration: sc.isDragging.value
                    ? Duration.zero
                    : const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                width: w,
                child: ClipRect(
                  child: sidebarBuilder(context, sc.isCollapsedFor(w)),
                ),
              );
            }),
            _DragHandle(controller: sc, screenWidth: screenWidth),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}

class _DragHandle extends StatefulWidget {
  const _DragHandle({required this.controller, required this.screenWidth});

  final SidebarController controller;
  final double screenWidth;

  @override
  State<_DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<_DragHandle> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sc = widget.controller;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => sc.isDragging.value = true,
        onHorizontalDragUpdate: (d) =>
            sc.resize(d.delta.dx, widget.screenWidth),
        onHorizontalDragEnd: (_) => sc.isDragging.value = false,
        onHorizontalDragCancel: () => sc.isDragging.value = false,
        onDoubleTap: sc.reset,
        child: SizedBox(
          width: 10,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(() {
                  final active = _hover || sc.isDragging.value;
                  return Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: active ? 3 : 1,
                      color: active
                          ? const Color(0xFF2F6BFF)
                          : const Color(0xFFE3EEF9),
                    ),
                  );
                }),
              ),
              Positioned(
                top: 69,
                left: 0,
                right: 0,
                height: 1,
                child: Container(color: AppTheme.border),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
