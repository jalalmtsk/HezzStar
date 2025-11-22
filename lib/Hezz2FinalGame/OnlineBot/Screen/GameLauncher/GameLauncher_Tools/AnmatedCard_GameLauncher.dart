import 'dart:math';

import 'package:flutter/material.dart';

/// A reusable animated card that flips on tap.
/// - `backImagePath` shows the back face
/// - `frontBuilder` builds the front face (customizable)
class AnimatedCard extends StatefulWidget {
  final double width;
  final double height;
  final String backImagePath;
  final WidgetBuilder frontBuilder;
  final Color accent;

  const AnimatedCard({
    super.key,
    required this.width,
    required this.height,
    required this.backImagePath,
    required this.frontBuilder,
    required this.accent,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipController.isAnimating) return;
    if (_showFront) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final t = _flipController.value;
          final ang = t * pi; // 0 -> pi
          final isFrontVisible = t > 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(ang),
            child: isFrontVisible ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: widget.accent.withOpacity(0.25), blurRadius: 8, offset: const Offset(2, 3))],
        ),
        child: Image.asset(
          widget.backImagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFront() {
    // When front-side shows, we flip the content horizontally to keep it readable (because we rotated)
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi), // mirror front so it reads correctly
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.frontBuilder(context),
        ),
      ),
    );
  }
}
