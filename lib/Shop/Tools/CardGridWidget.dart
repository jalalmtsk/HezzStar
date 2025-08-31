import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ExperieneManager.dart';
import '../../tools/AudioManager/AudioManager.dart';
import 'CardItem.dart';

class CardGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> imageCards;

  const CardGridWidget({required this.imageCards, super.key});

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context);
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    void showPurchaseDialog(BuildContext parentContext, String imagePath, int cost) {
      showDialog(
        context: parentContext,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Purchase"),
          content: Text("Do you want to unlock this card for $cost ⭐?"),
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
                if (xpManager.spendGold(cost)) {
                  xpManager.unlockCard(imagePath);
                  xpManager.selectCard(imagePath);
                  audioManager.playEventSound("clickButton");
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Card unlocked!")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Not enough gold!")));
                }
              },
              child:
              const Text("Pay", style: TextStyle(color: Colors.deepOrange)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: imageCards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, index) {
        final item = imageCards[index];
        final imagePath = item['image'];
        final cost = item['cost'];
        final unlocked = xpManager.isCardUnlocked(imagePath);
        final selected = xpManager.selectedCard == imagePath;

        return CardItemWidget(
          imagePath: imagePath,
          cost: cost,
          unlocked: unlocked,
          selected: selected,
          userGold: xpManager.gold,
          onSelect: () => xpManager.selectCard(imagePath),
          onBuy: () => showPurchaseDialog(context, imagePath, cost),
        );
      },
    );
  }
}
