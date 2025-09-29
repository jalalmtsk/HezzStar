import 'package:flutter/material.dart';

import '../../../Models/Deck.dart';
import '../../../Tools/TextUI/CardReamingTextUi.dart';
import '../../../Tools/TextUI/MinimalBageText.dart';

class DeckCenterPanel extends StatelessWidget {
  final double top;
  final double left;
  final double right;
  final Function() onDraw;
  final dynamic deck; // deck object (with .cards and .isEmpty)
  final dynamic topCard; // top card (with .assetName)
  final List<dynamic> discard; // discard pile
  final GlobalKey deckKey;
  final GlobalKey centerKey;

  const DeckCenterPanel({
    super.key,
    required this.top,
    required this.left,
    required this.right,
    required this.onDraw,
    required this.deck,
    required this.topCard,
    required this.discard,
    required this.deckKey,
    required this.centerKey,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Draw Pile
              GestureDetector(
                onTap: onDraw,
                child: Column(
                  children: [
                    MinimalBadgeText(label: "Draw Pile", fontSize: 14),
                    const SizedBox(height: 4),
                    SizedBox(
                      key: deckKey,
                      width: 70,
                      height: 110,
                      child: deck.isEmpty
                          ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white70,
                        ),
                        child: const Center(child: Text('Empty')),
                      )
                          : Image.asset(deck.cards.last.backAsset(context),
                          fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 4),
                    CardCountBadge(remaining: deck.length),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Top Card
              Column(
                children: [
                  MinimalBadgeText(label: "Top Card"),
                  const SizedBox(height: 4),
                  SizedBox(
                    key: centerKey,
                    width: 70,
                    height: 110,
                    child: topCard == null
                        ? Container()
                        : Image.asset(topCard.assetName, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 4),
                  CardCountBadge(remaining: discard.length),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

