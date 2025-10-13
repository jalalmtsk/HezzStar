import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/MainScreenIndex.dart';
import 'package:hezzstar/widgets/userStatut/userStatus.dart';
import 'package:provider/provider.dart';
import '../../ExperieneManager.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/Cards.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import '../../Manager/HelperClass/FlyingRewardManager.dart';
import '../../Manager/HelperClass/RewardDimScreen.dart';

class EndGameScreen extends StatefulWidget {
  final List<List<PlayingCard>> hands;
  final int winnerIndex;
  final GameModeType gameModeType;
  final int currentRound;
  final int betAmount;
  final String winnerName;
  final String winnerAvatar;
  final String rewardMessage;
  final List<int> playerScores;

  const EndGameScreen({
    super.key,
    required this.hands,
    required this.winnerIndex,
    required this.gameModeType,
    required this.currentRound,
    required this.betAmount,
    required this.winnerName,
    required this.winnerAvatar,
    required this.rewardMessage,
    required this.playerScores,
  });

  @override
  State<EndGameScreen> createState() => _EndGameScreenLuxState();
}

class _EndGameScreenLuxState extends State<EndGameScreen>
    with TickerProviderStateMixin {
  final GlobalKey goldKeyEnd = GlobalKey();
  final GlobalKey gemsKeyEnd = GlobalKey();
  final GlobalKey xpKeyEnd = GlobalKey();

  bool _rewardGiven = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  Color primaryAccent = Colors.orangeAccent;
  Color secondaryAccent = Colors.deepOrange;

  Map<int, int> prizes = {}; // reward per player (index → gold)

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    _applyTheme();

    if (!_rewardGiven) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _giveRewards());
      _rewardGiven = true;
    }
  }

  void _applyTheme() {
    setState(() {
      if (widget.gameModeType == GameModeType.playToWin) {
        primaryAccent = Colors.orangeAccent;
        secondaryAccent = Colors.deepOrange;
      } else {
        primaryAccent = Colors.redAccent;
        secondaryAccent = Colors.black87;
      }
    });
  }

  void _giveRewards() {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    final int totalPool = widget.hands.length * widget.betAmount;

    if (widget.gameModeType == GameModeType.playToWin) {
      // Only the winner takes all
      prizes[widget.winnerIndex] = totalPool;
    } else {
      // Elimination mode — split by score ratio
      final totalScore = widget.playerScores.fold<int>(0, (a, b) => a + (b > 0 ? b : 0));
      for (int i = 0; i < widget.playerScores.length; i++) {
        final score = widget.playerScores[i];
        prizes[i] = totalScore > 0 ? ((score / totalScore) * totalPool).round() : 0;
      }
    }

    // Reward animation for the local player
    final int playerReward = prizes[0] ?? 0;
    if (playerReward > 0) {
      RewardDimScreen.show(
        context,
        start: const Offset(200, 400),
        endKey: goldKeyEnd,
        amount: playerReward,
        type: RewardType.gold,
      );
      xpManager.addWin(widget.hands.length);
    }

    setState(() {});
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sort players by score (descending)
    final List<int> sortedIndices = List.generate(widget.playerScores.length, (i) => i);
    sortedIndices.sort((a, b) => widget.playerScores[b].compareTo(widget.playerScores[a]));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _luxBackground()),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  UserStatusBar(
                    goldKey: goldKeyEnd,
                    gemsKey: gemsKeyEnd,
                    xpKey: xpKeyEnd,
                    showPlusButton: false,
                  ),
                  const SizedBox(height: 40),
                  _luxTitle(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        itemCount: sortedIndices.length,
                        itemBuilder: (context, rank) {
                          final index = sortedIndices[rank];
                          final gold = prizes[index] ?? 0;
                          final isWinner = index == widget.winnerIndex;
                          return _luxPlayerCard(index, isWinner, gold, rank + 1);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _luxBackButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _luxBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/UI/BackgroundImage/EndScreenBackground.jpg'),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          colors: [
            primaryAccent.withOpacity(0.2),
            secondaryAccent.withOpacity(0.1),
            Colors.black.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.0,
            colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _luxTitle() {
    final winnerName = widget.winnerIndex == 0 ? 'You' : 'Player ${widget.winnerIndex + 1}';
    final bool isElimination = widget.gameModeType == GameModeType.elimination;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
          boxShadow: [
            BoxShadow(
              color: primaryAccent.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              isElimination ? "Final Scoreboard" : "$winnerName Wins!",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isElimination
                  ? "Rewards shared by score ratio"
                  : widget.rewardMessage,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _luxPlayerCard(int index, bool isWinner, int gold, int rank) {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    final String avatarPath = (index == 0)
        ? (xpManager.selectedAvatar ??
        'assets/images/Skins/AvatarSkins/DefaultUser.png')
        : (isWinner && widget.winnerAvatar.isNotEmpty)
        ? widget.winnerAvatar
        : 'assets/images/Skins/AvatarSkins/CardMaster/CardMaster${index % 6 + 1}.png';

    final int score = widget.playerScores[index];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isWinner ? primaryAccent.withOpacity(0.85) : Colors.white,
      elevation: isWinner ? 8 : 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage(avatarPath),
            ),
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.black,
              child: Text(
                '$rank',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        title: Text(
          index == 0 ? 'You' : 'Player ${index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWinner ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          'Score: $score pts',
          style: TextStyle(
            color: isWinner ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
        ),
        trailing: Text(
          '+$gold 💰',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isWinner ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _luxBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MainScreen())),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(vertical: 14),
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
            'Back to Lobby',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
