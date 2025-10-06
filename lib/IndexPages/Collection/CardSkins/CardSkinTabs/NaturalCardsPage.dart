import 'package:flutter/material.dart';
import '../../Tools/CardGridWidget.dart';
import '../../Tools/CurrencyTypeEnum.dart';

class NaturalCardsPage extends StatelessWidget {
  const NaturalCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CardGridWidget(
        imageCards: [
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Crystal1.jpg", 'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Crystal2.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Crystal3.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Drag1.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Drag2.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Drag3.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Forest1.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Forest2.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Wizard1.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Wizard2.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Wizard3.jpg",'currency': CurrencyType.gems, "cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Cul1.jpg",'currency': CurrencyType.gems, "cost" : 10000},
        ],
      ),
    );
  }
}
