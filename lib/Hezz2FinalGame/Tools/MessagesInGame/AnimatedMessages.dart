import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../tools/AudioManager/AudioManager.dart';

class AnimatedLottieEmojiBubble extends StatefulWidget {
  final Function(String) onSelected;
  const AnimatedLottieEmojiBubble({super.key, required this.onSelected});

  @override
  State<AnimatedLottieEmojiBubble> createState() =>
      _AnimatedLottieEmojiBubbleState();
}

class _AnimatedLottieEmojiBubbleState extends State<AnimatedLottieEmojiBubble>
    with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];
  bool _isShowing = false;

  final List<Map<String, String>> _funnyLotties = [
    {
      "file": "assets/animations/MessageAnimations/CoolEmoji.json",
      "sound": "assets/audios/UI/SFX/MessageSound/ohYeah.mp3"
    },
    {
      "file": "assets/animations/MessageAnimations/AngryEmoji.json",
      "sound": "assets/audios/UI/SFX/MessageSound/evilLaugh.mp3"
    },
    {
      "file": "assets/animations/MessageAnimations/LaughingCat.json",
      "sound": "assets/audios/UI/SFX/MessageSound/CatLaugh.mp3"
    },
    {
      "file": "assets/animations/MessageAnimations/cryingSmoothymon.json",
      "sound": "assets/audios/UI/SFX/MessageSound/CryingAziza.mp3"
    },
    {
      "file": "assets/animations/MessageAnimations/StreamOfHearts.json",
      "sound": "assets/audios/UI/SFX/MessageSound/ohYeah.mp3"
    },
  ];

  void _toggleEmojiBubble() {
    if (!mounted) return;

    setState(() {
      _isShowing = !_isShowing;
    });

    if (_isShowing) {
      // Dispose old controllers
      for (final c in _controllers) {
        c.dispose();
      }
      _controllers = List.generate(_funnyLotties.length, (_) {
        return AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        );
      });

      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted && i < _controllers.length) _controllers[i].forward();
        });
      }

      // Auto hide after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isShowing = false);
        for (var c in _controllers) {
          c.dispose();
        }
        _controllers.clear();
      });
    } else {
      for (var c in _controllers) {
        c.dispose();
      }
      _controllers.clear();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _toggleEmojiBubble,
          child: Icon(
            Icons.message,
            color: Colors.orangeAccent,
            size: 28,
          ),
        ),

        if (_isShowing)
          Positioned(
            bottom: 50, // height above the avatar/message icon
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
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
                  final emojiFile = _funnyLotties[index]["file"]!;
                  final soundFile = _funnyLotties[index]["sound"]!;
                  return GestureDetector(
                    onTap: () {
                      widget.onSelected(emojiFile);
                      audioManager.playSfx(soundFile);
                      // hide after selection
                      setState(() => _isShowing = false);
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
                          child: Lottie.asset(emojiFile, repeat: true),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }
}
