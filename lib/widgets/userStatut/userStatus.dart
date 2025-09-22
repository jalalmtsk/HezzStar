import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ExperieneManager.dart';

class UserStatusBar extends StatelessWidget {
  const UserStatusBar({super.key});

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
    return Consumer<ExperienceManager>(
      builder: (context, xpManager, child) {
        double xpProgress = xpManager.currentLevelXP / xpManager.requiredXPForNextLevel;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Adjust icon and font sizes based on available width
            double screenWidth = constraints.maxWidth;
            double iconSize = screenWidth < 400 ? 50 : 70;
            double fontSize = screenWidth < 400 ? 14 : 18;
            double padding = screenWidth < 400 ? 8 : 12;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _horizontalStat(
                  iconPath: 'assets/UI/Icons/Gamification/LevelXpHolder_Icon.png',
                  level: xpManager.level,
                  value:
                  "${formatNumber(xpManager.currentLevelXP)} / ${formatNumber(xpManager.requiredXPForNextLevel)}",
                  iconSize: iconSize,
                  fontSize: fontSize,
                  padding: padding,
                ),
                _horizontalStat(
                  iconPath: 'assets/UI/Icons/Gamification/Gold_Icon.png',
                  value: formatNumber(xpManager.gold),
                  iconSize: iconSize,
                  fontSize: fontSize,
                  padding: padding,
                ),
                _horizontalStat(
                  iconPath: 'assets/UI/Icons/Gamification/Gems_Icon.png',
                  value: formatNumber(xpManager.gems),
                  iconSize: iconSize,
                  fontSize: fontSize,
                  padding: padding,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _horizontalStat({
    required String iconPath,
    int? level,
    required String value,
    double iconSize = 60,
    double fontSize = 16,
    double padding = 8,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        // Text container
        Padding(
          padding: EdgeInsets.all(padding),
          child: Container(
            margin: EdgeInsets.only(left: iconSize * 0.7),
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Icon
        Positioned(
          left: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
              if (level != null)
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  maxRadius: iconSize * 0.23,
                  child: Text(
                    "$level",
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: fontSize * 0.75,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
