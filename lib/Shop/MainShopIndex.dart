import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../tools/AudioManager/AudioManager.dart';
import 'AvatrSkins/AvatarShopIndex.dart';
import 'CardSkins/CardSkinsIndexPage.dart';

class MainCardShopPage extends StatelessWidget {
  const MainCardShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme.copyWith(
      primary: const Color(0xFFFF6F3C),
      primaryContainer: const Color(0xFFFFA65C),
      surface: Colors.white,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 2,
          title: const Text(
            "Shop",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.style), text: "Card Skins"),
              Tab(icon: Icon(Icons.table_bar), text: "Table Skins"),
              Tab(icon: Icon(Icons.person), text: "Avatars"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CardSkinsIndexPage(),
            CardSkinsIndexPage(),
            AvatarShopIndex(),
          ],
        ),
      ),
    );
  }

  Widget _circularButton(
      {required IconData icon,
        required VoidCallback onTap,
        required Color color}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 24, color: color),
        ),
      ),
    );
  }
}
