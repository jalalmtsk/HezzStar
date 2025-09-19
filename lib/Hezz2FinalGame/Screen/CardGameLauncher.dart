import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hezzstar/Hezz2FinalGame/Screen/GameScreen.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:hezzstar/widgets/userStatut/userStatus.dart';
import '../../ExperieneManager.dart';

class CardGameLauncher extends StatefulWidget {
  final int botCount;
  const CardGameLauncher({super.key, required this.botCount});

  @override
  State<CardGameLauncher> createState() => _CardGameLauncherState();
}

class _CardGameLauncherState extends State<CardGameLauncher>
    with TickerProviderStateMixin {
  GameModeType gameMode = GameModeType.playToWin;
  int handSize = 5;
  int selectedBetIndex = 0;

  late PageController _pageController;
  late AnimationController _pulseController;
  late AnimationController _chipController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> bets = [
    {'gold': 50, 'xp': 2},
    {'gold': 100, 'xp': 4},
    {'gold': 200, 'xp': 8},
    {'gold': 500, 'xp': 20},
    {'gold': 2000, 'xp': 25},
    {'gold': 10000, 'xp': 30},
    {'gold': 20000, 'xp': 60},
    {'gold': 50000, 'xp': 100},
    {'gold': 100000, 'xp': 200},
    {'gold': 200000, 'xp': 300},
    {'gold': 1000000, 'xp': 500},
    {'gold': 2000000, 'xp': 1000},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.65);

    // Pulse animation for selected bet card
    _pulseController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Floating chips animation
    _chipController =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _chipController.dispose();
    super.dispose();
  }

  String _formatGold(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final expManager = context.watch<ExperienceManager>();

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Skins/BackCard_Skins/HomeBg1.jpg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const UserStatusBar(),
                const SizedBox(height: 20),
                _luxTitle(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _premiumGameModeToggle(),
                              const SizedBox(height: 20),
                              _premiumHandSizeSelector(),
                              Expanded(child: _luxBetCarousel()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _premiumStartButton(expManager),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _luxTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Colors.yellowAccent, Colors.orangeAccent]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.orangeAccent.withOpacity(0.7),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "🎴 Card Game Lobby",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${widget.botCount + 1} Players",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _premiumGameModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => gameMode = GameModeType.playToWin),
          child: Image.asset(
            gameMode == GameModeType.playToWin
                ? 'assets/images/Skins/BackCard_Skins/button.png'
                : 'assets/images/Skins/BackCard_Skins/MythCard2.jpg',
            width: 140,
            height: 60,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => setState(() => gameMode = GameModeType.elimination),
          child: Image.asset(
            gameMode == GameModeType.elimination
                ? 'assets/images/Skins/BackCard_Skins/button.png'
                : 'assets/images/Skins/BackCard_Skins/MythCard2.jpg',
            width: 140,
            height: 60,
          ),
        ),
      ],
    );
  }

  Widget _premiumHandSizeSelector() {
    return Container(
      width: 300,
      height: 60,
      child: Row(
        children: [
          _handOption('Quick', 3),
          _handOption('Medium', 5),
          _handOption('Long', 9),
        ],
      ),
    );
  }

  Widget _handOption(String label, int size) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => handSize = size),
        child: Image.asset(
          handSize == size
              ? 'assets/images/${label}_active.png'
              : 'assets/images/$label.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _luxBetCarousel() {
    return PageView.builder(
      controller: _pageController,
      itemCount: bets.length,
      onPageChanged: (index) => setState(() => selectedBetIndex = index),
      itemBuilder: (context, index) {
        final bet = bets[index];
        bool isSelected = selectedBetIndex == index;

        return Center(
          child: Transform.scale(
            scale: isSelected ? _pulseAnimation.value : 1.0,
            child: GestureDetector(
              onTap: () => setState(() => selectedBetIndex = index),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    isSelected
                        ? 'assets/images/Skins/BackCard_Skins/Untitled_design__9_-removebg-preview.png'
                        : 'assets/images/Skins/BackCard_Skins/2.png',
                    width: 180,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                  // Overlay Gold and XP
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${_formatGold(bet['gold'])} G",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "+${bet['xp']} XP",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _premiumStartButton(ExperienceManager expManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GestureDetector(
        onTap: () async {
          final bet = bets[selectedBetIndex];
          if (expManager.gold >= bet['gold']) {
            expManager.spendGold(bet['gold']);
            expManager.addExperience(bet['xp']);

            // Show the searching popup using widget.botCount
            await _showSearchingPopup(context, widget.botCount);

            // After searching popup closes, navigate to GameScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GameScreen(
                  startHandSize: handSize,
                  botCount: widget.botCount,
                  mode: GameMode.local,
                  gameModeType: gameMode,
                  selectedBet: bet['gold'],
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Not enough Gold!')),
            );
          }
        },
        child: Image.asset(
          'assets/images/start_button.png',
          height: 60,
        ),
      ),
    );
  }

// Updated Future to use widget.botCount
  Future<void> _showSearchingPopup(BuildContext context, int players) async {
    int foundPlayers = 0; // Reset at the start of the dialog

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        void findNextPlayer(void Function(void Function()) setState) {
          if (foundPlayers >= players) {
            Future.delayed(const Duration(seconds: 1), () {
              if (Navigator.canPop(context)) Navigator.of(context).pop();
            });
            return;
          }

          // Random delay between 1s (1000ms) and 3s (3000ms)
          final randomDelay = Duration(milliseconds: 1000 + Random().nextInt(2001));
          Future.delayed(randomDelay, () {
            if (!Navigator.canPop(context)) return;
            setState(() {
              foundPlayers++;
            });
            findNextPlayer(setState);
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            if (foundPlayers == 0) {
              findNextPlayer(setState);
            }

            return Dialog(
              backgroundColor: Colors.green.shade900.withOpacity(0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.yellowAccent,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "$foundPlayers/$players",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      foundPlayers < players ? "Searching..." : "⚡ Match Found!",
                      style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(players, (index) {
                        bool isActive = index < foundPlayers;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.yellowAccent : Colors.grey[600],
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                              BoxShadow(
                                color: Colors.yellowAccent.withOpacity(0.7),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                                : [],
                          ),
                          child: isActive
                              ? const Icon(Icons.person, size: 14, color: Colors.white)
                              : null,
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    const Text("Please wait...",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

