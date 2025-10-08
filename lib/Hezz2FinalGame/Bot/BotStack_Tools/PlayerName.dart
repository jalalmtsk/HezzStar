import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class PlayerName extends StatelessWidget {
  final String name;
  final double maxWidth;

  const PlayerName({required this.name, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
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
          text: name,
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
          name,
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
