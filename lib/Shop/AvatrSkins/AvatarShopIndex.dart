import 'package:flutter/material.dart';
import 'package:hezzstar/Shop/AvatrSkins/AvatarSkinTabs/CardMaster.dart';
import 'package:hezzstar/Shop/AvatrSkins/AvatarSkinTabs/Warriors.dart';


class AvatarShopIndex extends StatelessWidget {
  const AvatarShopIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(text: "CardMaster"),
              Tab(text: "Warriors"),
              Tab(text: "Natural"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CardMaster(),
            Warriors(),

          ],
        ),
      ),
    );
  }
}
