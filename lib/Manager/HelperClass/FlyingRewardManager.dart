import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ExperieneManager.dart';
import 'FlyingRewardWidget.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';

enum RewardType { gold, gem, star }

class FlyingRewardManager {
  static final FlyingRewardManager _instance = FlyingRewardManager._internal();
  factory FlyingRewardManager() => _instance;
  FlyingRewardManager._internal();

  late OverlayState _overlayState;
  void init(BuildContext context) {
    _overlayState = Overlay.of(context)!;
  }

  void spawnReward({
    required BuildContext context,
    required Offset start,
    required GlobalKey endKey,
    required int amount,
    RewardType type = RewardType.gold,
  }) {
    if (_overlayState == null) _overlayState = Overlay.of(context)!;

    // Decide number of icons based on reward type + amount
    int numIcons = _getNumIconsForReward(type, amount);

    // Split amount per icon (ensures sum == total)
    List<int> amounts = _splitAmount(amount, numIcons);

    for (int i = 0; i < numIcons; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        OverlayEntry? entry;
        entry = OverlayEntry(
          builder: (context) => FlyingRewardWidget(
            startOffset: start,
            endKey: endKey,
            amount: amounts[i],
            type: type,
            onCompleted: () {
              entry?.remove();
            },
          ),
        );

        _overlayState.insert(entry);

        // Play sound
        _playSound(type);

        // Update ExperienceManager when each icon completes
        final xpManager = Provider.of<ExperienceManager>(context, listen: false);
        switch (type) {
          case RewardType.gold:
            xpManager.addGold(amounts[i]);
            break;
          case RewardType.gem:
            xpManager.addGems(amounts[i]);
            break;
          case RewardType.star:
            xpManager.addExperience(amounts[i]);
            break;
        }
      });
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

  void _playSound(RewardType type) {
    String asset;
    switch (type) {
      case RewardType.gold:
        asset = 'assets/sounds/gold.wav';
        break;
      case RewardType.gem:
        asset = 'assets/sounds/gem.wav';
        break;
      case RewardType.star:
        asset = 'assets/sounds/star.wav';
        break;
    }

    // Uncomment once AudioManager is set up
    // final audioManager = Provider.of<AudioManager>(context, listen: false);
    // audioManager.playSfx(asset);
  }
}
