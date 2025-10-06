import 'dart:math';
import 'package:flutter/material.dart';

class FlyingSpendWidget extends StatefulWidget {
  final Offset startOffset;
  final GlobalKey endKey;
  final int amount;
  final VoidCallback onCompleted;

  const FlyingSpendWidget({
    super.key,
    required this.startOffset,
    required this.endKey,
    required this.amount,
    required this.onCompleted,
  });

  @override
  State<FlyingSpendWidget> createState() => _FlyingSpendWidgetState();
}

class _FlyingSpendWidgetState extends State<FlyingSpendWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Offset _randomOffset;

  Offset _getEndOffset() {
    final context = widget.endKey.currentContext;
    if (context == null) return Offset(200, 400);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return position + Offset(size.width / 2 - 16, size.height / 2 - 16);
  }

  @override
  void initState() {
    super.initState();
    final endOffset = _getEndOffset();
    final random = Random();
    _randomOffset = Offset(random.nextDouble() * 50 - 25, random.nextDouble() * 50 - 25);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + random.nextInt(300)),
    );

    _animation = Tween<Offset>(
      begin: widget.startOffset + _randomOffset,
      end: endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onCompleted();
    });

    _controller.forward();
  }

  @override
  void dispose() {
    if (_controller.isAnimating) widget.onCompleted();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: _animation.value.dx,
          top: _animation.value.dy,
          child: Image.asset(
            'assets/UI/Icons/Gamification/Gold_Icon.png',
            width: 30,
            height: 30,
          ),
        );
      },
    );
  }
}
