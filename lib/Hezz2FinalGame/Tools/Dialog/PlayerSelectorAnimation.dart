import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ExperieneManager.dart';
import 'BotPlayerInfoDialog.dart';

class PlayerSelector {
  final BuildContext context;
  final int botCount;
  final List<bool> eliminatedPlayers;
  final Function(int) onPlayerSelected; // callback to set current player
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

    isAnimating = true;

    // Active players include you (0) and bots (1..botCount)
    final activePlayers = List.generate(botCount + 1, (i) => i)
        .where((i) => !eliminatedPlayers[i])
        .toList();

    if (activePlayers.isEmpty) return;

    OverlayEntry? entry;
    int currentIndex = 0;
    final random = Random();

    Timer? timer;
    timer = Timer.periodic(const Duration(milliseconds: 150), (t) {
      if (entry != null) entry!.remove();

      final p = activePlayers[currentIndex % activePlayers.length];
      final xpManager = Provider.of<ExperienceManager>(context, listen: false);
      final isYou = p == 0;
      final name = isYou ? xpManager.username : BotDetailsPopup.getBotInfo(p).name;
      final avatar = isYou ? xpManager.selectedAvatar : BotDetailsPopup.getBotInfo(p).avatarPath;

      entry = OverlayEntry(
        builder: (_) => _buildOverlay(name, avatar!, Colors.deepPurple.withOpacity(0.9)),
      );

      overlay.insert(entry!);
      currentIndex++;
    });

    // Shuffle for random duration
    await Future.delayed(Duration(milliseconds: 1500 + random.nextInt(1500)));

    // Stop timer and pick final player
    timer.cancel();
    if (entry != null) entry?.remove();

    final p = activePlayers[random.nextInt(activePlayers.length)];
    onPlayerSelected(p); // notify parent

    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    final isYou = p == 0;
    final finalName = isYou ? xpManager.username : BotDetailsPopup.getBotInfo(p).name;
    final finalAvatar = isYou ? xpManager.selectedAvatar : BotDetailsPopup.getBotInfo(p).avatarPath;

    entry = OverlayEntry(
      builder: (_) => _buildOverlay(finalName, finalAvatar!, Colors.greenAccent.withOpacity(0.9)),
    );

    overlay.insert(entry!);
    await Future.delayed(const Duration(milliseconds: 1000));
    entry?.remove();
    isAnimating = false;
  }

  Widget _buildOverlay(String name, String avatarPath, Color color) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      top: size.height * 0.4,
      left: size.width * 0.3,
      right: size.width * 0.3,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(avatarPath),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
