import 'package:flutter/material.dart';
import 'CardSkinTabs/FantasyCardsPage.dart';
import 'CardSkinTabs/MythicalCardsPage.dart';
import 'CardSkinTabs/NaturalCardsPage.dart';

class CardSkinsIndexPage extends StatelessWidget {
  const CardSkinsIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(text: "Mythical"),
              Tab(text: "Fantasy"),
              Tab(text: "Natural"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MythicalCardsPage(),
            FantasyCardsPage(),
            NaturalCardsPage(),
          ],
        ),
      ),
    );
  }
}
