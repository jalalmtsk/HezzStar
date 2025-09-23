import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'AdsManager.dart';
import '../../ExperieneManager.dart';

class AdsGameButton extends StatelessWidget {
  final String text;
  final String sparkleAsset; // ✨ Sparkles animation
  final String boxAsset; // 📦 Box/button animation
  final int rewardAmount;

  const AdsGameButton({
    super.key,
    required this.text,
    required this.sparkleAsset,
    required this.boxAsset,
    this.rewardAmount = 1,
  });

  void _handleAdReward(BuildContext context) async {
    bool earned = await AdHelper.showRewardedAd(context);
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    if (earned) {
      xpManager.addGems(rewardAmount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎉 You earned $rewardAmount Gem${rewardAmount > 1 ? 's' : ''}!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No reward earned.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleAdReward(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // ✨ Sparkle animation behind
              Lottie.asset(
                sparkleAsset,
                width: 120,
                height: 120,
                repeat: true,
                animate: true,
              ),

              // 📦 Box/button animation in front
              Lottie.asset(
                boxAsset,
                width: 100,
                height: 100,
                repeat: true,
                animate: true,
              ),
            ],
          ),
          // 📝 Text under the lottie
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
              shadows: [
                Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
