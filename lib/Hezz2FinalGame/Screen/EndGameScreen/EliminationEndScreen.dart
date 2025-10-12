import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/MainScreenIndex.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../ExperieneManager.dart';
import '../../../Manager/HelperClass/FlyingRewardManager.dart';
import '../../../Manager/HelperClass/RewardDimScreen.dart';
import '../../../widgets/userStatut/userStatus.dart';
import '../../../Hezz2FinalGame/Models/Cards.dart';
import '../../../Hezz2FinalGame/Models/GameCardEnums.dart';

class EliminationEndPage extends StatefulWidget {
  final List<List<PlayingCard>> hands;
  final int winnerIndex;
  final int currentRound;
  final int betAmount;
  final String winnerName;
  final String winnerAvatar;

  const EliminationEndPage({
    super.key,
    required this.hands,
    required this.winnerIndex,
    required this.currentRound,
    required this.betAmount,
    required this.winnerName,
    required this.winnerAvatar,
  });

  @override
  State<EliminationEndPage> createState() => _EliminationEndPageState();
}

class _EliminationEndPageState extends State<EliminationEndPage>
    with TickerProviderStateMixin {
  final GlobalKey goldKeyElim = GlobalKey();
  final GlobalKey gemsKeyElim = GlobalKey();
  final GlobalKey xpKeyElim = GlobalKey();
  bool _rewardGiven = false;
  late AnimationController _introController;
  late AnimationController _fadeController;
  late Animation<double> _introAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _introAnim = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutBack,
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _introController.forward();
      Future.delayed(const Duration(milliseconds: 400), () {
        _fadeController.forward();
      });

      if (!_rewardGiven) {
        _giveReward();
        _rewardGiven = true;
      }
    });
  }

  void _giveReward() {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    final int n = widget.hands.length;
    final int totalPool = n * widget.betAmount;

    // Weighted elimination payout: winner gets most
    List<int> weights = List.generate(n, (i) => 1 << (n - i - 1));
    int sumWeights = weights.reduce((a, b) => a + b);
    int reward =
    (totalPool * weights[widget.winnerIndex] / sumWeights).toInt();

    if (reward > 0) {
      RewardDimScreen.show(
        context,
        start: const Offset(200, 400),
        endKey: goldKeyElim,
        amount: reward,
        type: RewardType.gold,
      );

      if (widget.winnerIndex == 0) {
        xpManager.addWin(widget.hands.length);
      }
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWinner = widget.winnerIndex == 0;
    final String winnerText = isWinner ? "You Survived!" : "${widget.winnerName} Survived!";

    return Scaffold(
      body: Stack(
        children: [
          // 🔥 Background with motion blur and glowing pulse
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C0A0A), Color(0xFF0D0D0D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),

          // ⚡ Animated energy pulse
          Align(
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Lottie.asset(
                'assets/lottie/pulse_red.json',
                repeat: true,
                height: 300,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                UserStatusBar(
                  goldKey: goldKeyElim,
                  gemsKey: gemsKeyElim,
                  showPlusButton: false,
                  xpKey: xpKeyElim,
                ),

                const SizedBox(height: 30),

                // 🏁 Winner Banner Animation
                ScaleTransition(
                  scale: _introAnim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [Colors.redAccent, Colors.black87],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      winnerText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: widget.hands.length,
                      itemBuilder: (context, index) {
                        final isWinner = index == widget.winnerIndex;
                        return _eliminationCard(index, isWinner);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _backButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eliminationCard(int index, bool isWinner) {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    final avatarPath = isWinner
        ? widget.winnerAvatar
        : 'assets/images/Skins/AvatarSkins/CardMaster/CardMaster${index % 6 + 1}.png';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isWinner
              ? [Colors.redAccent, Colors.black87]
              : [Colors.grey.shade900, Colors.black54],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          if (isWinner)
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.6),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(avatarPath),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isWinner ? "Survivor" : "Eliminated",
              style: TextStyle(
                color: isWinner ? Colors.white : Colors.redAccent.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (isWinner)
            const Icon(Icons.local_fire_department, color: Colors.amberAccent, size: 30)
          else
            const Icon(Icons.close, color: Colors.redAccent, size: 28),
        ],
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 60),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Back to Lobby',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
