import 'package:flutter/material.dart';
import 'package:hezzstar/IndexPages/Collection/Tools/TableItems.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../ExperieneManager.dart';
import '../../../main.dart';
import '../../../tools/AudioManager/AudioManager.dart';
import 'CardItem.dart';
import 'CurrencyTypeEnum.dart';

class TableSkinGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tableSkins;

  const TableSkinGridWidget({required this.tableSkins, super.key});

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
                Container(color: Colors.black54),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      "assets/animations/Win/Confetti.json",
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
                          child: Image.asset(imagePath, width: 150, height: 100),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                     Text(
                      tr(context).tableSkinUnlocked,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child:
                       Text(tr(context).awesome, style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ),
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
                Text(tr(context).unlockTableSkin,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, width: 120, height: 80),
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
                        Navigator.pop(context);
                      },
                      child:  Text(tr(context).exit),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange),
                      onPressed: () async {
                        bool success = false;

                        if (currency == CurrencyType.gold) {
                          success = await xpManager.spendGold(cost);
                        } else {
                          success = await xpManager.spendGems(cost);
                        }

                        if (success) {
                          audioManager.playSfx("assets/audios/UI/SFX/Gamification_SFX/Win1.mp3");

                          xpManager.unlockTableSkin(imagePath);
                          xpManager.selectTableSkin(imagePath);
                          audioManager.playEventSound("sandClick");

                          Navigator.pop(context);

                          Future.delayed(const Duration(milliseconds: 100), () {
                            showUnlockPopup(parentContext, imagePath);
                          });
                        } else {
                          Navigator.pop(context);
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

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: tableSkins.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // 👈 Only one item per row
        mainAxisSpacing: 16,
        crossAxisSpacing: 0,
        childAspectRatio: 2.5, // 👈 Make it wide and table-like
      ),
      itemBuilder: (_, index) {
        final item = tableSkins[index];
        final imagePath = item['image'];
        final cost = item['cost'];
        final currency = item['currency'] as CurrencyType;
        final unlocked = xpManager.isTableSkinUnlocked(imagePath);
        final selected = xpManager.selectedTableSkin == imagePath;

        return TableSkinItemWidget(
          imagePath: imagePath,
          cost: cost,
          currencyType: currency,
          unlocked: unlocked,
          selected: selected,
          userGold: xpManager.gold,
          userGems: xpManager.gems,
          onSelect: () => xpManager.selectTableSkin(imagePath),
          onBuy: () => showPurchaseDialog(context, imagePath, cost, currency),
        );
      },
    );
  }
}
