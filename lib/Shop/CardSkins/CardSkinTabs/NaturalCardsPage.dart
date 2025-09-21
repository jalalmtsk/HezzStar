import 'package:flutter/material.dart';
import '../../Tools/CardGridWidget.dart';
import '../../Tools/CurrencyTypeEnum.dart';

class NaturalCardsPage extends StatelessWidget {
  const NaturalCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/MythCard3.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/MythCard4.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/MythCard5.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Wizard1.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Wizard2.jpg",'currency': CurrencyType.gems,"cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Wizard3.jpg",'currency': CurrencyType.gems, "cost" : 100},
          {"image":"assets/images/Skins/BackCard_Skins/Fantasy/Cul1.jpg",'currency': CurrencyType.gems, "cost" : 10000},
        ],
      ),
    );
  }
}
