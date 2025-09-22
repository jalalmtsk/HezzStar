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
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent, // keep transparent background
          appBar: AppBar(
            backgroundColor: Colors.transparent, // transparent AppBar
            elevation: 0, // remove shadow
            centerTitle: true,
            title: const Text(
              "Card Skins",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: const TabBar(
              indicatorColor: Colors.yellowAccent, // glowing indicator
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorWeight: 3,
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
      ),
    );
  }
}
