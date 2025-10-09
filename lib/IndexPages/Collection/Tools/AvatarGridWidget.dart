import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../ExperieneManager.dart';
import '../../../tools/AudioManager/AudioManager.dart';
import 'CardItem.dart';
import 'CurrencyTypeEnum.dart';

class AvatarGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> avatars;

  const AvatarGridWidget({required this.avatars, super.key});

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context);
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    // 👇 Unlock celebration popup
    void showUnlockPopup(BuildContext context, String imagePath) {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => Center(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🌌 Subtle blurred dark background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                ),

                // ✨ Main column content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reward visual stack
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glowing aura
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.deepOrangeAccent.withOpacity(0.5),
                                Colors.transparent,
                              ],
                              radius: 0.8,
                            ),
                          ),
                        ),

                        // Lottie background effect
                        Lottie.asset(
                          "assets/animations/AnimationSFX/RewawrdLightEffect.json",
                          width: 260,
                          height: 260,
                          repeat: true,
                          fit: BoxFit.contain,
                        ),

                        // Avatar image card
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrangeAccent.withOpacity(0.7),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              imagePath,
                              width: 160,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Foreground confetti
                        Lottie.asset(
                          "assets/animations/Win/Confetti.json",
                          width: 400,
                          height: 400,
                          repeat: false,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 🎉 Title text
                    const Text(
                      "Avatar Unlocked!",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.deepOrangeAccent,
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🧡 Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 10,
                        shadowColor: Colors.deepOrangeAccent.withOpacity(0.6),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: const Text(
                        "Awesome!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )

          ),
        ),
      );
    }

    // 👇 Purchase dialog
    void showPurchaseDialog(
        BuildContext parentContext, String imagePath, int cost, CurrencyType currency) {
      String currencySymbol =
      currency == CurrencyType.gold ? "💰 Gold" : "💎 Gems";

      showDialog(
        context: parentContext,
        builder: (context) => Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Unlock Avatar",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, width: 120, height: 160),
                ),
                const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Unlock for $cost",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Image.asset(
                    currency == CurrencyType.gold
                        ? 'assets/UI/Icons/Gamification/GoldInGame_Icon.png'
                        : 'assets/UI/Icons/Gamification/Gems_Icon.png',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        audioManager.playEventSound("sandClick");
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange),
                      onPressed: () async {
                        // Play confirm click
                        audioManager.playEventSound("sandClick");

                        bool success = false;
                        if (currency == CurrencyType.gold) {
                          success = await xpManager.spendGold(cost);
                        } else {
                          success = await xpManager.spendGems(cost);
                        }

                        if (success) {
                          // Play purchase success sound
                          audioManager.playSfx("assets/audios/UI/SFX/Gamification_SFX/Win1.mp3");

                          xpManager.unlockAvatar(imagePath);
                          xpManager.selectAvatar(imagePath);

                          // 🔹 Pop purchase dialog first
                          Navigator.pop(context);

                          // 🔹 Delay to show unlock popup
                          Future.delayed(const Duration(milliseconds: 100), () {
                            showUnlockPopup(parentContext, imagePath);
                          });

                        } else {
                          // Play error/failed purchase sound
                          audioManager.playEventSound("sandClick");

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Not enough $currencySymbol!")),
                          );
                        }
                      },
                      child: const Text("Unlock"),
                    )

                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
      itemCount: avatars.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, index) {
        final item = avatars[index];
        final imagePath = item['image'];
        final cost = item['cost'];
        final currency = item['currency'] as CurrencyType;
        final unlocked = xpManager.isAvatarUnlocked(imagePath);
        final selected = xpManager.selectedAvatar == imagePath;

        return CardItemWidget(
          imagePath: imagePath,
          cost: cost,
          currencyType: currency,
          unlocked: unlocked,
          selected: selected,
          userGold: xpManager.gold,
          userGems: xpManager.gems,
          onSelect: () => xpManager.selectAvatar(imagePath),
          onBuy: () => showPurchaseDialog(context, imagePath, cost, currency),
        );
      },
    );
  }
}
