import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:provider/provider.dart';

import '../../Hezz2FinalGame/Screen/CardGameLauncher.dart';
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
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.85),
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () => AvatarSelectionPopup.show(context, xpManager),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.purpleAccent, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.deepPurple,
                              backgroundImage: xpManager.selectedAvatar != null
                                  ? AssetImage(xpManager.selectedAvatar!)
                                  : const AssetImage("assets/avatars/default.png"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 🌟 Animated Logo
                  Center(
                    child: AnimatedBuilder(
                      animation: _bgController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + (_bgController.value * 0.05),
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xF1C40F), Color(0x9B59B6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Container(
                              height: 180,
                              width: 320,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/UI/modes/logo4-removebg-preview.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),


                  // 🎮 Expanded Horizontal Game Modes
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _modes.length,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemBuilder: (context, index) {
                        final mode = _modes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _modeCard(mode['title']!, mode['botCount']!, index),
                        );
                      },
                    ),
                  ),


                  // 💎 Add Gold Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        elevation: 0,
                      ).copyWith(
                        shadowColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        xpManager.addGold(30000);
                        xpManager.addGems(40000);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.black87,
                            content: Text(
                              "💰 30000 Gold & 40000 Gems added!",
                              style: TextStyle(
                                color: Color(0xF1C40F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0x9B59B6), Color(0xF1C40F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xF1C40F).withOpacity(0.6),
                              blurRadius: 25,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 45),
                          child: Text(
                            "💎 Add 30k Gold",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
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
