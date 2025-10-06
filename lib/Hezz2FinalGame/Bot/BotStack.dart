import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import '../Tools/Dialog/BotPlayerInfoDialog.dart';


bool isLottieActivated = true; // default ON


class PlayerCard extends StatefulWidget {
  final int bot;
  final bool vertical;
  final bool isEliminated;
  final bool isQualified;
  final bool isTurn;
  final bool handDealt;
  final int cardCount;
  final List<dynamic> hand;
  final Key? playerKey;

  const PlayerCard({
    super.key,
    required this.bot,
    required this.vertical,
    required this.isEliminated,
    required this.isQualified,
    required this.isTurn,
    required this.handDealt,
    required this.cardCount,
    required this.hand,
    this.playerKey,
  });

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> with TickerProviderStateMixin {
  String? reactionAnimation;
  Timer? _reactionTimer;

  // Your Lottie JSON files
  final List<String> _reactions = [
    'assets/animations/MessageAnimations/AngryEmoji.json',
    'assets/animations/MessageAnimations/CoolEmoji.json',
    'assets/animations/MessageAnimations/LaughingCat.json',
    'assets/animations/MessageAnimations/MoneyEmoji.json',
    'assets/animations/MessageAnimations/StreamOfHearts.json',
  ];

  @override
  void initState() {
    super.initState();
    _startRandomReactions();
  }

  void _startRandomReactions() {
    final random = Random();

    // Start the first reaction after a random delay (1-5 seconds)
    Future.delayed(Duration(milliseconds: 1000 + random.nextInt(4000)), _playRandomReaction);
  }

  void _playRandomReaction() {
    if (!mounted) return;

    final random = Random();
    setState(() {
      reactionAnimation = _reactions[random.nextInt(_reactions.length)];
    });

    // Animation duration random between 1.5s - 3s
    int animDuration = 1500 + random.nextInt(1500);
    Future.delayed(Duration(milliseconds: animDuration), () {
      if (!mounted) return;
      setState(() => reactionAnimation = null);

      // Schedule next reaction with random interval (5-20 seconds)
      Future.delayed(Duration(milliseconds: 5000 + random.nextInt(20000)), _playRandomReaction);
    });
  }

  @override
  void dispose() {
    _reactionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = BotDetailsPopup.getBotInfo(widget.bot);

    Color borderColor = Colors.white70;
    Color statusColor = Colors.white;
    String statusText = '';

    if (widget.isEliminated) {
      borderColor = Colors.redAccent;
      statusColor = Colors.redAccent;
      statusText = 'OUT';
    } else if (widget.isQualified) {
      borderColor = Colors.blueAccent;
      statusColor = Colors.blueAccent;
      statusText = 'QUAL';
    } else if (widget.isTurn) {
      borderColor = Colors.greenAccent;
      statusColor = Colors.greenAccent;
      statusText = 'TURN';
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Main container
        Container(
          key: widget.playerKey,
          width: 85,
          height: 170,
          padding: const EdgeInsets.only(top: 36, left: 6, right: 6, bottom: 6),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(1, 2),
              )
            ],
          ),
          child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 6),
        _PlayerName(name: info.name, maxWidth: 60),
        const SizedBox(height: 6),

        // Show cards only if not eliminated
        if (!widget.isEliminated)
          _CardPreview(
            hand: widget.hand,
            vertical: widget.vertical,
            scale: 1.3,
            isEliminated: widget.isEliminated,
            isQualified: widget.isQualified,
          ),

        const SizedBox(height: 4),

        // Show card count only if not eliminated
        if (!widget.isEliminated)
          _CardCount(count: widget.cardCount),
      ],
    ),
    ),

        // Avatar outside container
        Positioned(
          top: -22,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Turn indicator
              if (widget.isTurn && widget.handDealt)
                SizedBox(
                  width: 64,
                  height: 64,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1, end: 0),
                    duration: const Duration(seconds: 10),
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        color: statusColor,
                        backgroundColor: statusColor.withOpacity(0.2),
                        strokeWidth: 3,
                      );
                    },
                  ),
                ),

              // Avatar
              CircleAvatar(
                radius: widget.isTurn ? 30 : 26,
                backgroundColor: Colors.black.withOpacity(0.2),
                backgroundImage: AssetImage(info.avatarPath),
              ),

              // Random reaction animation
              if(isLottieActivated)
              Positioned(
                top: 20,
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: reactionAnimation != null
                      ? Lottie.asset(
                    reactionAnimation!,
                    key: ValueKey(reactionAnimation),
                    repeat: false,
                    fit: BoxFit.contain,
                  )
                      : const SizedBox.shrink(), // keep structure stable
                ),
              ),


              // Status badge
              if (statusText.isNotEmpty)
                Positioned(
                  top: -14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        )
                      ],
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------ Other Widgets ---------------------

class _CardPreview extends StatelessWidget {
  final List<dynamic> hand;
  final bool vertical;
  final double scale;
  final bool isEliminated;
  final bool isQualified;

  const _CardPreview({
    required this.hand,
    required this.vertical,
    this.scale = 1.0,
    this.isEliminated = false,
    this.isQualified = false,
  });

  @override
  Widget build(BuildContext context) {
    double cardWidth = (vertical ? 38 : 45) * scale;
    double cardHeight = (vertical ? 54 : 60) * scale;

    return SizedBox(
      width: cardWidth + 10,
      height: cardHeight,
      child: Stack(
        children: [
          for (int i = 0; i < hand.length && i < 3; i++)
            Positioned(
              left: i * 6,
              top: i * 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        )
                      ],
                    ),
                    child: Image.asset(
                      hand.isNotEmpty
                          ? hand.first.backAsset(context)
                          : 'assets/images/cards/backCard.png',
                      width: cardWidth,
                      height: cardHeight,
                      fit: BoxFit.cover,
                      color: (isEliminated || isQualified)
                          ? Colors.grey.withOpacity(0.6)
                          : null,
                      colorBlendMode: BlendMode.saturation,
                    ),
                  ),
                  if (isEliminated)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.red.withOpacity(0.4),
                        child: const Text(
                          "ELIMINATED",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (isQualified)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.blue.withOpacity(0.4),
                        child: const Text(
                          "QUALIFIED",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


class _CardCount extends StatelessWidget {
  final int count;
  const _CardCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      "$count cards",
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 2,
            color: Colors.black,
            offset: Offset(1, 1),
          )
        ],
      ),
    );
  }
}

class _PlayerName extends StatelessWidget {
  final String name;
  final double maxWidth;

  const _PlayerName({required this.name, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))
          ],
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final isOverflow = textPainter.width > maxWidth;

    if (isOverflow) {
      return SizedBox(
        width: maxWidth,
        height: 16,
        child: Marquee(
          text: name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))
            ],
          ),
          scrollAxis: Axis.horizontal,
          blankSpace: 20,
          velocity: 25,
          pauseAfterRound: const Duration(seconds: 5),
        ),
      );
    } else {
      return SizedBox(
        width: maxWidth,
        height: 16,
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))
            ],
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
