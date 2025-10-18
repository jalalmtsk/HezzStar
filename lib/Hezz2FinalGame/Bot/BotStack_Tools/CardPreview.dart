import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../main.dart';

class CardPreview extends StatelessWidget {
  final List<dynamic> hand;
  final bool vertical;
  final double scale;
  final bool isEliminated;
  final bool isQualified;
  final bool showQualificationLottie; // ✅ Add this

  const CardPreview({
    required this.hand,
    required this.vertical,
    this.scale = 1.0,
    this.isEliminated = false,
    this.isQualified = false,
    this.showQualificationLottie = false, // ✅ Default to false
  });

  @override
  Widget build(BuildContext context) {
    double cardWidth = (vertical ? 38 : 45) * scale;
    double cardHeight = (vertical ? 54 : 60) * scale;

    return SizedBox(
      width: cardWidth + 10,
      height: cardHeight,
      child: Stack(
        children: [
          for (int i = 0; i < hand.length && i < 3; i++)
            Positioned(
              left: i * 6,
              top: i * 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        )
                      ],
                    ),
                    child: Image.asset(
                      hand.isNotEmpty ? hand.first.backAsset(context) : 'assets/images/cards/backCard.png',
                      width: cardWidth,
                      height: cardHeight,
                      fit: BoxFit.cover,
                      color: (isEliminated || isQualified) ? Colors.grey.withOpacity(0.6) : null,
                      colorBlendMode: BlendMode.saturation,
                    ),
                  ),

                  if (isEliminated)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.red.withOpacity(0.4),
                        child:  Text(
                          tr(context).eliminated,
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  if (isQualified)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.blue.withOpacity(0.4),
                        child:  Text(
                          tr(context).qualified,
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
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
