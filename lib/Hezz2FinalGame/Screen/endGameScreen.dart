import 'dart:math';
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
  final int xpWin;
  final String winnerName;
  final String winnerAvatar;
  final String rewardMessage;
  final List<int> playerScores;
  final List<String> playerNames;
  final List<String>? playerAvatars; // optional
  final GameMode mode;

  const EndGameScreen({
    super.key,
    required this.hands,
    required this.winnerIndex,
    required this.gameModeType,
    required this.currentRound,
    required this.betAmount,
    required this.xpWin,
    required this.winnerName,
    required this.winnerAvatar,
    required this.rewardMessage,
    required this.playerScores,
    required this.playerNames,
    required this.playerAvatars,
    required this.mode
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

    RewardDimScreen.show(
      context,
      start: const Offset(200, 400),
      endKey: xpKeyEnd,
      amount: widget.xpWin,
      type: RewardType.star,
    );

    prizes.clear();

    if (widget.gameModeType == GameModeType.playToWin) {
      // ✅ Only the winner takes all
      prizes[widget.winnerIndex] = totalPool;

      // 🎁 If YOU are the winner, show reward animation and update stats
      if (widget.winnerIndex == 0) {
        RewardDimScreen.show(
          context,
          start: const Offset(200, 400),
          endKey: goldKeyEnd,
          amount: totalPool,
          type: RewardType.gold,
        );
        xpManager.addWin(widget.hands.length);
        xpManager.addGold(totalPool);


      }
    } else {
      // 🏆 Elimination mode — Weighted reward distribution by rank
      final int playerCount = widget.playerScores.length;

      // Sort players by score descending to determine rank order
      final List<int> sortedIndices =
      List.generate(playerCount, (i) => i)
        ..sort((a, b) => widget.playerScores[b].compareTo(widget.playerScores[a]));

      // Assign exponential weights based on rank (e.g., 8, 4, 2, 1 for 4 players)
      final List<int> weights = List.generate(
        playerCount,
            (i) => pow(2, playerCount - i - 1).toInt(),
      );

      final int sumWeights = weights.reduce((a, b) => a + b);

      // Calculate weighted rewards
      for (int rank = 0; rank < playerCount; rank++) {
        final int playerIndex = sortedIndices[rank];
        prizes[playerIndex] =
            ((totalPool * weights[rank]) / sumWeights).round();
      }

      // 🎁 Give reward animation if local player earned something
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
        xpManager.addGold(playerReward);
      }
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


    final Map<int, bool> isTied = {};
    for (int i = 0; i < widget.playerScores.length; i++) {
      final score = widget.playerScores[i];
      final countSameScore =
          widget.playerScores.where((s) => s == score).length;
      isTied[i] = countSameScore > 1;
    }

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
                          final tied = isTied[index] ?? false;
                          return _luxPlayerCard(index, isWinner, gold, rank + 1, tied);
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
                  : "Congratulations!",
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _luxPlayerCard(int index, bool isWinner, int gold, int rank, bool isTied)
  {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);

    final int score = widget.playerScores[index];
    final avatarPath = widget.playerAvatars?[index];
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
              backgroundImage: widget.mode == GameMode.online ?AssetImage(avatarPath!) : (index == 0 ? AssetImage(widget.playerAvatars![0]):AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png")),
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
          widget.mode == GameMode.online ? widget.playerNames[index] : (index == 0 ? xpManager.username :"Bot"),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWinner ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          'Hezz 2 Star',
          //'Score: $score pts',
          style: TextStyle(
            color: isWinner ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
        ),
        trailing:(widget.gameModeType == GameModeType.elimination && isTied)
            ? Text(
          '⏳ Playing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isWinner
                ? Colors.white
                : Colors.orangeAccent,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+$gold ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isWinner ? Colors.white : Colors.black54,
              ),
            ),
            Image.asset(
              'assets/UI/Icons/Gamification/GoldInGame_Icon.png', // 👈 replace with your actual asset path
              height: 23,
              width: 23,
            ),
          ],
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
