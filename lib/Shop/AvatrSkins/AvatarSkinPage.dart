import 'package:flutter/material.dart';
import 'package:hezzstar/Shop/Tools/AvatarGridWidget.dart';

class AvatarShopPage extends StatelessWidget {
  const AvatarShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AvatarGridWidget(
        avatars: [
          {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal1.jpg", "cost": 50},
          {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal2.jpg", "cost": 100},
          {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Drag1.jpg", "cost": 200},
        ],
      ),
    );
  }
}
