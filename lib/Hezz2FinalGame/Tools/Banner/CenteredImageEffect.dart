import 'package:flutter/material.dart';

class CenterImageEffect extends StatefulWidget {
  final ImageProvider image;
  final double size;
  final Duration duration;
  final VoidCallback? onEnd;

  const CenterImageEffect({
    super.key,
    required this.image,
    this.size = 200,
    this.duration = const Duration(seconds: 1),
    this.onEnd,
  });

  @override
  State<CenterImageEffect> createState() => _CenterImageEffectState();
}

class _CenterImageEffectState extends State<CenterImageEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeIn,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Auto reverse after duration
    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        if (widget.onEnd != null) widget.onEnd!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: widget.image,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.7),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
