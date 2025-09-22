import 'package:flutter/material.dart';

import '../../Tools/AvatarGridWidget.dart';
import '../../Tools/CurrencyTypeEnum.dart';

class CardMaster extends StatelessWidget {
  const CardMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AvatarGridWidget(
          avatars: [
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster1.png", 'currency': CurrencyType.gems,"cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster2.png", 'currency': CurrencyType.gems,"cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster3.png", 'currency': CurrencyType.gems,"cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster4.png", 'currency': CurrencyType.gems,"cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster5.png", 'currency': CurrencyType.gems,"cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster6.png", 'currency': CurrencyType.gems,"cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster7.png", 'currency': CurrencyType.gems,"cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster8.png", 'currency': CurrencyType.gems,"cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster9.png", 'currency': CurrencyType.gems,"cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster10.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster11.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster12.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster13.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster14.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster15.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster16.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster17.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster18.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster19.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster20.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster21.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster22.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster23.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster24.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster25.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster26.png",'currency': CurrencyType.gems, "cost": 100},
            {"image": "assets/images/Skins/AvatarSkins/CardMaster/CardMaster27.png",'currency': CurrencyType.gems, "cost": 100},
          ],
        ),
      ),
    );
  }
}
