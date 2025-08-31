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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statusIcon(
              iconPath: 'assets/UI/modes/gelms.jpg',
              valueText: "${formatNumber(xpManager.currentLevelXP)} / ${formatNumber(xpManager.requiredXPForNextLevel)}",
            ),
            _statusIcon(
              iconPath: 'assets/UI/modes/gold.jpg',
              valueText: formatNumber(xpManager.gold),
            ),
            _statusIcon(
              iconPath: 'assets/UI/modes/gemUcin2.jpg',
              valueText: "${formatNumber(xpManager.gems)}",
            ),
          ],
        );
      },
    );
  }

  Widget _statusIcon({
    required String iconPath,
    required String valueText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: 45,
              width: 45,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  iconPath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  alignment: Alignment(0, 0),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            valueText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
