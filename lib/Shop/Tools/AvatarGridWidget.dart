import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ExperieneManager.dart';
import '../../tools/AudioManager/AudioManager.dart';
import 'CardItem.dart';
import 'CurrencyTypeEnum.dart';

class AvatarGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> avatars;

  const AvatarGridWidget({required this.avatars, super.key});

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context);
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    void showPurchaseDialog(
        BuildContext parentContext,
        String imagePath,
        int cost,
        CurrencyType currency,
        ) {
      String currencySymbol =
      currency == CurrencyType.gold ? "💰 Gold" : "💎 Gems";

      showDialog(
        context: parentContext,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Purchase"),
          content:
          Text("Do you want to unlock this avatar for $cost $currencySymbol?"),
          actions: [
            TextButton(
              onPressed: () {
                audioManager.playEventSound("cancelButton");
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                bool success = false;

                if (currency == CurrencyType.gold) {
                  success = xpManager.spendGold(cost);
                } else {
                  success = xpManager.spendGems(cost);
                }

                if (success) {
                  xpManager.unlockAvatar(imagePath);
                  xpManager.selectAvatar(imagePath);
                  audioManager.playEventSound("clickButton");
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Avatar unlocked!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Not enough $currencySymbol!")),
                  );
                }
              },
              child: const Text(
                "Pay",
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: avatars.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, index) {
        final item = avatars[index];
        final imagePath = item['image'];
        final cost = item['cost'];
        final currency = item['currency'] as CurrencyType; // 👈 read currency
        final unlocked = xpManager.isAvatarUnlocked(imagePath);
        final selected = xpManager.selectedAvatar == imagePath;

        return CardItemWidget(
          imagePath: imagePath,
          cost: cost,
          currencyType: currency, // 👈 gold or gems
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
