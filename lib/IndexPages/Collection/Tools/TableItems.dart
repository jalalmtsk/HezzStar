import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../tools/AudioManager/AudioManager.dart';
import 'CurrencyTypeEnum.dart';

class TableSkinItemWidget extends StatelessWidget {
  final String imagePath;
  final int cost;
  final CurrencyType currencyType;
  final bool unlocked;
  final bool selected;
  final int userGold;
  final int userGems;
  final VoidCallback onSelect;
  final VoidCallback onBuy;

  const TableSkinItemWidget({
    super.key,
    required this.imagePath,
    required this.cost,
    required this.currencyType,
    required this.unlocked,
    required this.selected,
    required this.userGold,
    required this.userGems,
    required this.onSelect,
    required this.onBuy,
  });

  String _formatCost(int number) {
    if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(number % 1000000 == 0 ? 0 : 1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K";
    } else {
      return number.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    bool canBuy = !unlocked &&
        ((currencyType == CurrencyType.gold && userGold >= cost) ||
            (currencyType == CurrencyType.gems && userGems >= cost));

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double imageWidth = width * 1.0;
        double imageHeight = imageWidth * 0.55;
        double badgeFontSize = width < 250 ? 12 : 16;
        double costFontSize = width < 250 ? 14 : 18;
        double currencyIconSize = width < 250 ? 20 : 28;

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
                SnackBar(
                  content: Text(
                      "Not enough ${currencyType == CurrencyType.gold ? "gold" : "gems"}!"),
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
                    child: Image.asset(
                      imagePath,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Top-right badge for unlocked/selected
                if (selected)
                  Positioned(
                    top: 8,
                    right: 12,
                    child: _badge("Selected", Colors.green, badgeFontSize),
                  )
                else if (unlocked)
                  Positioned(
                    top: 8,
                    right: 12,
                    child: _badge("Unlocked", Colors.orange, badgeFontSize),
                  ),
                // Bottom-center cost
                if (!unlocked)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Shimmer.fromColors(
                              baseColor: currencyType == CurrencyType.gold
                                  ? Colors.deepOrange
                                  : Colors.lightGreenAccent,
                              highlightColor: currencyType == CurrencyType.gold
                                  ? Colors.yellow
                                  : Colors.cyan,
                              child: Text(
                                _formatCost(cost),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: costFontSize,
                                  color: Colors.white,
                                  shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Image.asset(
                              currencyType == CurrencyType.gold
                                  ? "assets/UI/Icons/Gamification/GoldInGame_Icon.png"
                                  : "assets/UI/Icons/Gamification/Gems_Icon.png",
                              width: currencyIconSize,
                              height: currencyIconSize,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _badge(String text, Color color, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.7), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: fontSize),
      ),
    );
  }
}
