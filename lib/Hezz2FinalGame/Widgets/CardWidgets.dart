import 'package:flutter/material.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/Cards.dart';
import 'package:provider/provider.dart';

class CardWidget extends StatelessWidget {
  final PlayingCard card;
  final bool isFaceUp;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const CardWidget({
    required this.card,
    this.isFaceUp = true,
    this.onTap,
    this.width = 70,
    this.height = 110,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get the dynamic back card from ExperienceManager
    final backAsset = card.backAsset(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          isFaceUp ? card.assetName : backAsset,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
