import 'package:flutter/material.dart';
import '../../Tools/CardGridWidget.dart';

class MythicalCardsPage extends StatelessWidget {
  const MythicalCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardGridWidget(
        imageCards: [
          {"image": "assets/images/Skins/BackCard_Skins/MythCard1.jpg", "cost": 10},
          {"image": "assets/images/Skins/BackCard_Skins/MythCard2.jpg", "cost": 20},
        ],
      ),
    );
  }
}
