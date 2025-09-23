import 'package:flutter/material.dart';

class FlyingGold extends StatefulWidget {
  final Offset startOffset;
  final GlobalKey endKey;
  final VoidCallback onCompleted;

  const FlyingGold({
    super.key,
    required this.startOffset,
    required this.endKey,
    required this.onCompleted,
  });

  @override
  State<FlyingGold> createState() => _FlyingGoldState();
}

class _FlyingGoldState extends State<FlyingGold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  Offset _getEndOffset() {
    final renderBox =
    widget.endKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero) + Offset(20, 20);
  }

  @override
  void initState() {
    super.initState();
    final endOffset = _getEndOffset();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<Offset>(
      begin: widget.startOffset,
      end: endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
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
          child: child!,
        );
      },
      child: Image.asset(
        'assets/UI/Icons/Gamification/Gold_Icon.png',
        width: 32,
        height: 32,
      ),
    );
  }
}
