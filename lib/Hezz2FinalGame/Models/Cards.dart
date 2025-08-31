import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ExperieneManager.dart';

class PlayingCard {
  final String suit;
  final int rank;
  final String id;

  PlayingCard({required this.suit, required this.rank}) : id = UniqueKey().toString();

  String get assetName => 'assets/images/cards/${suit.toLowerCase()}_${rank.toString()}.png';

  /// Returns the currently selected back card from ExperienceManager
  String backAsset(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    return xpManager.selectedCard ?? 'assets/images/cards/backCard.png';
  }

  String get label => '$rank of $suit';
}
