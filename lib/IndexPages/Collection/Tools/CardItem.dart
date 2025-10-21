import 'package:flutter/material.dart';
import 'package:hezzstar/main.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../tools/AudioManager/AudioManager.dart';
import 'CurrencyTypeEnum.dart';

class CardItemWidget extends StatelessWidget {
  final String imagePath;
  final int cost;
  final CurrencyType currencyType;
  final bool unlocked;
  final bool selected;
  final int userGold;
  final int userGems;
  final VoidCallback onSelect;
  final VoidCallback onBuy;

  const CardItemWidget({
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

    bool canBuy;
    if (currencyType == CurrencyType.gold) {
      canBuy = !unlocked && (userGold >= cost);
    } else {
      canBuy = !unlocked && (userGems >= cost);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double imageWidth = width * 0.7; // image scales with container width
        double imageHeight = imageWidth * 1.5; // maintain aspect ratio
        double badgeFontSize = width < 200 ? 10 : 14;
        double costFontSize = width < 200 ? 14 : 18;
        double currencyIconSize = width < 200 ? 20 : 28;

        return GestureDetector(
          onTap: () {
            if (unlocked) {
              audioManager.playEventSound("sandClick");
              onSelect();
            } else if (canBuy) {
              audioManager.playEventSound("sandClick");
              onBuy();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${tr(context).notEnough} ${currencyType == CurrencyType.gold ? "gold" : "gems"}!"),
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
                if (selected)
                  Positioned(
                    top: imageHeight * 0.97,
                    right: 8,
                    left: 8,
                    child: _badge(tr(context).selected, Colors.green, badgeFontSize),
                  )
                else if (unlocked)
                  Positioned(
                    top: imageHeight * 0.97,
                    right: 8,
                    left: 8,
                    child: _badge(tr(context).unlocked, Colors.orange, badgeFontSize),
                  ),
                if (!unlocked)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                            SizedBox(width: 2),
                            Image.asset(
                              currencyType == CurrencyType.gold
                                  ? "assets/UI/Icons/Gamification/GoldInGame_Icon.png"
                                  : "assets/UI/Icons/Gamification/Gems_Icon.png",
                              width: currencyIconSize * 1.3,
                              height: currencyIconSize * 1.3,
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
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.7), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        textAlign: TextAlign.center,
        text.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: fontSize),
      ),
    );
  }
}
