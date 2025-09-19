import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ExperieneManager.dart';
import '../../tools/AudioManager/AudioManager.dart';
import 'CardItem.dart'; // You can reuse the same CardItemWidget for avatars

class AvatarGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> avatars;

  const AvatarGridWidget({required this.avatars, super.key});

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context);
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    void showPurchaseDialog(BuildContext parentContext, String imagePath, int cost) {
      showDialog(
        context: parentContext,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Purchase"),
          content: Text("Do you want to unlock this avatar for $cost 💰?"),
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
                  xpManager.unlockAvatar(imagePath);
                  xpManager.selectAvatar(imagePath);
                  audioManager.playEventSound("clickButton");
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Avatar unlocked!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Not enough gold!")),
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
        final unlocked = xpManager.isAvatarUnlocked(imagePath);
        final selected = xpManager.selectedAvatar == imagePath;

        return CardItemWidget(
          imagePath: imagePath,
          cost: cost,
          unlocked: unlocked,
          selected: selected,
          userGold: xpManager.gold,
          onSelect: () => xpManager.selectAvatar(imagePath),
          onBuy: () => showPurchaseDialog(context, imagePath, cost),
        );
      },
    );
  }
}
