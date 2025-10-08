import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hezzstar/IndexPages/HomePage/HomePage.dart';
import 'package:provider/provider.dart';
import '../../ExperieneManager.dart';
import '../../widgets/userStatut/globalKeyUserStatusBar.dart';
import 'FlyingRewardWidget.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';

enum RewardType { gold, gem, star }

class FlyingRewardManager {
  static final FlyingRewardManager _instance = FlyingRewardManager._internal();
  factory FlyingRewardManager() => _instance;
  FlyingRewardManager._internal();

  late OverlayState _overlayState;

  final Map<RewardType, String> _soundAssets = {
    RewardType.gold: 'assets/audios/UI/SFX/Gamification_SFX/MuchCoinsSound.mp3',
    RewardType.gem: 'assets/audios/UI/SFX/Gamification_SFX/WinningGold_Sound.mp3',
    RewardType.star: 'assets/audios/UI/SFX/Gamification_SFX/xp_Sound.mp3',
  };

  void init(BuildContext context) {
    _overlayState = Overlay.of(context);
  }

  void spawnReward({
    required BuildContext context,
    required Offset start,
    required GlobalKey endKey,
    required int amount,
    RewardType type = RewardType.gold,
  }) {
    if (_overlayState == null) _overlayState = Overlay.of(context)!;

    int numIcons = _getNumIconsForReward(type, amount);
    List<int> amounts = _splitAmount(amount, numIcons);

    final audioManager = Provider.of<AudioManager>(context, listen: false);
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);

    // ✅ Give full reward immediately (logic safe)
    switch (type) {
      case RewardType.gold:
        xpManager.addGold(amount);
        break;
      case RewardType.gem:
        xpManager.addGems(amount);
        break;
      case RewardType.star:
        xpManager.addExperience(amount,context: context,gemsKey: gemsKey);
        break;
    }

    // 🎵 Play sounds
    if (type == RewardType.gold) {
      audioManager.playSfxLoop(_soundAssets[type]!);
    } else {
      _playSound(context, type);
    }

    // ✨ Spawn purely cosmetic animations
    for (int i = 0; i < numIcons; i++) {
      Future.delayed(Duration(milliseconds: i * _getSpawnDelay(type)), () {
        OverlayEntry? entry;
        entry = OverlayEntry(
          builder: (context) => FlyingRewardWidget(
            startOffset: start,
            endKey: endKey,
            amount: amounts[i],
            type: type,
            onCompleted: () {
              entry?.remove();

              // Stop looping gold sound after last coin
              if (type == RewardType.gold && i == numIcons - 1) {
                audioManager.stopSfxLoop();
              }
            },
          ),
        );

        _overlayState.insert(entry);
      });
    }
  }


  int _getSpawnDelay(RewardType type) {
    switch (type) {
      case RewardType.gold:
        return 80;
      case RewardType.gem:
        return 120;
      case RewardType.star:
        return 100;
    }
  }

  int _getNumIconsForReward(RewardType type, int amount) {
    switch (type) {
      case RewardType.gold:
        if (amount < 10) return 3;
        if (amount < 100) return 6;
        if (amount < 1000) return 12;
        return 20;
      case RewardType.gem:
        if (amount < 5) return 1;
        if (amount < 20) return 3;
        if (amount < 100) return 5;
        return 8;
      case RewardType.star:
        if (amount < 50) return 4;
        if (amount < 200) return 8;
        if (amount < 1000) return 12;
        return 15;
    }
  }

  List<int> _splitAmount(int total, int parts) {
    List<int> result = List.filled(parts, total ~/ parts);
    int remainder = total % parts;
    for (int i = 0; i < remainder; i++) {
      result[i] += 1;
    }
    return result;
  }

  void _playSound(BuildContext context, RewardType type) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    final asset = _soundAssets[type]!;
    audioManager.playSfx(asset);
  }

  void preloadSounds(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    for (var asset in _soundAssets.values) {
      // Optional: preload if AudioManager supports it
      // audioManager.preloadSfx(asset);
    }
  }
}
