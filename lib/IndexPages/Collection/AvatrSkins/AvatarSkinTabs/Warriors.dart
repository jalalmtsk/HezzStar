import 'package:flutter/material.dart';

import '../../Tools/AvatarGridWidget.dart';
import '../../Tools/CurrencyTypeEnum.dart';

class Warriors extends StatelessWidget {
  const Warriors({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AvatarGridWidget(
          avatars: [
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior1.png",'currency': CurrencyType.gold, "cost": 2500000},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior2.png",'currency': CurrencyType.gold, "cost": 3500000},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior3.png",'currency': CurrencyType.gems, "cost": 1200},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior4.png",'currency': CurrencyType.gems, "cost": 1500},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior5.png",'currency': CurrencyType.gems, "cost": 1800},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior6.png",'currency': CurrencyType.gems, "cost": 2000},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior7.png",'currency': CurrencyType.gems, "cost": 2200},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior8.png",'currency': CurrencyType.gems, "cost": 3400},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior9.png",'currency': CurrencyType.gems, "cost": 3800},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior10.png",'currency': CurrencyType.gems, "cost": 4000},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior11.png",'currency': CurrencyType.gems, "cost": 5000},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior12.png",'currency': CurrencyType.gems, "cost": 5000},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior13.png",'currency': CurrencyType.gems, "cost": 10000},
            {"image": "assets/images/Skins/AvatarSkins/Warriors/Warrior14.png",'currency': CurrencyType.gold, "cost": 100000000},
          ],
        ),
      ),
    );
  }
}
