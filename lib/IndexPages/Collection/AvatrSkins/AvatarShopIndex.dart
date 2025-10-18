import 'package:flutter/material.dart';

import '../../../main.dart';
import 'AvatarSkinTabs/CardMaster.dart';
import 'AvatarSkinTabs/Elements.dart';
import 'AvatarSkinTabs/Warriors.dart';

class AvatarShopIndex extends StatelessWidget {
  const AvatarShopIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // Custom Header (no AppBar)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Text(
                      tr(context).avatarSkins,
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

              // TabBar
              Container(
                color: Colors.black.withOpacity(0.3),
                child:  TabBar(
                  indicatorColor: Colors.amberAccent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: tr(context).cardMaster),
                    Tab(text: tr(context).warriors),
                    Tab(text: tr(context).elements),
                  ],
                ),
              ),

              // TabBarView
              const Expanded(
                child: TabBarView(
                  children: [
                    CardMaster(),
                    Warriors(),
                    Elements(),
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
