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
    {"file": "assets/animations/MessageAnimations/AngryEmoji.json"},
    {"file": "assets/animations/MessageAnimations/CoolEmoji.json"},
    {"file": "assets/animations/MessageAnimations/StreamOfHearts.json"},
    {"file": "assets/animations/MessageAnimations/MoneyEmoji.json"},
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
        duration: const Duration(milliseconds: 300),
      );
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy - 120,
        left: offset.dx + size.width / 2 - 350,
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

                    // 🎭 Show the selected emoji animation in a new overlay
                    final emojiOverlay = OverlayEntry(
                      builder: (context) => Positioned(
                        bottom: 150, // adjust position
                        left: MediaQuery.of(context).size.width / 2 - 50,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Lottie.asset(
                            selectedFile,
                            repeat: true, // loop
                          ),
                        ),
                      ),
                    );

                    Overlay.of(context)?.insert(emojiOverlay);

                    // ⏳ remove after 3 seconds
                    Future.delayed(const Duration(milliseconds: 3500), () {
                      emojiOverlay.remove();
                    });

                    // remove the emoji bubble menu
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
      Future.delayed(Duration(milliseconds: i * 150), () {
        _controllers[i].forward();
      });
    }

    _removeTimer = Timer(const Duration(seconds: 10), _removeOverlay);
  }

  void _removeOverlay() {
    _removeTimer?.cancel();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      for (var c in _controllers) c.dispose();
    }
    _isShowing = false;

    Timer(const Duration(milliseconds: 3000), () {
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
        Icons.bubble_chart_outlined,
        color: _canClick && !_isShowing ? Colors.orangeAccent : Colors.grey,
        size: 32,
      ),
    );
  }
}
