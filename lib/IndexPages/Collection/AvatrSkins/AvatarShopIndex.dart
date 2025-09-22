import 'package:flutter/material.dart';

import 'AvatarSkinTabs/CardMaster.dart';
import 'AvatarSkinTabs/Elements.dart';
import 'AvatarSkinTabs/Warriors.dart';


class AvatarShopIndex extends StatelessWidget {
  const AvatarShopIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        backgroundColor: Colors.transparent, // keep body transparent
        appBar: AppBar(
          backgroundColor: Colors.transparent, // transparent AppBar
          elevation: 0, // remove shadow
          centerTitle: true,
          title: const Text(
            "Avatar Skins",
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
              Tab(text: "CardMaster"),
              Tab(text: "Warriors"),
              Tab(text: "Elements"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CardMaster(),
            Warriors(),
            Elements()
          ],
        ),
      ),
    );
  }
}
