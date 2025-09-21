import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class AnimatedLottieEmojiBubble extends StatefulWidget {
  final Function(String) onSelected; // callback with animation file path
  const AnimatedLottieEmojiBubble({super.key, required this.onSelected});

  @override
  State<AnimatedLottieEmojiBubble> createState() => _AnimatedLottieEmojiBubbleState();
}

class _AnimatedLottieEmojiBubbleState extends State<AnimatedLottieEmojiBubble>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late List<AnimationController> _controllers;
  Timer? _removeTimer;

  bool _isShowing = false;
  bool _canClick = true;

  // 🔥 Funny Lottie animations (make sure JSON files exist in your assets!)
  final List<Map<String, String>> _funnyLotties = [
    {"file": "assets/animations/MessageAnimations/LaughingCat.json"},
    {"file": "assets/animations/emojis/clap.json"},
    {"file": "assets/animations/emojis/angry.json"},
    {"file": "assets/animations/emojis/party.json"},
    {"file": "assets/animations/emojis/sad.json"},
  ];

  void _showEmojiBubble() {
    if (!_canClick) return;

    setState(() {
      _canClick = false;
      _isShowing = true;
    });

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _controllers = List.generate(_funnyLotties.length, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy - 120,
        left: offset.dx + size.width / 2 - 160,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_funnyLotties.length, (index) {
                return GestureDetector(
                  onTap: () {
                    widget.onSelected(_funnyLotties[index]["file"]!); // ✅ send file path
                    _removeOverlay();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ScaleTransition(
                      scale: Tween(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _controllers[index],
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Lottie.asset(
                          _funnyLotties[index]["file"]!,
                          repeat: true,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_overlayEntry!);

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        _controllers[i].forward();
      });
    }

    _removeTimer = Timer(const Duration(seconds: 3), _removeOverlay);
  }

  void _removeOverlay() {
    _removeTimer?.cancel();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      for (var c in _controllers) c.dispose();
    }
    _isShowing = false;

    Timer(const Duration(milliseconds: 1200), () {
      setState(() {
        _canClick = true;
      });
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showEmojiBubble,
      child: Icon(
        Icons.emoji_emotions_outlined,
        color: _canClick && !_isShowing ? Colors.orangeAccent : Colors.grey,
        size: 32,
      ),
    );
  }
}
