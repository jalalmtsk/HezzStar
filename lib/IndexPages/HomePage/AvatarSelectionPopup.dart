import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ExperieneManager.dart';

class AvatarSelectionPopup {
  static void show(BuildContext context, ExperienceManager xpManager) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title:  Text(
          "Select",
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          height: 200,
          width: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: xpManager.unlockedAvatars.isNotEmpty
                ? xpManager.unlockedAvatars.length
                : 3, // fallback demo avatars
            itemBuilder: (context, index) {
              final avatarPath = xpManager.unlockedAvatars.isNotEmpty
                  ? xpManager.unlockedAvatars[index]
                  : "assets/avatars/demo_${index + 1}.png";

              return GestureDetector(
                onTap: () {
                  xpManager.selectAvatar(avatarPath);
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(avatarPath),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
