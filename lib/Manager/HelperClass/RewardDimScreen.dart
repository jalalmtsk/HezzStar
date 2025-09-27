import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'FlyingRewardManager.dart';

class RewardDimScreen {
  /// Shows a full-screen dimmed overlay with animated image + amount + confetti + glowing aura.
  static void show(
      BuildContext context, {
        required Offset start,
        required GlobalKey endKey,
        required int amount,
        required RewardType type,
      }) {
    // Choose image asset based on reward type
    String assetPath;
    String label;
    Color glowColor;
    String auraLottie;

    switch (type) {
      case RewardType.gold:
        assetPath = "assets/UI/Icons/Gamification/GoldInGame_Icon.png";
        label = "Gold";
        glowColor = Colors.amberAccent;
        auraLottie = "assets/animations/AnimationSFX/RewawrdLightEffect.json";
        break;
      case RewardType.gem:
        assetPath = "assets/UI/Icons/Gamification/Gems_Icon.png";
        label = "Gems";
        glowColor = Colors.greenAccent;
        auraLottie = "assets/animations/AnimationSFX/RewawrdLightEffect.json";
        break;
      case RewardType.star:
        assetPath = "assets/UI/Icons/Gamification/Xp_Icon.png";
        label = "XP";
        glowColor = Colors.yellowAccent;
        auraLottie = "assets/animations/AnimationSFX/RewawrdLightEffect.json";
        break;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75), // immersive dim
      barrierDismissible: false,
      builder: (_) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FlyingRewardManager().spawnReward(
              start: start,
              endKey: endKey,
              amount: amount,
              type: type,
              context: context,
            );
            Navigator.of(context).pop();
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background confetti celebration (fills screen)
              Positioned.fill(
                child: IgnorePointer(
                  child: Lottie.asset(
                    'assets/animations/Win/Confetti4.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                ),
              ),

              // Top confetti burst
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Lottie.asset(
                    'assets/animations/Win/Confetti2.json',
                    height: 200,
                    fit: BoxFit.contain,
                    repeat: false,
                  ),
                ),
              ),

              // Center popup with scale animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            glowColor.withOpacity(0.15),
                            Colors.white,
                            glowColor.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: glowColor.withOpacity(0.6),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(0.7),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Glossy overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.35),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Reward icon + centered aura
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Aura Lottie always centered
                                  Lottie.asset(
                                    auraLottie,
                                    height: 180,
                                    repeat: true,
                                    fit: BoxFit.contain,
                                  ),

                                  // Glow pulse
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          glowColor.withOpacity(0.5),
                                          Colors.transparent,
                                        ],
                                        radius: 0.8,
                                      ),
                                    ),
                                  ),

                                  // Reward icon
                                  Image.asset(
                                    assetPath,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Reward label
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: glowColor,
                                  shadows: [
                                    Shadow(
                                      color: glowColor.withOpacity(0.8),
                                      blurRadius: 12,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Reward amount
                              Text(
                                '+$amount',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: Offset(2, 2),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Hint text
                              Text(
                                'Tap anywhere to collect',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
