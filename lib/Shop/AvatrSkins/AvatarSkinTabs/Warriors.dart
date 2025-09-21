import 'package:flutter/material.dart';
import 'package:hezzstar/Shop/Tools/AvatarGridWidget.dart';

import '../../Tools/CurrencyTypeEnum.dart';

class Warriors extends StatelessWidget {
  const Warriors({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AvatarGridWidget(
        avatars: [
          {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior1.png",'currency': CurrencyType.gold, "cost": 50},
          {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior2.png",'currency': CurrencyType.gold, "cost": 100},
          {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior3.png",'currency': CurrencyType.gems, "cost": 200},
          {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior4.png",'currency': CurrencyType.gems, "cost": 300},
          {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior5.png",'currency': CurrencyType.gems, "cost": 400},
        ],
      ),
    );
  }
}
