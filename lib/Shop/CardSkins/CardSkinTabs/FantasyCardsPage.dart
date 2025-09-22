import 'package:flutter/material.dart';
import '../../Tools/CardGridWidget.dart';
import '../../Tools/CurrencyTypeEnum.dart';

class FantasyCardsPage extends StatelessWidget {
  const FantasyCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CardGridWidget(
        imageCards: [
          {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal1.jpg", 'currency': CurrencyType.gold, "cost": 50},
          {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal2.jpg", 'currency': CurrencyType.gems, "cost": 100000},
          {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal3.jpg", 'currency': CurrencyType.gems, "cost": 50},

        ],
      ),
    );
  }
}
