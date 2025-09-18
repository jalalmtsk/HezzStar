import 'package:flutter/material.dart';
import '../../Tools/CardGridWidget.dart';

class FantasyCardsPage extends StatelessWidget {
  const FantasyCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardGridWidget(
        imageCards: [
          {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal1.jpg", "cost": 50},
          {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal2.jpg", "cost": 100},
          {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Drag1.jpg", "cost": 200},
        ],
      ),
    );
  }
}
