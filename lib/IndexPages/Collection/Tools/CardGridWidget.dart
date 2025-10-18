import 'package:flutter/material.dart';
import 'package:hezzstar/main.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../ExperieneManager.dart';
import '../../../tools/AudioManager/AudioManager.dart';
import 'CardItem.dart';
import 'CurrencyTypeEnum.dart';

class CardGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> imageCards;

  const CardGridWidget({required this.imageCards, super.key});

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context);
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    // 🎉 Unlock celebration popup
    void showUnlockPopup(BuildContext context, String imagePath) {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true, // important!
        builder: (ctx) => Stack(
          alignment: Alignment.center,
          children: [
            Container(color: Colors.black54),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  "assets/animations/Win/Confetti4.json",
                  width: 250,
                  height: 250,
                  repeat: false,
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      "assets/animations/AnimationSFX/RewawrdLightEffect.json",
                      width: 220,
                      height: 220,
                      repeat: true,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(imagePath, width: 150, height: 200),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                 Text(
                  tr(context).cardUnlocked,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Builder(
                  builder: (buttonContext) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(buttonContext, rootNavigator: true).pop(); // properly closes popup
                      },
                      child:  Text("${tr(context).awesome}!", style: TextStyle(fontSize: 18)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }


    // 💳 Purchase dialog
    void showPurchaseDialog(
        BuildContext parentContext, String imagePath, int cost, CurrencyType currency) {
      String currencySymbol = currency == CurrencyType.gold ? "💰 Gold" : "💎 Gems";

      showDialog(
        context: parentContext,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr(context).unlockCard,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
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
                      "${tr(context).unlockFor} $cost",
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
                        Navigator.of(context).pop();
                      },
                      child:  Text(tr(context).cancel),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      onPressed: () async {
                        bool success = false;

                        if (currency == CurrencyType.gold) {
                          success = await xpManager.spendGold(cost);
                        } else {
                          success = await xpManager.spendGems(cost);
                        }

                        if (success) {
                          audioManager.playSfx("assets/audios/UI/SFX/Gamification_SFX/Win1.mp3");

                          xpManager.unlockCard(imagePath);
                          xpManager.selectCard(imagePath);
                          audioManager.playEventSound("sandClick");

                          // Close purchase dialog
                          Navigator.of(context).pop();

                          // Delay to avoid overlapping dialogs
                          Future.delayed(const Duration(milliseconds: 100), () {
                            showUnlockPopup(context, imagePath);
                          });
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${tr(context).notEnough} $currencySymbol!")),
                          );
                        }
                      },
                      child:  Text(tr(context).unlock),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🔳 Grid of cards
    return GridView.builder(
      padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
      itemCount: imageCards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, index) {
        final item = imageCards[index];
        final imagePath = item['image'];
        final cost = item['cost'];
        final currency = item['currency'] as CurrencyType;
        final unlocked = xpManager.isCardUnlocked(imagePath);
        // ✅ If no card selected, pick the first unlocked card as default
        if (xpManager.selectedCard == null && unlocked) {
          xpManager.selectCard(imagePath);
        }
        final selected = xpManager.selectedCard == imagePath;

        return CardItemWidget(
          imagePath: imagePath,
          cost: cost,
          currencyType: currency,
          unlocked: unlocked,
          selected: selected,
          userGold: xpManager.gold,
          userGems: xpManager.gems,
          onSelect: () => xpManager.selectCard(imagePath),
          onBuy: () => showPurchaseDialog(context, imagePath, cost, currency),
        );
      },
    );
  }
}
