import 'package:flutter/material.dart';

class ClockAnimationLayer extends StatefulWidget {
  @override
  _ClockAnimationLayerState createState() => _ClockAnimationLayerState();
}

class _ClockAnimationLayerState extends State<ClockAnimationLayer>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
      reverseDuration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: Container(
        color: Colors.black,
      ),
      builder: (BuildContext context, Widget child) {
        return Opacity(
          opacity: _controller.value,
          child: child,
        );
      },
    );
  }
}
