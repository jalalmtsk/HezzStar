import 'dart:math';

import 'package:flutter/material.dart';

// 🟡 FlyingGold widget with amount text
class FlyingGold extends StatefulWidget {
  final Offset startOffset;
  final GlobalKey endKey;
  final VoidCallback onCompleted;
  final String amountText;

  const FlyingGold({
    super.key,
    required this.startOffset,
    required this.endKey,
    required this.onCompleted,
    required this.amountText,
  });

  @override
  State<FlyingGold> createState() => _FlyingGoldState();
}

class _FlyingGoldState extends State<FlyingGold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Offset _randomOffset;

  Offset _getEndOffset() {
    final renderBox = widget.endKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    // Center the coin on top of the gold icon
    return position + Offset(size.width / 2 - 16, size.height / 2 - 16);
  }

  @override
  void initState() {
    super.initState();
    final endOffset = _getEndOffset();
    final random = Random();
    // Add slight random offset for each coin
    _randomOffset = Offset(random.nextDouble() * 40 - 20, random.nextDouble() * 40 - 20);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<Offset>(
      begin: widget.startOffset + _randomOffset,
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/UI/Icons/Gamification/Gold_Icon.png',
            width: 32,
            height: 32,
          ),
          Positioned(
            top: -20,
            child: Text(
              widget.amountText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}