import 'package:flutter/material.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:marquee/marquee.dart';

import '../../../main.dart';

class PlayerName extends StatelessWidget {
  final String name;
  final double maxWidth;
  final GameMode mode;

  const PlayerName({required this.name, required this.maxWidth, required this.mode});

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: GameMode == GameMode.online ? name : tr(context).bot,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))],
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final isOverflow = textPainter.width > maxWidth;

    if (isOverflow) {
      return SizedBox(
        width: maxWidth,
        height: 16,
        child: Marquee(
          text: GameMode == GameMode.online ? name : tr(context).bot,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))],
          ),
          scrollAxis: Axis.horizontal,
          blankSpace: 20,
          velocity: 25,
          pauseAfterRound: const Duration(seconds: 5),
        ),
      );
    } else {
      return SizedBox(
        width: maxWidth,
        height: 16,
        child: Text(
          mode == GameMode.online ? name : tr(context).bot,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))],
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
