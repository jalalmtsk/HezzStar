import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedEmojiBubble extends StatefulWidget {
  final Function(String) onSelected; // callback to show emoji or phrase
  const AnimatedEmojiBubble({super.key, required this.onSelected});

  @override
  State<AnimatedEmojiBubble> createState() => _AnimatedEmojiBubbleState();
}

class _AnimatedEmojiBubbleState extends State<AnimatedEmojiBubble>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late List<AnimationController> _controllers;
  Timer? _removeTimer;

  bool _isShowing = false; // Overlay visible
  bool _canClick = true; // Prevent rapid clicks

  final List<Map<String, String>> _emojis = [
    {"emoji": "👍", "label": "Good!"},
    {"emoji": "😂", "label": "Funny"},
    {"emoji": "❤️", "label": "Love"},
    {"emoji": "😮", "label": "Wow"},
    {"emoji": "😢", "label": "Sad"},
  ];

  final List<Map<String, String>> _phrases = [
    {"emoji": "💬", "label": "Hello!"},
    {"emoji": "💬", "label": "Good luck!"},
    {"emoji": "💬", "label": "Well played!"},
    {"emoji": "💬", "label": "Oops!"},
    {"emoji": "💬", "label": "Thanks!"},
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

    // Initialize controllers for emojis + phrases
    _controllers = List.generate(_emojis.length + _phrases.length, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
      );
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy - 80,
        left: offset.dx + size.width / 2 - 300,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row of emojis
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_emojis.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        widget.onSelected(_emojis[index]["emoji"]!);
                        _removeOverlay();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ScaleTransition(
                          scale: Tween(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _controllers[index],
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _emojis[index]["emoji"]!,
                                style: const TextStyle(fontSize: 26),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _emojis[index]["label"]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                // Row of phrases
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_phrases.length, (index) {
                    int controllerIndex = _emojis.length + index;
                    return GestureDetector(
                      onTap: () {
                        widget.onSelected(_phrases[index]["label"]!);
                        _removeOverlay();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ScaleTransition(
                          scale: Tween(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _controllers[controllerIndex],
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _phrases[index]["label"]!,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
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

    _removeTimer = Timer(const Duration(seconds: 2), _removeOverlay);
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
        Icons.message_outlined,
        color: _canClick && !_isShowing ? Colors.white : Colors.grey,
        size: 30,
      ),
    );
  }
}
