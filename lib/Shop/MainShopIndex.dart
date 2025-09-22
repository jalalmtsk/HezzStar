import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../tools/AudioManager/AudioManager.dart';
import 'AvatrSkins/AvatarShopIndex.dart';
import 'CardSkins/CardSkinsIndexPage.dart';

class MainCardShopPage extends StatefulWidget {
  const MainCardShopPage({super.key});

  @override
  State<MainCardShopPage> createState() => _MainCardShopPageState();
}

class _MainCardShopPageState extends State<MainCardShopPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / _tabController.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 2,
        title: const Text(
          "Shop",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Stack(
            children: [
              // TabBar
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.transparent, // hide default
                tabs: const [
                  Tab(icon: Icon(Icons.style), text: "Card Skins"),
                  Tab(icon: Icon(Icons.table_bar), text: "Table Skins"),
                  Tab(icon: Icon(Icons.person), text: "Avatars"),
                ],
              ),
              // Animated Glow & Bounce Indicator
              AnimatedBuilder(
                animation: Listenable.merge(
                    [_tabController.animation!, _bounceController]),
                builder: (context, child) {
                  double animationValue = _tabController.animation!.value;
                  double bounceValue = _bounceController.value * 4; // bounce height

                  return Positioned(
                    bottom: bounceValue, // vertical bounce
                    left: animationValue * tabWidth,
                    width: tabWidth,
                    child: Center(
                      child: Container(
                        height: 6,
                        width: tabWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CardSkinsIndexPage(),
          CardSkinsIndexPage(),
          AvatarShopIndex(),
        ],
      ),
    );
  }
}
