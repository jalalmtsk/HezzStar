import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:provider/provider.dart';

import '../../Hezz2FinalGame/Screen/GameLauncher/CardGameLauncher.dart';
import '../../widgets/userStatut/userStatus.dart';
import 'AvatarSelectionPopup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🌟 Status Bar and Avatar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const UserStatusBar(),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: GestureDetector(
                          onTap: () => AvatarDetailsPopup.show(context, xpManager),
                          child: Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background photo icon
                                Image.asset(
                                  "assets/UI/Icons/AvatarProfile_Icon.png", // replace with your background image
                                  height: 150, // adjust size
                                  width: 120,
                                  fit: BoxFit.contain,
                                ),

                                // CircleAvatar on top
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey.withValues(alpha: 0.8),
                                  backgroundImage: xpManager.selectedAvatar != null
                                      ? AssetImage(xpManager.selectedAvatar!)
                                      : const AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png"),
                                ),
                              ],
                            )

                          ),
                        ),
                      ),
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
                    child: ElevatedButton(
                      onPressed: () {
                        xpManager.addGold(30000);
                        xpManager.addGems(40000);
                      },
                      child: Text(
                        "💎 Add 30k Gold",
                      ),
                    ),
                  ),
                  // 💎 Add Gold Button

                ],
              ),
            ),
          ),
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
