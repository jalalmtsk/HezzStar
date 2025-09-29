import 'package:flutter/material.dart';

class CenterBanner {
  final BuildContext context;
  final GlobalKey centerKey;

  CenterBanner({required this.context, required this.centerKey});

  void show(String text, Color col) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        final c = _rectFor(centerKey)?.center ??
            Offset(
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height * 0.35,
            );

        return _AnimatedBanner(
          text: text,
          color: col,
          position: c,
          onEnd: () => entry.remove(),
        );
      },
    );

    overlay.insert(entry);
  }

  Rect? _rectFor(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final offset = renderObject.localToGlobal(Offset.zero);
      return offset & renderObject.size;
    }
    return null;
  }
}

class _AnimatedBanner extends StatefulWidget {
  final String text;
  final Color color;
  final Offset position;
  final VoidCallback onEnd;

  const _AnimatedBanner({
    required this.text,
    required this.color,
    required this.position,
    required this.onEnd,
  });

  @override
  State<_AnimatedBanner> createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<_AnimatedBanner>
    with SingleTickerProviderStateMixin {
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
      curve: Curves.elasticOut, // bouncy anime-style entrance
      reverseCurve: Curves.easeIn,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // auto close
    Future.delayed(const Duration(seconds: 2), () async {
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
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy - 120,
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
