import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CenterLottieEffect {
  final BuildContext context;

  CenterLottieEffect({required this.context});

  /// [lottieAsset] is your local JSON file or network URL
  /// [size] sets the width & height of the animation
  void show(String lottieAsset, {double size = 250, Duration duration = const Duration(seconds: 2)}) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _AnimatedLottie(
        lottieAsset: lottieAsset,
        size: size,
        duration: duration,
        onEnd: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _AnimatedLottie extends StatefulWidget {
  final String lottieAsset;
  final double size;
  final Duration duration;
  final VoidCallback onEnd;

  const _AnimatedLottie({
    required this.lottieAsset,
    required this.size,
    required this.duration,
    required this.onEnd,
  });

  @override
  State<_AnimatedLottie> createState() => _AnimatedLottieState();
}

class _AnimatedLottieState extends State<_AnimatedLottie> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeIn,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _controller.forward();

    // auto close after duration
    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onEnd();
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
    final screen = MediaQuery.of(context).size;

    return Positioned(
      left: (screen.width - widget.size) / 2,
      top: (screen.height - widget.size) / 2,
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
