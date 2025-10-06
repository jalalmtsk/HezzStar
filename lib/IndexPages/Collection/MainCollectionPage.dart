import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/widgets/userStatut/userStatus.dart';
import 'AvatrSkins/AvatarShopIndex.dart';
import 'CardSkins/CardSkinsIndexPage.dart';
import 'TableSkin/TableSkin.dart';

class MainCollectionPage extends StatefulWidget {
  const MainCollectionPage({super.key});

  @override
  State<MainCollectionPage> createState() => _MainCollectionPageState();
}

class _MainCollectionPageState extends State<MainCollectionPage>
    with TickerProviderStateMixin {
  final GlobalKey goldKeyCollection = GlobalKey();
  final GlobalKey gemsKeyCollection = GlobalKey();
  final GlobalKey xpKeyCollection = GlobalKey();

  late TabController _tabController;
  late AnimationController _introController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat(reverse: true);

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _introController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bounceController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / _tabController.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              // 🌟 Animated User Status Bar
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _introController,
                    curve: const Interval(0.0, 0.25, curve: Curves.easeOutBack),
                  )),
                  child: UserStatusBar(
                    goldKey: goldKeyCollection,
                    gemsKey: gemsKeyCollection,
                    xpKey: xpKeyCollection,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🌟 Animated Collection Title
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _introController,
                  curve: const Interval(0.2, 0.45, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.5, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _introController,
                    curve: const Interval(0.2, 0.45, curve: Curves.easeOutBack),
                  )),
                  child: const Text(
                    "Collection",
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
                ),
              ),

              const SizedBox(height: 6),

              // 🌟 TabBar with Glow & Bounce Indicator
              Stack(
                children: [
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        height: 80,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _introController,
                      curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.amber,
                      unselectedLabelColor: Colors.white,
                      indicatorColor: Colors.transparent,
                      tabs: const [
                        Tab(
                          icon: Image(
                            image: AssetImage(
                                'assets/UI/Icons/TabBars_Icons/CardSkin_Icon.png'),
                            width: 50,
                            height: 50,
                          ),
                          text: "Card Skins",
                        ),
                        Tab(
                          icon: Image(
                            image: AssetImage(
                                'assets/UI/Icons/TabBars_Icons/AvatarSkins_Icon.png'),
                            width: 46,
                            height: 46,
                          ),
                          text: "Avatars",
                        ),
                        Tab(
                          icon: Image(
                            image: AssetImage(
                                'assets/UI/Icons/TabBars_Icons/TableSkin_Icon.png'),
                            width: 45,
                            height: 45,
                          ),
                          text: "Table Skins",
                        ),
                      ],
                    ),
                  ),
                  // Animated Glow & Bounce Indicator
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_tabController.animation!, _bounceController]),
                    builder: (context, child) {
                      double animationValue = _tabController.animation!.value;
                      double bounceValue = _bounceController.value * 0.9;

                      return Positioned(
                        bottom: bounceValue * 2.9,
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

              // 🌟 Animated TabBarView
              Expanded(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _introController,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      CardSkinsIndexPage(),
                      AvatarShopIndex(),
                      TableSkin(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
