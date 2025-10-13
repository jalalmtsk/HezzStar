import 'package:flutter/material.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';

import '../../../Hezz2FinalGame/Models/Cards.dart';
import '../endGameScreen.dart';
import 'EliminationEndScreen.dart';
import 'PlayTowinScreen.dart';

class EndGameRouter extends StatelessWidget {
  final List<List<PlayingCard>> hands;
  final int winnerIndex;
  final GameModeType gameModeType;
  final int currentRound;
  final int betAmount;
  final String winnerName;
  final String winnerAvatar;

  const EndGameRouter({
    super.key,
    required this.hands,
    required this.winnerIndex,
    required this.gameModeType,
    required this.currentRound,
    required this.betAmount,
    required this.winnerName,
    required this.winnerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    switch (gameModeType) {
      case GameModeType.elimination:
        return EliminationEndPage(
          hands: hands,
          winnerIndex: winnerIndex,
          currentRound: currentRound,
          betAmount: betAmount,
          winnerName: winnerName,
          winnerAvatar: winnerAvatar,
        );

      case GameModeType.playToWin:
        return PlayToWinEndPage(
          hands: hands,
          winnerIndex: winnerIndex,
          currentRound: currentRound,
          betAmount: betAmount,
          winnerName: winnerName,
          winnerAvatar: winnerAvatar,
        );

      default:
      // Fallback (just in case)
        return EndGameScreen(
          hands: hands,
          winnerIndex: winnerIndex,
          gameModeType: gameModeType,
          currentRound: currentRound,
          betAmount: betAmount,
          winnerName: winnerName,
          winnerAvatar: winnerAvatar, rewardMessage: '',
          playerScores: [],
        );
    }
  }
}
