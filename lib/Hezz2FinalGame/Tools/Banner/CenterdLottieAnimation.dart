import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CenterLottieEffect extends StatefulWidget {
  final String lottieAsset;
  final double size;
  final Duration duration;
  final VoidCallback? onEnd;

  const CenterLottieEffect({
    super.key,
    required this.lottieAsset,
    this.size = 270,
    this.duration = const Duration(milliseconds: 600),
    this.onEnd,
  });

  @override
  State<CenterLottieEffect> createState() => _CenterLottieEffectWidgetState();
}

class _CenterLottieEffectWidgetState extends State<CenterLottieEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
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
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Lottie.asset(
              widget.lottieAsset,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
