// file: offline_card_game_launcher.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/MainScreenIndex.dart';
import 'package:provider/provider.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:hezzstar/Hezz2FinalGame/Screen/GameScreen.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:hezzstar/widgets/userStatut/userStatus.dart';
import '../../../tools/AudioManager/AudioManager.dart';
import '../../main.dart';
import 'Tools_Offline/OfflineLoadingPopUp.dart';

class OfflineCardGameLauncher extends StatefulWidget {
  const OfflineCardGameLauncher({super.key});

  @override
  State<OfflineCardGameLauncher> createState() => _OfflineCardGameLauncherState();
}

class _OfflineCardGameLauncherState extends State<OfflineCardGameLauncher>
    with TickerProviderStateMixin {

  // Offline settings
  int handSize = 5;
  final List<Map<String, dynamic>> handOptions = [
    {"label": "Quick", "size": 3},
    {"label": "Medium", "size": 5},
    {"label": "Long", "size": 7},
  ];

  final List<int> playerCounts = [2, 3, 4, 5]; // total players
  int selectedPlayerCount = 2;

  // Premium Blue & Gold palette
  Color primaryAccent = const Color(0xFF1E3A8A); // deep blue
  Color secondaryAccent = const Color(0xFFFACC15); // gold yellow

  late AnimationController _handEntranceController;

  @override
  void initState() {
    super.initState();
    _handEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _handEntranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expManager = context.watch<ExperienceManager>();
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/UI/BackgroundImage/bg5.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),
                UserStatusBar(
                  goldKey: GlobalKey(),
                  gemsKey: GlobalKey(),
                  xpKey: GlobalKey(),
                  showPlusButton: false,
                ),
                const SizedBox(height: 28),
                _title("🎴 ${tr(context).offlineLobby} 🎴"),
                const SizedBox(height: 14),
                _playerSelectorRow(),
                const SizedBox(height: 14),
                _title(tr(context).cards),
                const SizedBox(height: 14),
                Container(child: _handSizeSelectorRow()),
                Expanded(child: _animatedHandPreview()),
                _offlineStartRowButtons(expManager, audioManager),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String title) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [primaryAccent, secondaryAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryAccent.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handSizeSelectorRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: handOptions.map((opt) {
          bool isSelected = handSize == opt["size"];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => setState(() => handSize = opt["size"]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? secondaryAccent : Colors.white30,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: secondaryAccent.withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : [],
                ),
                child: Text(
                  "${opt["size"]} ${tr(context).cards}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryAccent : Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _playerSelectorRow() {
    return Wrap(
      spacing: 15,
      runSpacing: 5,
      alignment: WrapAlignment.center,
      children: playerCounts.map((count) {
        bool isSelected = selectedPlayerCount == count;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => setState(() => selectedPlayerCount = count),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.black54,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isSelected ? secondaryAccent : Colors.white30,
                    width: 2),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: secondaryAccent.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
                    : [],
              ),
              child: Text(
                "$count ${tr(context).players}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? primaryAccent : Colors.white70,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _animatedHandPreview() {
    final cardWidth = 60.0;
    final cardHeight = cardWidth * 1.5;

    return Center(
      child: AnimatedBuilder(
        animation: _handEntranceController,
        builder: (context, _) {
          double entrance = Curves.elasticOut.transform(_handEntranceController.value);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(handSize, (index) {
                double tilt = (index - (handSize - 1) / 2) * 0.12 * entrance;
                return Transform.rotate(
                  angle: tilt,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [primaryAccent.withValues(alpha: 0.7), secondaryAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryAccent.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: const Offset(2, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  color: Colors.black38,
                                  blurRadius: 3,
                                  offset: Offset(1, 2))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _offlineStartRowButtons(ExperienceManager expManager, AudioManager audioManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Exit Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                audioManager.playEventSound("sandClick");
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => MainScreen()));
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryAccent, primaryAccent.withValues(alpha: 0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    tr(context).exit,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2))
                        ]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Start Match Button
          Expanded(
            child: GestureDetector(
              onTap: () async {
                audioManager.playEventSound("sandClick");

                await OfflineLoadingPopup.show(context, durationSeconds: 3);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      startHandSize: handSize,
                      botCount: selectedPlayerCount - 1,
                      mode: GameMode.local,
                      gameModeType: GameModeType.playToWin,
                      selectedBet: 0,
                      xpReward: 1,
                    ),
                  ),
                );
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryAccent, secondaryAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: secondaryAccent.withOpacity(0.5),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    tr(context).startMatch,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2))
                        ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
