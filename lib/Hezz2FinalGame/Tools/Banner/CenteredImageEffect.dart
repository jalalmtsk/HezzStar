import 'package:flutter/material.dart';

class CenterImageEffect extends StatefulWidget {
  final String imagePath;
  final Duration duration;
  final double imageWidth;
  final Color glowColor;
  final VoidCallback? onEnd;

  const CenterImageEffect({
    super.key,
    required this.imagePath,
    this.duration = const Duration(milliseconds: 800),
    this.imageWidth = 200,
    this.glowColor = Colors.orange,
    this.onEnd,
  });

  @override
  State<CenterImageEffect> createState() => _GlowingImageBannerState();
}

class _GlowingImageBannerState extends State<CenterImageEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
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
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Auto reverse after given duration
    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onEnd?.call();
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
            height: 300,
            child: Image.asset(
              widget.imagePath,
              width: widget.imageWidth,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
