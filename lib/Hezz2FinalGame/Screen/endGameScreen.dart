import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ExperieneManager.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/Cards.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';

class EndGameScreen extends StatefulWidget {
  final List<List<PlayingCard>> hands;
  final int winnerIndex;
  final GameModeType gameModeType;
  final int currentRound;
  final int betAmount;
  final String winnerName;
  final String winnerAvatar;

  const EndGameScreen({
    super.key,
    required this.hands,
    required this.winnerIndex,
    required this.gameModeType,
    required this.currentRound,
    required this.betAmount,
    required this.winnerName,
    required this.winnerAvatar,
  });

  @override
  State<EndGameScreen> createState() => _EndGameScreenLuxState();
}

class _EndGameScreenLuxState extends State<EndGameScreen>
    with TickerProviderStateMixin {
  bool _rewardGiven = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  Color primaryAccent = Colors.orangeAccent;
  Color secondaryAccent = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    if (!_rewardGiven) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _giveReward());
      _rewardGiven = true;
    }

    _applyTheme();
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

  void _giveReward() {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    final int totalPool = widget.hands.length * widget.betAmount;
    int reward = 0;

    if (widget.gameModeType == GameModeType.playToWin) {
      reward = widget.winnerIndex == 0 ? totalPool : 0;
    } else {
      List<double> percentages = [0.5, 0.25, 0.15, 0.10];
      reward = (totalPool *
          (widget.winnerIndex < percentages.length
              ? percentages[widget.winnerIndex]
              : 0))
          .toInt();
    }

    if (reward > 0) xpManager.addGold(reward);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int playerCount = widget.hands.length;
    final int totalPool = playerCount * widget.betAmount;

    Map<int, int> prizes = {};
    List<double> percentages = [0.5, 0.25, 0.15, 0.10];
    for (int i = 0; i < playerCount; i++) {
      prizes[i] = widget.gameModeType == GameModeType.playToWin
          ? (i == widget.winnerIndex ? totalPool : 0)
          : (totalPool * (i < percentages.length ? percentages[i] : 0)).toInt();
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
                  const SizedBox(height: 8),
                  _luxTitle(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        itemCount: playerCount,
                        itemBuilder: (context, index) {
                          final gold = prizes[index] ?? 0;
                          final isWinner = index == widget.winnerIndex;
                          return _luxPlayerCard(index, isWinner, gold);
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
          image: AssetImage('assets/images/Skins/BackCard_Skins/bgLauncher.jpg'),
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
        child: Text(
          '${widget.winnerIndex == 0 ? "You" : widget.winnerName} Wins!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 1))],
          ),
        ),
      ),
    );
  }

  Widget _luxPlayerCard(int index, bool isWinner, int gold) {
    final String avatarPath = index == widget.winnerIndex
        ? widget.winnerAvatar
        : 'assets/images/Skins/AvatarSkins/CardMaster/CardMaster${index % 6 + 1}.png';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isWinner ? primaryAccent : Colors.white,
      elevation: isWinner ? 8 : 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: isWinner ? Colors.white : Colors.grey[300],
          backgroundImage: AssetImage(avatarPath),
        ),
        title: Text(
          isWinner ? 'Winner' : 'No Reward',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWinner ? Colors.white : Colors.black87),
        ),
        trailing: Text(
          '+$gold Gold',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isWinner ? Colors.white : Colors.black54),
        ),
      ),
    );
  }

  Widget _luxBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: primaryAccent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
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
