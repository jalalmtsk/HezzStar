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
  late AnimationController _bgController;
  late AnimationController _pulseController;
  late Animation<Color?> _bgAnimation1;
  late Animation<Color?> _bgAnimation2;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> bets = [
    {'gold': 50, 'xp': 2},
    {'gold': 100, 'xp': 4},
    {'gold': 200, 'xp': 8},
    {'gold': 500, 'xp': 20},
    {'gold': 2000, 'xp': 25},
    {'gold': 10000, 'xp': 30},
    {'gold': 50000, 'xp': 35},
    {'gold': 250000, 'xp': 40},
    {'gold': 1000000, 'xp': 50},
    {'gold': 5000000, 'xp': 100},
    {'gold': 10000000, 'xp': 200},
    {'gold': 20000000, 'xp': 250},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7, initialPage: 0);

    // Background gradient animation
    _bgController =
    AnimationController(vsync: this, duration: Duration(seconds: 5))
      ..repeat(reverse: true);

    _bgAnimation1 =
        ColorTween(begin: Colors.purple.shade400, end: Colors.orangeAccent)
            .animate(_bgController);
    _bgAnimation2 =
        ColorTween(begin: Colors.blue.shade300, end: Colors.pinkAccent)
            .animate(_bgController);

    // Pulse animation for selected bet
    _pulseController =
    AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
          parent: _pulseController,
          curve: Curves.easeInOut,
        ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    _pulseController.dispose();
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

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bgAnimation1.value!, _bgAnimation2.value!],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  UserStatusBar(),
                  SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              children: [
                                _connectedGameModeToggle(),
                                SizedBox(height: 20),
                                _connectedHandSizeSelector(),
                                Expanded(child: _awesomeBetCarousel()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _glowingStartButton(expManager),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------- Connected Game Mode Toggle --------
  Widget _connectedGameModeToggle() {
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: gameMode == GameModeType.playToWin
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: 125,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.5),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => gameMode = GameModeType.playToWin),
                  child: Center(
                    child: Text(
                      'Play To Win',
                      style: TextStyle(
                        color: gameMode == GameModeType.playToWin
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => gameMode = GameModeType.elimination),
                  child: Center(
                    child: Text(
                      'Elimination',
                      style: TextStyle(
                        color: gameMode == GameModeType.elimination
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------- Connected Hand Size Toggle --------
  Widget _connectedHandSizeSelector() {
    return Container(
      width: 300,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: handSize == 3
                ? Alignment.centerLeft
                : handSize == 5
                ? Alignment.center
                : Alignment.centerRight,
            child: Container(
              width: 100,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.4),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => handSize = 3),
                  child: Center(
                    child: Text(
                      'Quick',
                      style: TextStyle(
                        color: handSize == 3 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => handSize = 5),
                  child: Center(
                    child: Text(
                      'Medium',
                      style: TextStyle(
                        color: handSize == 5 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => handSize = 9),
                  child: Center(
                    child: Text(
                      'Long',
                      style: TextStyle(
                        color: handSize == 9 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------- Awesome Bet Carousel with Pulse --------
  Widget _awesomeBetCarousel() {
    return PageView.builder(
      controller: _pageController,
      itemCount: bets.length,
      onPageChanged: (index) => setState(() => selectedBetIndex = index),
      itemBuilder: (context, index) {
        final bet = bets[index];
        bool isSelected = selectedBetIndex == index;

        return AnimatedBuilder(
          animation: Listenable.merge([_pageController, _pulseController]),
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = 1 - ((_pageController.page ?? 0) - index).abs() * 0.25;
            }

            double scale = isSelected ? value * _pulseAnimation.value : value;

            return Center(
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [Colors.greenAccent, Colors.lightGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : LinearGradient(
                      colors: [Colors.white24, Colors.white10],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? Colors.greenAccent.withOpacity(0.7)
                            : Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_formatGold(bet['gold'])} Gold',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '${bet['xp']} XP',
                        style: TextStyle(
                          fontSize: 18,
                          color: isSelected ? Colors.white70 : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------- Glowing Start Button --------
  Widget _glowingStartButton(ExperienceManager expManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GestureDetector(
        onTapDown: (_) => setState(() {}),
        onTapUp: (_) => setState(() {}),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.orangeAccent, Colors.redAccent]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.7),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async {
              final bet = bets[selectedBetIndex];
              if (expManager.gold >= bet['gold']) {
                expManager.spendGold(bet['gold']);
                expManager.addExperience(bet['xp']);
                await _showSearchingPopup(context, widget.botCount);
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
                  const SnackBar(
                    content: Text('Not enough Gold to start this game!'),
                  ),
                );
              }
            },
            child: Text(
              'Start Game',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // -------- Pre-Game Loading Popup (unchanged) --------
  Future<void> _showSearchingPopup(BuildContext context, int players) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int foundPlayers = 0;

        void findNextPlayer() {
          if (foundPlayers >= players) {
            Future.delayed(Duration(seconds: 1), () {
              if (Navigator.canPop(context)) Navigator.of(context).pop();
            });
            return;
          }
          final randomDelay = Duration(milliseconds: 500 + Random().nextInt(1500));
          Future.delayed(randomDelay, () {
            foundPlayers++;
            if (Navigator.canPop(context)) (context as Element).markNeedsBuild();
            findNextPlayer();
          });
        }

        findNextPlayer();

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.orangeAccent,
                      strokeWidth: 4,
                    ),
                    SizedBox(height: 20),
                    Text(
                      foundPlayers < players
                          ? "Searching Player $foundPlayers/$players..."
                          : "Match Found!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(players, (index) {
                        bool isActive = index < foundPlayers;
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.orangeAccent : Colors.grey[600],
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                              BoxShadow(
                                color: Colors.orangeAccent.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 2,
                              )
                            ]
                                : [],
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Please wait...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
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
