import 'package:flutter/material.dart';
import '../../../main.dart';
import 'CardSkinTabs/FantasyCardsPage.dart';
import 'CardSkinTabs/MythicalCardsPage.dart';
import 'CardSkinTabs/NaturalCardsPage.dart';

class CardSkinsIndexPage extends StatelessWidget {
  const CardSkinsIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent, // keep transparent background
          body: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Text(
                      tr(context).cardSkins,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Minimal underline
                    Container(
                      height: 3,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.amberAccent,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Custom TabBar without AppBar
              Container(
                color: Colors.black.withOpacity(0.5), // optional background
                child:  TabBar(
                  indicatorColor: Colors.yellowAccent, // glowing indicator
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: tr(context).mythical),
                    Tab(text: tr(context).fantasy),
                  ],
                ),
              ),
              // TabBarView
              const Expanded(
                child: TabBarView(
                  children: [
                    MythicalCardsPage(),
                    NaturalCardsPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
