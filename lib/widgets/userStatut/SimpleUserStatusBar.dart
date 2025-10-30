import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:provider/provider.dart';
import '../../MainScreenIndex.dart';

class SimpleUserStatusBar extends StatelessWidget {
  final bool showGold;
  final bool showGems;
  final bool showPlusButton;

  const SimpleUserStatusBar({
    super.key,
    this.showGold = true,
    this.showGems = true,
    this.showPlusButton = true,
  });

  String formatNumber(int number) {
    if (number >= 1000000) {
      double result = number / 1000000;
      return result % 1 == 0 ? "${result.toInt()}M" : "${result.toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      double result = number / 1000;
      return result % 1 == 0 ? "${result.toInt()}K" : "${result.toStringAsFixed(1)}K";
    } else {
      return number.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.12;
    final fontSize = screenWidth * 0.035;
    final padding = screenWidth * 0.01;

    return Consumer<ExperienceManager>(
      builder: (context, xpManager, child) {
        List<Widget> stats = [];

        if (showGold) {
          stats.add(_statItem(
            iconPath: 'assets/UI/Icons/Gamification/Gold_Icon.png',
            value: formatNumber(xpManager.gold),
            iconSize: iconSize,
            fontSize: fontSize,
            padding: padding,
            showPlus: showPlusButton,
          ));
        }

        if (showGems) {
          stats.add(_statItem(
            iconPath: 'assets/UI/Icons/Gamification/Gems_Icon.png',
            value: formatNumber(xpManager.gems),
            iconSize: iconSize,
            fontSize: fontSize,
            padding: padding,
            showPlus: showPlusButton,
          ));
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: stats,
        );
      },
    );
  }

  Widget _statItem({
    required String iconPath,
    required String value,
    double iconSize = 70,
    double fontSize = 20,
    double padding = 8,
    bool showPlus = false,
    VoidCallback? onPlusTap,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
