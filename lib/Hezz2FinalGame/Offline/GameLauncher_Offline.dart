// file: offline_card_game_launcher.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/MainScreenIndex.dart';
import 'package:provider/provider.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:hezzstar/Hezz2FinalGame/Screen/GameScreen.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:hezzstar/widgets/userStatut/userStatus.dart';
import '../../../tools/AudioManager/AudioManager.dart';
import '../Screen/GameLauncher/GameLauncher_Tools/SearchingPopup.dart';

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

  Color primaryAccent = Colors.orangeAccent;
  Color secondaryAccent = Colors.deepOrange;

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
                image: AssetImage('assets/UI/BackgroundImage/EndScreenBackground.jpg'),
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
                _title("🎴 Offline Lobby 🎴"),
                const SizedBox(height: 14),
                _playerSelectorRow(),
                const SizedBox(height: 14),
                _title("Cards"),
                const SizedBox(height: 14),
                _handSizeSelectorRow(),
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
          gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
        ),
        child:  Text(
          title,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _handSizeSelectorRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: handOptions.map((opt) {
        bool isSelected = handSize == opt["size"];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => setState(() => handSize = opt["size"]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.black54,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? primaryAccent : Colors.white24,
                  width: isSelected ? 2.5 : 1.2,
                ),
              ),
              child: Text(
                "${opt["size"]} Cards",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black87 : Colors.white,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _playerSelectorRow() {
    return Wrap(
      children: playerCounts.map((count) {
        bool isSelected = selectedPlayerCount == count;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => setState(() => selectedPlayerCount = count),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.black54,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? primaryAccent : Colors.white24, width: 2),
              ),
              child: Text(
                "$count Players",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black87 : Colors.white70,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _animatedHandPreview() {
    final cardWidth = 50.0;
    final cardHeight = cardWidth * 1.4;

    return Center(
      child: AnimatedBuilder(
        animation: _handEntranceController,
        builder: (context, _) {
          double entrance = Curves.elasticOut.transform(_handEntranceController.value);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(handSize, (index) {
              double tilt = (index - (handSize - 1) / 2) * 0.1 * entrance;
              return Transform.rotate(
                angle: tilt,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            }),
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


          Expanded(
            child: GestureDetector(
              onTap: () {
                audioManager.playEventSound("sandClick");
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
                // your logic for online button
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.redAccent, Colors.deepOrange]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Exit",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Offline Start Button
          Expanded(
            child: GestureDetector(
              onTap: () async {
                audioManager.playEventSound("sandClick");

                // Add XP for offline mode
                expManager.addExperience(1);

                // Navigate to GameScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      startHandSize: handSize,
                      botCount: selectedPlayerCount - 1,
                      mode: GameMode.local,
                      gameModeType: GameModeType.playToWin,
                      selectedBet: 0, // no gold in offline
                      xpReward: 0,
                    ),
                  ),
                );
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: primaryAccent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Start Game",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),


          // Example: Second button (e.g. Online Mode)
        ],
      ),
    );
  }
}
