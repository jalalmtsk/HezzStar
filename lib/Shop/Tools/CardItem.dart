import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../tools/AudioManager/AudioManager.dart';


class CardItemWidget extends StatelessWidget {
  final String imagePath;
  final int cost;
  final bool unlocked;
  final bool selected;
  final int userGold;
  final VoidCallback onSelect;
  final VoidCallback onBuy;

  const CardItemWidget({
    super.key,
    required this.imagePath,
    required this.cost,
    required this.unlocked,
    required this.selected,
    required this.userGold,
    required this.onSelect,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    final canBuy = !unlocked && (userGold >= cost);

    return GestureDetector(
      onTap: () {
        if (unlocked) {
          audioManager.playEventSound("clickButton2");
          onSelect();
        } else if (canBuy) {
          audioManager.playEventSound("PopButton");
          onBuy();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Not enough gold!"),
              behavior: SnackBarBehavior.floating,
            ),
          );
          audioManager.playEventSound("invalid");
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: unlocked ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.green : unlocked ? Colors.orange : Colors.grey.shade400,
            width: selected ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? Colors.greenAccent.withOpacity(0.6) : Colors.black26,
              blurRadius: selected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(imagePath, width: 120, height: 150, fit: BoxFit.cover),
              ),
            ),
            if (selected)
              Positioned(top: 8, right: 8, child: _badge("Selected", Colors.green))
            else if (unlocked)
              Positioned(top: 8, right: 8, child: _badge("Unlocked", Colors.orange)),
            if (!unlocked)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Shimmer.fromColors(
                    baseColor: Colors.deepOrange,
                    highlightColor: Colors.yellow,
                    child: Text(
                      '$cost 💰',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withOpacity(0.7), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Text(text.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10)),
    );
  }
}
