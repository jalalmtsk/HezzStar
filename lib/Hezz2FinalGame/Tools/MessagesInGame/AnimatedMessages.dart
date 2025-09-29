import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedLottieEmojiBubble extends StatefulWidget {
  final Function(String) onSelected;
  const AnimatedLottieEmojiBubble({super.key, required this.onSelected});

  @override
  State<AnimatedLottieEmojiBubble> createState() =>
      _AnimatedLottieEmojiBubbleState();
}

class _AnimatedLottieEmojiBubbleState extends State<AnimatedLottieEmojiBubble>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  List<AnimationController> _controllers = [];
  Timer? _removeTimer;

  bool _isShowing = false;
  bool _canClick = true;

  final List<Map<String, String>> _funnyLotties = [
    {"file": "assets/animations/MessageAnimations/LaughingCat.json"},
    {"file": "assets/animations/MessageAnimations/AngryEmoji.json"},
    {"file": "assets/animations/MessageAnimations/CoolEmoji.json"},
    {"file": "assets/animations/MessageAnimations/MoneyEmoji.json"},
    {"file": "assets/animations/MessageAnimations/StreamOfHearts.json"},
  ];

  void _showEmojiBubble() {
    if (!_canClick || !mounted) return;

    setState(() {
      _canClick = false;
      _isShowing = true;
    });

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return; // ⛔ safety
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // dispose old controllers
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers = List.generate(_funnyLotties.length, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy - 20,
        left: offset.dx + size.width / 2 - 300,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(6),
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
                    final selectedFile = _funnyLotties[index]["file"]!;
                    widget.onSelected(selectedFile);

                    // 🎭 Show selected emoji overlay
                    final emojiOverlay = OverlayEntry(
                      builder: (context) => Positioned(
                        bottom: 150,
                        left: MediaQuery.of(context).size.width / 2 - 40,
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Lottie.asset(selectedFile, repeat: true),
                        ),
                      ),
                    );

                    if (mounted) {
                      Overlay.of(context)?.insert(emojiOverlay);

                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          emojiOverlay.remove();
                        }
                      });
                    }

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

    if (mounted) {
      Overlay.of(context)?.insert(_overlayEntry!);
    }

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted && i < _controllers.length) {
          _controllers[i].forward();
        }
      });
    }

    _removeTimer = Timer(const Duration(seconds: 10), _removeOverlay);
  }

  void _removeOverlay() {
    _removeTimer?.cancel();
    _removeTimer = null;

    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;

      for (var c in _controllers) {
        c.dispose();
      }
      _controllers.clear();
    }

    _isShowing = false;

    if (mounted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _canClick = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _removeTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showEmojiBubble,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          Icons.message,
          color: _canClick && !_isShowing ? Colors.orangeAccent : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}
