import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:hezzstar/tools/LanguageMenu.dart';
import 'package:provider/provider.dart';

import '../../Hezz2FinalGame/Screen/GameLauncher/CardGameLauncher.dart';
import '../../main.dart';
import '../../tools/AdsManager/AdsGameButton.dart';
import '../../widgets/userStatut/userStatus.dart';
import 'AvatarSelectionPopup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// 🟡 FlyingGold widget with amount text
class FlyingGold extends StatefulWidget {
  final Offset startOffset;
  final GlobalKey endKey;
  final VoidCallback onCompleted;
  final String amountText;

  const FlyingGold({
    super.key,
    required this.startOffset,
    required this.endKey,
    required this.onCompleted,
    required this.amountText,
  });

  @override
  State<FlyingGold> createState() => _FlyingGoldState();
}

class _FlyingGoldState extends State<FlyingGold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Offset _randomOffset;

  Offset _getEndOffset() {
    final renderBox = widget.endKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    // Center the coin on top of the gold icon
    return position + Offset(size.width / 2 - 16, size.height / 2 - 16);
  }

  @override
  void initState() {
    super.initState();
    final endOffset = _getEndOffset();
    final random = Random();
    // Add slight random offset for each coin
    _randomOffset = Offset(random.nextDouble() * 40 - 20, random.nextDouble() * 40 - 20);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<Offset>(
      begin: widget.startOffset + _randomOffset,
      end: endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: _animation.value.dx,
          top: _animation.value.dy,
          child: child!,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/UI/Icons/Gamification/Gold_Icon.png',
            width: 32,
            height: 32,
          ),
          Positioned(
            top: -20,
            child: Text(
              widget.amountText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey goldKey = GlobalKey(); // Key for gold icon
  late AnimationController _bgController;
  final List<FlyingGold> _flyingGolds = [];

  String formatGold(int amount) {
    if (amount >= 1000000) {
      double result = amount / 1000000;
      return result % 1 == 0 ? "${result.toInt()}M" : "${result.toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      double result = amount / 1000;
      return result % 1 == 0 ? "${result.toInt()}K" : "${result.toStringAsFixed(1)}K";
    } else {
      return amount.toString();
    }
  }

  void _spawnFlyingGold(int amount) {
    final size = MediaQuery.of(context).size;
    final start = Offset(size.width / 2 - 16, size.height / 2 - 16);

    // Determine number of coins based on amount
    int numCoins;
    if (amount < 10) {
      numCoins = 8;
    } else if (amount < 100) {
      numCoins = 14;
    } else if (amount < 1000) {
      numCoins = 20;
    } else if (amount < 5000) {
      numCoins = 25;
    } else if (amount < 10000) {
      numCoins = 30;
    } else if (amount < 50000) {
      numCoins = 35;
    } else if (amount < 100000) {
      numCoins = 40;
    } else {
      numCoins = 50;
    }

    for (int i = 0; i < numCoins; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        // schedule each coin with a small incremental delay
        if (!mounted) return;
        setState(() {
          _flyingGolds.add(FlyingGold(
            startOffset: start,
            endKey: goldKey,
            onCompleted: () {
              setState(() {
                if (_flyingGolds.isNotEmpty) _flyingGolds.removeAt(0);
              });
            },
            amountText: "+${formatGold(amount)}",
          ));
        });
      });
    }
  }



  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🎴 Animated Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.1 + (_bgController.value * 0.1),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/Skins/BackCard_Skins/bg3.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.79),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🌟 Status Bar and Avatar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: UserStatusBar(goldKey: goldKey),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => AvatarDetailsPopup.show(context, xpManager),
                            child: SizedBox(
                              height: 160,
                              width: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    "assets/UI/Icons/AvatarProfile_Icon.png",
                                    height: 160,
                                    width: 140,
                                    fit: BoxFit.contain,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Text(
                                      xpManager.userProfile.username ?? "Player Name",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.8),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.6),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.grey.withAlpha(200),
                                    backgroundImage: xpManager.selectedAvatar != null
                                        ? AssetImage(xpManager.selectedAvatar!)
                                        : const AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AdsGameButton(
                            text: "",
                            sparkleAsset: "assets/animations/AnimationSFX/RewawrdLightEffect.json",
                            boxAsset: "assets/animations/AnimatGamification/AdsBox.json",
                            rewardAmount: 5,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: Icon(Icons.add),
                      onTap: () {
                        int reward = 1000; // Example gold reward
                        xpManager.addGold(reward);
                        xpManager.addGems(10);
                        _spawnFlyingGold(reward);
                      },
                    ),
                    LanguageMenu(colorButton: Colors.white)
                  ],
                ),
                const SizedBox(height: 100,),

                // 🎮 Expanded Horizontal Game Modes
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _modes.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final mode = _modes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _modeCard(mode['title']!, mode['botCount']!, index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 50,),
                Center(
                  child: GestureDetector(
                    child: Icon(Icons.add),
                    onTap: () {
                      int reward = 5000000;
                      xpManager.addGold(reward);
                      xpManager.addGems(40000);
                      _spawnFlyingGold(reward);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Render flying gold animations
          ..._flyingGolds,
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _modes = [
    {'title': '⚡ 1 vs 1', 'botCount': 1},
    {'title': '👥 3 Players', 'botCount': 2},
    {'title': '🎯 4 Players', 'botCount': 3},
    {'title': '🔥 5 Players', 'botCount': 4},
    {'title': '🛰 Offline Mode', 'botCount': 4},
  ];

  Widget _modeCard(String title, int botCount, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => CardGameLauncher(botCount: botCount),
            transitionsBuilder: (_, anim, __, child) {
              return ScaleTransition(
                scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                child: child,
              );
            },
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 220,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Color(0x9B59B6), width: 2),
          boxShadow: [
            BoxShadow(
              color: Color(0x9B59B6).withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          image: DecorationImage(
            image: AssetImage('assets/UI/modes/mode_${index + 1}.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.35),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: Color(0xF1C40F), blurRadius: 16),
                Shadow(color: Color(0x9B59B6), blurRadius: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
