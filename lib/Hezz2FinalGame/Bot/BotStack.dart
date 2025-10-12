// --------------------- PlayerCard.dart ----------------------
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../ExperieneManager.dart';
import '../Tools/Dialog/BotPlayerInfoDialog.dart';
import 'BotStack_Tools/CardCount.dart';
import 'BotStack_Tools/CardPreview.dart';
import 'BotStack_Tools/PlayerName.dart';

bool isLottieActivated = true;

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
  String? overlayAnimation;
  LottieEffect? _overlayEffect;
  bool _isOverlayActive = false;
  Timer? _reactionTimer;
  Timer? _overlayTimer;
  bool _botTurnSoundPlayed = false;

  final Map<String, String> _reactionSounds = {
    'assets/animations/MessageAnimations/AngryEmoji.json': 'assets/audios/UI/SFX/MessageSound/evilLaugh.mp3',
    'assets/animations/MessageAnimations/CoolEmoji.json': 'assets/audios/UI/SFX/MessageSound/ohYeah.mp3',
    'assets/animations/MessageAnimations/LaughingCat.json': 'assets/audios/UI/SFX/MessageSound/CatLaugh.mp3',
    'assets/animations/MessageAnimations/cryingSmoothymon.json': 'assets/audios/UI/SFX/MessageSound/CryingAziza.mp3',
    'assets/animations/MessageAnimations/StreamOfHearts.json': 'assets/audios/UI/SFX/HeartsSound.mp3',
  };

  final List<String> _specialLotties = [
    'assets/animations/MessageAnimations/MoneyEmoji.json',
    'assets/animations/MessageAnimations/Snake.json',
    'assets/animations/MessageAnimations/Bunny.json',
    'assets/animations/MessageAnimations/duck.json',
    'assets/animations/MessageAnimations/RunningBird.json'
  ];

  @override
  void initState() {
    super.initState();
    _startRandomReactions();
  }

  void _startRandomReactions() {
    if (!isLottieActivated) return;
    final random = Random();
    _reactionTimer = Timer(
      Duration(milliseconds: 4500 + random.nextInt(10000)),
      _playRandomReaction,
    );
  }

  void _playRandomReaction() {
    if (!mounted || !isLottieActivated) return;
    final random = Random();
    final keys = _reactionSounds.keys.toList();
    final selectedAnimation = keys[random.nextInt(keys.length)];

    setState(() {
      reactionAnimation = selectedAnimation;
    });

    final audioManager = Provider.of<AudioManager>(context, listen: false);
    final soundPath = _reactionSounds[selectedAnimation];
    if (soundPath != null && isLottieActivated) {
      audioManager.playSfx(soundPath);
    }

    int animDuration = 1500 + random.nextInt(1500);
    _reactionTimer = Timer(Duration(milliseconds: animDuration), () {
      if (!mounted || !isLottieActivated) return;
      setState(() => reactionAnimation = null);

      _reactionTimer = Timer(
        Duration(milliseconds: 6000 + random.nextInt(18000)),
        _playRandomReaction,
      );
    });
  }

  void toggleLottie(bool value) {
    isLottieActivated = value;
    if (!isLottieActivated) {
      _reactionTimer?.cancel();
      setState(() => reactionAnimation = null);
    } else {
      _startRandomReactions();
    }
  }

  void _showOverlayAnimation(String animationPath) async {
    final effect = _lottieEffects[animationPath];
    if (effect == null) return;

    final expManager = Provider.of<ExperienceManager>(context, listen: false);
    final bool success = await expManager.spendGold(effect.cost);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Not enough gold to use this animation (${effect.cost} 💰)!"),
        ),
      );
      return; // stop here if not enough gold
    }

    // ✅ Continue playing if cost paid
    _overlayTimer?.cancel();
    setState(() {
      overlayAnimation = animationPath;
      _overlayEffect = effect;
      _isOverlayActive = true;
    });

    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          overlayAnimation = null;
          _isOverlayActive = false;
          _overlayEffect = null;
        });
      }
    });

    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playSfx(effect.sound);
  }


  @override
  void dispose() {
    _reactionTimer?.cancel();
    _overlayTimer?.cancel();
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

    if (widget.bot > 0 && widget.isTurn && !_botTurnSoundPlayed) {
      final audioManager = Provider.of<AudioManager>(context, listen: false);
      _botTurnSoundPlayed = true;
      audioManager.playSfx("assets/audios/UI/SFX/Gamification_SFX/Bot'sTurnSound.mp3");
    }

    if (!widget.isTurn && _botTurnSoundPlayed) {
      _botTurnSoundPlayed = false;
    }
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          key: widget.playerKey,
          width: 85,
          height: 184,
          padding: const EdgeInsets.only(top: 30, left: 4, right: 4, bottom: 4),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.black.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(1, 2),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlayerName(name: info.name, maxWidth: 60),

              const SizedBox(height: 2),
              if (!widget.isEliminated)
                _AnimatedCardContainer(
                  isActive: _isOverlayActive,
                  lottieEffect: _overlayEffect,
                  child: CardPreview(
                    hand: widget.hand,
                    vertical: widget.vertical,
                    scale: 1.4,
                    isEliminated: widget.isEliminated,
                    isQualified: widget.isQualified,
                  ),
                ),
              const SizedBox(height: 4),
              if (!widget.isEliminated) CardCount(count: widget.cardCount),
              const SizedBox(height: 2,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Wrap(
                              spacing: 2,
                              runSpacing: 2,
                              alignment: WrapAlignment.center,
                              children: _specialLotties.map((animationPath) {
                                final effect = _lottieEffects[animationPath];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _showOverlayAnimation(animationPath);
                                  },
                                  child: Wrap(
                                    children: [
                                      Lottie.asset(animationPath, width: 80, height: 80, repeat: true),
                                      Column(
                                        children: [
                                          Text(
                                            "${effect?.cost ?? 0}",
                                            style: const TextStyle(
                                              color: Colors.amberAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Image.asset("assets/UI/Icons/Gamification/GoldInGame_Icon.png", height: 10, width: 10,),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.card_giftcard,color: Colors.white,size: 16,),
                  ),

                  GestureDetector(
                    onTap: () {
                      final audioManager = Provider.of<AudioManager>(context, listen: false);
                      audioManager.playEventSound('sandClick');
                      setState(() {
                        isLottieActivated = !isLottieActivated;
                      });
                    },
                    child: Icon(
                      isLottieActivated ? Icons.volume_up : Icons.volume_mute_outlined,
                      color: isLottieActivated ? Colors.orangeAccent : Colors.grey,
                      size: 17,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),

        Positioned(
          top: -22,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
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
                        backgroundColor: statusColor.withValues(alpha: 0.2),
                        strokeWidth: 3,
                      );
                    },
                  ),
                ),
              CircleAvatar(
                radius: widget.isTurn ? 30 : 26,
                backgroundColor: Colors.black.withValues(alpha: 0.2),
                backgroundImage: AssetImage(info.avatarPath),
              ),
              if (isLottieActivated && reactionAnimation != null)
                Positioned(
                  top: 20,
                  child: SizedBox(
                    width: 58,
                    height: 58,
                    child: Lottie.asset(
                      reactionAnimation!,
                      key: ValueKey(reactionAnimation),
                      repeat: false,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
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
                          color: Colors.black.withValues(alpha: 0.3),
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

        if (overlayAnimation != null)
          Positioned(
            bottom: 40,
            child: SizedBox(
              width: 75,
              height: 75,
              child: Lottie.asset(
                overlayAnimation!,
                repeat: false,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------- LottieEffect map ----------------
final Map<String, LottieEffect> _lottieEffects = {
  'assets/animations/MessageAnimations/Bunny.json': LottieEffect(
    color: Colors.white,
    sound: 'assets/audios/UI/SFX/MessageSound/BunnyFunnyMessage.mp3',
    scale: 1.1,
    rotation: 0.05,
    cost: 500, // 💰
  ),
  'assets/animations/MessageAnimations/duck.json': LottieEffect(
    color: Colors.deepOrangeAccent,
    sound: 'assets/audios/UI/SFX/MessageSound/duckQwarkMessage.mp3',
    scale: 1.08,
    rotation: 0.03,
    cost: 450,
  ),
  'assets/animations/MessageAnimations/RunningBird.json': LottieEffect(
    color: Colors.blueAccent,
    sound: 'assets/audios/UI/SFX/MessageSound/kaaaaakaaaBirdMessage.mp3',
    scale: 1.12,
    rotation: 0.07,
    cost: 300,
  ),
  'assets/animations/MessageAnimations/MoneyEmoji.json': LottieEffect(
    color: Colors.yellowAccent,
    sound: 'assets/audios/UI/SFX/MessageSound/MoneyEmojiMessage.mp3',
    scale: 1.3,
    rotation: 0.08,
    cost: 10000,
  ),
  'assets/animations/MessageAnimations/Snake.json': LottieEffect(
    color: Colors.green,
    sound: 'assets/audios/UI/SFX/MessageSound/SnakeHissMessage.mp3',
    scale: 1.5,
    rotation: 0.09,
    cost: 2000,
  ),
};

class LottieEffect {
  final Color color;
  final String sound;
  final double scale;
  final double rotation;
  final int cost; // 💰 cost in gold or experience

  LottieEffect({
    required this.color,
    required this.sound,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.cost = 0, // default 0 if free

  });
}

// ---------------- AnimatedCardContainer ----------------
class _AnimatedCardContainer extends StatefulWidget {
  final bool isActive;
  final LottieEffect? lottieEffect;
  final Widget child;

  const _AnimatedCardContainer({
    required this.isActive,
    this.lottieEffect,
    required this.child,
  });

  @override
  State<_AnimatedCardContainer> createState() => _AnimatedCardContainerState();
}

class _AnimatedCardContainerState extends State<_AnimatedCardContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _updateAnimations();
    if (widget.isActive) _controller.forward();
  }

  void _updateAnimations() {
    final effect = widget.lottieEffect;
    _scaleAnimation = Tween<double>(begin: 1.0, end: effect?.scale ?? 1.08)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _rotationAnimation = Tween<double>(begin: 0.0, end: effect?.rotation ?? 0.03)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _glowAnimation = ColorTween(
      begin: Colors.transparent,
      end: effect?.color.withOpacity(0.6) ?? Colors.yellowAccent.withOpacity(0.6),
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _AnimatedCardContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimations();
    if (widget.isActive) _controller.forward();
    else _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(_scaleAnimation.value)
            ..rotateZ(_rotationAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: widget.isActive
                  ? Border.all(color: _glowAnimation.value ?? Colors.yellowAccent, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: _glowAnimation.value ?? Colors.transparent,
                  blurRadius: 18,
                  spreadRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}