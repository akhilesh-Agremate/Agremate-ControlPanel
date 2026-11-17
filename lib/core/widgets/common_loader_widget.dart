import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoaderWidget extends StatefulWidget {
  final double? size;

  const LoaderWidget({super.key, this.size});

  @override
  State<LoaderWidget> createState() => _LoaderWidgetState();
}

class _LoaderWidgetState extends State<LoaderWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animation/Loading.json',
        width: widget.size,
        height: widget.size,
        controller: _controller,
        frameRate: FrameRate.max,
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..repeat();
        },
      ),
    );
  }
}