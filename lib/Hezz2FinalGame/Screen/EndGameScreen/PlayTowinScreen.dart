import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/MainScreenIndex.dart';
import 'package:provider/provider.dart';
import '../../../ExperieneManager.dart';
import '../../../Manager/HelperClass/FlyingRewardManager.dart';
import '../../../Manager/HelperClass/RewardDimScreen.dart';
import '../../../widgets/userStatut/userStatus.dart';
import 'package:lottie/lottie.dart';
import '../../../Hezz2FinalGame/Models/Cards.dart';

class PlayToWinEndPage extends StatefulWidget {
  final List<List<PlayingCard>> hands;
  final int winnerIndex;
  final int currentRound;
  final int betAmount;
  final String winnerName;
  final String winnerAvatar;

  const PlayToWinEndPage({
    super.key,
    required this.hands,
    required this.winnerIndex,
    required this.currentRound,
    required this.betAmount,
    required this.winnerName,
    required this.winnerAvatar,
  });

  @override
  State<PlayToWinEndPage> createState() => _PlayToWinEndPageState();
}

class _PlayToWinEndPageState extends State<PlayToWinEndPage>
    with TickerProviderStateMixin {
  final GlobalKey goldKeyEnd = GlobalKey();
  final GlobalKey gemKeyEnd = GlobalKey();
  final GlobalKey xpKeyEnd = GlobalKey();
  bool _rewardGiven = false;
  late AnimationController _winAnimController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _winAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = CurvedAnimation(
      parent: _winAnimController,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _winAnimController.forward();
      if (!_rewardGiven) {
        _giveReward();
        _rewardGiven = true;
      }
    });
  }

  void _giveReward() {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    final int totalPool = widget.hands.length * widget.betAmount;
    int reward = widget.winnerIndex == 0 ? totalPool : 0;

    if (reward > 0) {
      RewardDimScreen.show(
        context,
        start: const Offset(200, 400),
        endKey: goldKeyEnd,
        amount: reward,
        type: RewardType.gold,
      );
      xpManager.addWin(widget.hands.length);
    }
  }

  @override
  void dispose() {
    _winAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWinner = widget.winnerIndex == 0;
    final String winnerLabel = isWinner ? "🎉 You Win!" : "${widget.winnerName} Wins!";

    return Scaffold(
      body: Stack(
        children: [
          // 🌌 Animated Background with sigma blur
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/UI/BackgroundImage/EndScreenBackground.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.black.withOpacity(0.35)),
              ),
            ),
          ),

          // 🎊 Confetti Animation
          Align(
            alignment: Alignment.topCenter,
            child: Lottie.asset(
              'assets/animations/Win/Confetti2.json',
              repeat: false,
              height: 250,
            ),
          ),

          // ✨ Floating sparkles or particles (optional)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Lottie.asset(
              'assets/animations/Win/Confetti4.json',
              repeat: true,
              height: 120,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                UserStatusBar(
                  goldKey: goldKeyEnd,
                  gemsKey: gemKeyEnd,
                  xpKey: xpKeyEnd,
                  showPlusButton: false,
                ),
                const SizedBox(height: 30),

                // 🏆 Animated Winner Banner with glow
                ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 34),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.7),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Text(
                        winnerLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ),


                const SizedBox(height: 40),

                // 🧩 Player Cards
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.hands.length,
                    itemBuilder: (context, index) {
                      final isWinner = index == widget.winnerIndex;
                      final gold =
                      isWinner ? widget.betAmount * widget.hands.length : 0;
                      return AnimatedPlayerCard(
                          index: index,
                          winner: isWinner,
                          gold: gold,
                          winnerAvatar: widget.winnerAvatar,
                          winnerIndex: widget.winnerIndex,
                        );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 🔙 Back Button

                  AnimatedBackButton(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MainScreen()),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🎮 Player Card Widget
class AnimatedPlayerCard extends StatelessWidget {
  final int index;
  final bool winner;
  final int gold;
  final String winnerAvatar;
  final int winnerIndex;

  const AnimatedPlayerCard({
    super.key,
    required this.index,
    required this.winner,
    required this.gold,
    required this.winnerAvatar,
    required this.winnerIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: winner
              ? [Colors.orangeAccent, Colors.deepOrangeAccent]
              : [Colors.white.withOpacity(0.9), Colors.grey[300]!],
        ),
        boxShadow: [
          if (winner)
            BoxShadow(
              color: Colors.orangeAccent.withOpacity(0.6),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundImage: AssetImage(
              winner
                  ? winnerAvatar
                  : 'assets/images/Skins/AvatarSkins/CardMaster/CardMaster${index % 6 + 1}.png',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              winner ? "🏆 Winner" : "Player ${index + 1}",
              style: TextStyle(
                color: winner ? Colors.white : Colors.black87,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '+$gold',
            style: TextStyle(
              color: winner ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ⏪ Back Button
class AnimatedBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const AnimatedBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        margin: const EdgeInsets.symmetric(horizontal: 60),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orangeAccent.withOpacity(0.6),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Back to Lobby',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
