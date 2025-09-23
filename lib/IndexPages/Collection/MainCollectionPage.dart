import 'package:flutter/material.dart';
import 'package:hezzstar/widgets/userStatut/userStatus.dart';
import 'package:provider/provider.dart';
import '../../tools/AudioManager/AudioManager.dart';
import 'AvatrSkins/AvatarShopIndex.dart';
import 'CardSkins/CardSkinsIndexPage.dart';
import 'dart:ui';

import 'TableSkin/TableSkin.dart';

class MainCollectionPage extends StatefulWidget {
  const MainCollectionPage({super.key});

  @override
  State<MainCollectionPage> createState() => _MainCollectionPageState();
}

class _MainCollectionPageState extends State<MainCollectionPage>
    with TickerProviderStateMixin {

  final GlobalKey goldKey = GlobalKey(); // <-- add this
  late TabController _tabController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 User Status Bar
             Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: UserStatusBar(goldKey: goldKey),
            ),

            const SizedBox(height: 12),

            // 🔹 Shop Title
            const Text(
              "Shop",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 6,
                    color: Colors.black54,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 TabBar with blur background
            Stack(
              children: [
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      height: 72,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.amber,
                  unselectedLabelColor: Colors.white,
                  indicatorColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      icon: Image(
                        image: AssetImage('assets/UI/Icons/TabBars_Icons/CardSkin_Icon.png'),
                        width: 55,
                        height: 50,
                      ),
                      text: "Card Skins",
                    ),
                    Tab(
                      icon: Image(
                        image: AssetImage('assets/UI/Icons/TabBars_Icons/TableSkin_Icon.png'),
                        width: 45,
                        height: 45,
                      ),
                      text: "Table Skins",
                    ),
                    Tab(
                      icon: Image(
                        image: AssetImage('assets/UI/Icons/TabBars_Icons/AvatarSkins_Icon.png'),
                        width: 46,
                        height: 46,
                      ),
                      text: "Avatars",
                    ),
                  ],
                ),

                // 🔹 Animated Glow & Bounce Indicator
                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_tabController.animation!, _bounceController]),
                  builder: (context, child) {
                    double animationValue = _tabController.animation!.value;
                    double bounceValue = _bounceController.value * 2.9;

                    return Positioned(
                      bottom: bounceValue,
                      left: animationValue * tabWidth,
                      width: tabWidth,
                      child: Center(
                        child: Container(
                          height: 4,
                          width: tabWidth * 0.9,
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

            const SizedBox(height: 8),

            // 🔹 Expanded TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CardSkinsIndexPage(),
                  TableSkin(),
                  AvatarShopIndex(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
