// file: card_game_launcher.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hezzstar/Hezz2FinalGame/Screen/GameScreen.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:hezzstar/widgets/userStatut/userStatus.dart';
import '../../../ExperieneManager.dart';
import 'GameLauncher_Tools/SearchingPopup.dart';

class CardGameLauncher extends StatefulWidget {
  final int botCount;
  const CardGameLauncher({super.key, required this.botCount});

  @override
  State<CardGameLauncher> createState() => _CardGameLauncherState();
}

class _CardGameLauncherState extends State<CardGameLauncher>
    with TickerProviderStateMixin {
  final GlobalKey goldKey = GlobalKey(); // <-- add this
  final GlobalKey gemKey = GlobalKey(); // <-- add this
  final GlobalKey xpKey = GlobalKey(); // <-- add this

  GameModeType gameMode = GameModeType.playToWin;
  int handSize = 5;
  int selectedBetIndex = 0;

  late PageController _pageController;
  late AnimationController _pulseController; // for pulses
  late AnimationController _handEntranceController; // animate hand entrance
  late Animation<double> _pulseAnimation;

  // Bets list (kept as you provided)
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

  final List<Map<String, dynamic>> handOptions = [
    {"label": "Quick", "size": 3},
    {"label": "Medium", "size": 5},
    {"label": "Long", "size": 7},
  ];

  final List<Map<String, dynamic>> gameModes = [
    {"label": "Play to Win", "type": GameModeType.playToWin},
    {"label": "Elimination", "type": GameModeType.elimination},
  ];

  // dynamic colors based on mode
  Color primaryAccent = Colors.orangeAccent;
  Color secondaryAccent = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.66, initialPage: selectedBetIndex);

    _pulseController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _handEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    // initial theme
    _applyThemeForMode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _handEntranceController.dispose();
    super.dispose();
  }

  void _applyThemeForMode() {
    setState(() {
      if (gameMode == GameModeType.playToWin) {
        primaryAccent = Colors.orangeAccent;
        secondaryAccent = Colors.deepOrange;
      } else {
        primaryAccent = Colors.redAccent;
        secondaryAccent = Colors.black87;
      }
    });
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
          // Background image with tinted overlay that animates with mode
          Positioned.fill(child: _animatedBackground()),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),
                // UserStatusBar (keeps its own layout) — you already have a widget for it
                 UserStatusBar(goldKey: goldKey, gemsKey: gemKey, xpKey: xpKey,),
                const SizedBox(height: 28),
                _luxTitle(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.28),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 14),
                              _gameModeToggleRow(),
                              const SizedBox(height: 14),
                              _handSizeSelectorRow(),
                              const SizedBox(height: 10),
                              // animated hand preview
                              SizedBox(
                                height: 110,
                                child: Center(child: _animatedHandPreview()),
                              ),
                              const SizedBox(height: 6),
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

  // Animated background that changes with game mode
  Widget _animatedBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/Skins/BackCard_Skins/bgLauncher.jpg'),
          fit: BoxFit.cover,
          repeat: ImageRepeat.noRepeat,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryAccent.withOpacity(0.16),
            secondaryAccent.withOpacity(0.12),
            Colors.black.withOpacity(0.18),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        // subtle vignette overlay
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.6),
            radius: 1.0,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
            ],
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }

  // Title at top
  Widget _luxTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [primaryAccent.withOpacity(0.9), secondaryAccent.withOpacity(0.9)]),
          boxShadow: [
            BoxShadow(color: primaryAccent.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🎴 Lobby",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 1))],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${widget.botCount + 1} P",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            // mode indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: gameMode == GameModeType.playToWin ? Colors.white10 : Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                gameMode == GameModeType.playToWin ? "Mode: Play" : "Mode: Elim.",
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===== GAME MODE TOGGLE =====
  Widget _gameModeToggleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: gameModes.map((mode) {
        bool isSelected = gameMode == mode["type"];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                gameMode = mode["type"];
                _applyThemeForMode();
                // animate hand entrance again for visual feedback
                _handEntranceController.forward(from: 0.0);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [primaryAccent, secondaryAccent])
                    : LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  if (isSelected) BoxShadow(color: primaryAccent.withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mode["label"],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// ===== HAND SIZE SELECTOR =====
  Widget _handSizeSelectorRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: handOptions.map((opt) {
        bool isSelected = handSize == opt["size"];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () {
              setState(() {
                handSize = opt["size"];
                // small entrance animation
                _handEntranceController.forward(from: 0.0);
              });
            },
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
                boxShadow: isSelected
                    ? [BoxShadow(color: primaryAccent.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black45, blurRadius: 6, offset: const Offset(0, 3))],
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

  /// ===== HAND PREVIEW (Animated / Fanned / Flip-on-tap) =====
  Widget _animatedHandPreview() {
    // make sure cards don't overflow — allow horizontal scroll if needed
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCardWidth = (constraints.maxWidth / handSize) * 0.9;
        final cardWidth = max(36.0, min(60.0, maxCardWidth)); // 36..60 px
        final cardHeight = cardWidth * 1.4;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AnimatedBuilder(
            animation: _handEntranceController,
            builder: (context, _) {
              double entrance = Curves.elasticOut.transform(_handEntranceController.value);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(handSize, (index) {
                  // fan angle centered
                  double centerIndex = (handSize - 1) / 2;
                  double baseAngle = (index - centerIndex) * 0.09; // radians
                  double tilt = baseAngle * entrance; // animate from 0 -> baseAngle

                  final xpManager = Provider.of<ExperienceManager>(context, listen: false);

                  // slight vertical offset so center sits higher
                  double yOffset = ( (centerIndex - (index)).abs() ) * 2.0 * (1 - entrance);

                  return Transform.translate(
                    offset: Offset(0, yOffset),
                    child: Transform.rotate(
                      angle: tilt,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: AnimatedCard(
                            key: ValueKey('card_$handSize\_$index'),
                            width: cardWidth,
                            height: cardHeight,
                              backImagePath: xpManager.selectedCard != null
                                  ? xpManager.selectedCard!
                                  :  "assets/images/cards/backCard.png"  ,
                            frontBuilder: (ctx) => _cardFrontPreview(ctx, index, cardWidth, cardHeight),
                            accent: primaryAccent,
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
      },
    );
  }

  // Example front face widget for a card preview (you can customize to show rank/suit or an avatar)
  Widget _cardFrontPreview(BuildContext ctx, int index, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(colors: [primaryAccent.withOpacity(0.9), secondaryAccent.withOpacity(0.9)]),
        boxShadow: [BoxShadow(color: primaryAccent.withOpacity(0.35), blurRadius: 8, offset: const Offset(2, 3))],
      ),
      child: Center(
        child: Text(
          "${index + 1}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  /// ===== BET CAROUSEL =====
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 280 : 240,
                height: isSelected ? 320 : 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  image: DecorationImage(
                    image: AssetImage(isSelected
                        ? 'assets/UI/Containers/BetContainer_Active.png'
                        : 'assets/UI/Containers/BetContainer_Inactive.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    if (isSelected) BoxShadow(color: primaryAccent.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${_formatGold(bet['gold'])} G",
                      style: TextStyle(
                        fontSize: isSelected ? 38 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellowAccent,
                        shadows: const [Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "+${bet['xp']} XP",
                      style: TextStyle(
                        fontSize: isSelected ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        shadows: const [Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// ===== START BUTTON =====
  Widget _premiumStartButton(ExperienceManager expManager) {
    final bet = bets[selectedBetIndex];
    final enough = expManager.gold >= bet['gold'];
    final label = gameMode == GameModeType.playToWin ? "Start Match" : "Start Elimination";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: enough
                  ? () async {
                // Spend gold + XP, popup searching, navigate
                expManager.spendGold(bet['gold']);
                expManager.addExperience(bet['xp']);
                await SearchingPopup.show(context, widget.botCount);

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
              }
                  : () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough Gold!')));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: primaryAccent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
                  border: Border.all(color: enough ? Colors.yellowAccent : Colors.white24, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Icon(Icons.play_arrow_rounded, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    if (!enough)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.lock, color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.6),
                boxShadow: [BoxShadow(color: primaryAccent.withOpacity(0.45), blurRadius: 8, spreadRadius: 1)],
                border: Border.all(color: Colors.yellowAccent, width: 2),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.exit_to_app, color: Colors.yellowAccent, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable animated card that flips on tap.
/// - `backImagePath` shows the back face
/// - `frontBuilder` builds the front face (customizable)
class AnimatedCard extends StatefulWidget {
  final double width;
  final double height;
  final String backImagePath;
  final WidgetBuilder frontBuilder;
  final Color accent;

  const AnimatedCard({
    super.key,
    required this.width,
    required this.height,
    required this.backImagePath,
    required this.frontBuilder,
    required this.accent,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipController.isAnimating) return;
    if (_showFront) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final t = _flipController.value;
          final ang = t * pi; // 0 -> pi
          final isFrontVisible = t > 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(ang),
            child: isFrontVisible ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: widget.accent.withOpacity(0.25), blurRadius: 8, offset: const Offset(2, 3))],
        ),
        child: Image.asset(
          widget.backImagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFront() {
    // When front-side shows, we flip the content horizontally to keep it readable (because we rotated)
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi), // mirror front so it reads correctly
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.frontBuilder(context),
        ),
      ),
    );
  }
}
