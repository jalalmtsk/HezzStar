import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../ExperieneManager.dart';
import 'BotPlayerInfoDialog.dart';

class PlayerSelector {
  final BuildContext context;
  final int botCount;
  final List<bool> eliminatedPlayers;
  final Function(int) onPlayerSelected;
  bool isAnimating = false;

  PlayerSelector({
    required this.context,
    required this.botCount,
    required this.eliminatedPlayers,
    required this.onPlayerSelected,
  });

  Future<void> animateSelection() async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final audioManager = Provider.of<AudioManager>(context, listen: false);

    audioManager.playSfx("assets/audios/UI/SFX/Gamification_SFX/PlayerSelectionSound.mp3");

    isAnimating = true;
    final activePlayers = List.generate(botCount + 1, (i) => i)
        .where((i) => !eliminatedPlayers[i])
        .toList();

    if (activePlayers.isEmpty) return;

    OverlayEntry? entry;
    int currentIndex = 0;
    final random = Random();

    // 🚀 Cycling overlay for suspense
    Timer? timer;
    timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (entry != null) entry!.remove();

      final p = activePlayers[currentIndex % activePlayers.length];
      final xpManager = Provider.of<ExperienceManager>(context, listen: false);
      final isYou = p == 0;
      final name = isYou ? xpManager.username : BotDetailsPopup.getBotInfo(p).name;
      final avatar = isYou ? xpManager.selectedAvatar : BotDetailsPopup.getBotInfo(p).avatarPath;

      entry = OverlayEntry(
        builder: (_) => _buildAnimatedOverlay(name, avatar!),
      );

      overlay.insert(entry!);
      currentIndex++;
    });

    await Future.delayed(Duration(milliseconds: 1500 + random.nextInt(1500)));
    timer.cancel();
    if (entry != null) entry!.remove();

    // 🎯 Final selected player
    final p = activePlayers[random.nextInt(activePlayers.length)];
    onPlayerSelected(p);


    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    final isYou = p == 0;
    final finalName = isYou ? xpManager.username : BotDetailsPopup.getBotInfo(p).name;
    final finalAvatar = isYou ? xpManager.selectedAvatar : BotDetailsPopup.getBotInfo(p).avatarPath;

    entry = OverlayEntry(
      builder: (_) => _buildProFinalReveal(finalName, finalAvatar!),
    );

    overlay.insert(entry!);
    await Future.delayed(const Duration(milliseconds: 2200));
    entry?.remove();
    isAnimating = false;
  }

  // Minimalist cycling overlay
  Widget _buildAnimatedOverlay(String name, String avatarPath) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: AnimatedScale(
            scale: 1.05,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundImage: AssetImage(avatarPath),
                  backgroundColor: Colors.grey[900],
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none, // ✅ remove underline
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Pro-level final reveal
  Widget _buildProFinalReveal(String name, String avatarPath) {
    return Positioned.fill(
      child: Stack(
        children: [
          // 🌫 Background blur with dark overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),

          // Center avatar + Lottie behind
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 🎉 Lottie animation behind avatar
                    SizedBox(
                      width: 380,
                      height: 380,
                      child: Lottie.asset(
                        "assets/animations/AnimationSFX/Boom.json",
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // 🔵 Floating neon rings
                    for (int i = 0; i < 3; i++)
                      AnimatedContainer(
                        duration: Duration(milliseconds: 800 + i * 200),
                        width: 130.0 + i * 15,
                        height: 130.0 + i * 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amberAccent.withOpacity(0.3 + i * 0.2),
                            width: 3,
                          ),
                        ),
                      ),

                    // 🟡 Avatar bounce
                    AnimatedScale(
                      scale: 1.25,
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(avatarPath),
                        backgroundColor: Colors.grey[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ✨ Glowing name
                Text(
                  "$name Selected!",

                  style: TextStyle(
                    decoration: TextDecoration.none, // ✅ remove underline
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.amberAccent,
                    shadows: [
                      Shadow(
                        color: Colors.amberAccent.withOpacity(0.7),
                        blurRadius: 12,
                        offset: const Offset(0, 0),
                      ),
                      Shadow(
                        color: Colors.deepOrange.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
