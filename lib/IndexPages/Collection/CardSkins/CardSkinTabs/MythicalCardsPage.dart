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
          {"image": "assets/images/Skins/BackCard_Skins/Mythical/MythCard1.jpg",'currency': CurrencyType.gems, "cost": 10},
          {"image": "assets/images/Skins/BackCard_Skins/Mythical/MythCard2.jpg",'currency': CurrencyType.gems, "cost": 20},
        ],
      ),
    );
  }
}
