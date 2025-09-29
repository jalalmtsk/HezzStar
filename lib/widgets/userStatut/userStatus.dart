import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:provider/provider.dart';

class UserStatusBar extends StatelessWidget {
  final GlobalKey goldKey;
  final GlobalKey gemsKey;
  final GlobalKey xpKey;

  // Optional parameters to show/hide each element
  final bool showXP;
  final bool showGold;
  final bool showGems;

  const UserStatusBar({
    super.key,
    required this.goldKey,
    required this.gemsKey,
    required this.xpKey,
    this.showXP = true,
    this.showGold = true,
    this.showGems = true,
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
    final fontSize = screenWidth * 0.045;
    final padding = screenWidth * 0.02;

    return Consumer<ExperienceManager>(
      builder: (context, xpManager, child) {
        List<Widget> stats = [];

        if (showXP) {
          stats.add(_horizontalStat(
            iconPath: 'assets/UI/Icons/Gamification/LevelXpHolder_Icon.png',
            level: xpManager.level,
            value: "${formatNumber(xpManager.currentLevelXP)} / ${formatNumber(xpManager.requiredXPForNextLevel)}",
            keyForIcon: xpKey,
            iconSize: iconSize,
            fontSize: fontSize,
            padding: padding,
          ));
        }
        if (showGold) {
          stats.add(_horizontalStat(
            iconPath: 'assets/UI/Icons/Gamification/Gold_Icon.png',
            value: formatNumber(xpManager.gold),
            keyForIcon: goldKey,
            iconSize: iconSize,
            fontSize: fontSize,
            padding: padding,
          ));
        }
        if (showGems) {
          stats.add(_horizontalStat(
            iconPath: 'assets/UI/Icons/Gamification/Gems_Icon.png',
            value: formatNumber(xpManager.gems),
            keyForIcon: gemsKey,
            iconSize: iconSize,
            fontSize: fontSize,
            padding: padding,
          ));
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: stats,
        );
      },
    );
  }

  Widget _horizontalStat({
    required String iconPath,
    int? level,
    required String value,
    double iconSize = 70,
    double fontSize = 22,
    double padding = 10,
    GlobalKey? keyForIcon,
  }) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: Container(
                  margin: EdgeInsets.only(left: iconSize * 0.6),
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth - iconSize),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
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
                ),
              ),
              Positioned(
                left: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      iconPath,
                      key: keyForIcon,
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                    ),
                    if (level != null)
                      CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        maxRadius: iconSize * 0.22,
                        child: FittedBox(
                          child: Text(
                            "$level",
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: fontSize * 0.77,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
