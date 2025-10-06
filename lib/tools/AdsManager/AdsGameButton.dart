import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../Manager/HelperClass/FlyingRewardManager.dart';
import '../../Manager/HelperClass/RewardDimScreen.dart';
import '../AudioManager/AudioManager.dart';
import 'AdsManager.dart';
import '../../ExperieneManager.dart';

class AdsGameCard extends StatelessWidget {
  final String text;
  final String sparkleAsset; // ✨ Sparkles animation
  final String boxAsset; // 📦 Box/button animation
  final int rewardAmount;
  final GlobalKey gemsKey;
  final String? backgroundImage; // 🌄 Optional background

  const AdsGameCard({
    super.key,
    required this.text,
    required this.sparkleAsset,
    required this.boxAsset,
    required this.gemsKey,
    this.rewardAmount = 1,
    this.backgroundImage,
  });

  void _handleAdReward(BuildContext context) async {
    bool earned = await AdHelper.showRewardedAd(context);
    if (earned) {
      RewardDimScreen.show(
        context,
        start: const Offset(200, 400),
        endKey: gemsKey,
        amount: rewardAmount,
        type: RewardType.gem,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎉 You earned $rewardAmount Gem${rewardAmount > 1 ? 's' : ''}!",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No reward earned.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    return GestureDetector(
      onTap: () {
        audioManager.playEventSound("sandClick");
        _handleAdReward(context);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: backgroundImage != null
              ? DecorationImage(
            image: AssetImage(backgroundImage!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), BlendMode.darken),
          )
              : null,
          gradient: backgroundImage == null
              ? const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎬 Animated Lottie stack
            Stack(
              alignment: Alignment.center,
              children: [
                Lottie.asset(
                  sparkleAsset,
                  width: 70,
                  height: 70,
                  repeat: true,
                  animate: true,
                ),
                Lottie.asset(
                  boxAsset,
                  width: 65,
                  height: 65,
                  repeat: true,
                  animate: true,
                ),
              ],
            ),
            // 📝 Card text
          ],
        ),
      ),
    );
  }
}
