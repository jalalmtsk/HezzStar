import 'package:flutter/material.dart';
import '../../Tools/CardGridWidget.dart';
import '../../Tools/CurrencyTypeEnum.dart';

class MythicalCardsPage extends StatelessWidget {
  const MythicalCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: CardGridWidget(
        imageCards: [
          {"image": "assets/images/cards/backCard.png",'currency': CurrencyType.gems, "cost": 0},
          {"image": "assets/images/Skins/BackCard_Skins/Mythical/MythCard1.jpg",'currency': CurrencyType.gems, "cost": 20},
          {"image": "assets/images/Skins/BackCard_Skins/Mythical/MythCard2.jpg",'currency': CurrencyType.gems, "cost": 20},
          {"image":"assets/images/Skins/BackCard_Skins/Mythical/MythCard3.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Mythical/MythCard4.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Mythical/MythCard5.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Mythical/MythCard6.png",'currency': CurrencyType.gems,"cost" : 300},
          {"image":"assets/images/Skins/BackCard_Skins/Mythical/MythCard7.png",'currency': CurrencyType.gems,"cost" : 300},
          {"image":"assets/images/Skins/BackCard_Skins/Mythical/MythCard8.png",'currency': CurrencyType.gems,"cost" : 300},
        ],
      ),
    );
  }
}
