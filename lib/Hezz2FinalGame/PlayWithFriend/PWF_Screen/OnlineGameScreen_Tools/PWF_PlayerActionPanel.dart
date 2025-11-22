import 'package:flutter/material.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../../main.dart';
import '../../../Models/GameCardEnums.dart';
import '../../../Tools/TextUI/CardReamingTextUi.dart';

/// PWF = Play With Friends (fully online)
/// Same UI as your original PlayerActionPanel, but:
/// - Uses isMyTurn (no more currentPlayer == 0)
/// - Ready for online sync
/// - Calls onEmojiSelected so you can broadcast emotes
class PWF_PlayerActionPanel extends StatefulWidget {
  final bool eliminated;
  final bool isSpectating;
  final bool isAnimating;
  final bool handDealt;

  /// Is it THIS player's turn (online: currentTurnUid == myUid)
  final bool isMyTurn;

  final List<dynamic> hand;
  final String? selectedAvatar;
  final String username;

  final VoidCallback onDraw;
  final GlobalKey handKey;
  final ScrollController handScrollController;
  final List<GlobalKey> playerCardKeys;
  final Function(int) onPlayCard;
  final GameModeType gameModeType;
  final VoidCallback? onLeaveGame;

  /// Called when player selects an emoji (send to Firestore, etc.)
  final Function(String) onEmojiSelected;

  /// Turn timer length (default 15s)
  final int turnDurationSeconds;

  /// Optional callback when timer hits 0 (if you want extra logic)
  final VoidCallback? onTurnTimeout;

  const PWF_PlayerActionPanel({
    super.key,
    required this.eliminated,
    required this.isSpectating,
    required this.isAnimating,
    required this.handDealt,
    required this.isMyTurn,
    required this.hand,
    required this.selectedAvatar,
    required this.username,
    required this.onDraw,
    required this.handKey,
    required this.handScrollController,
    required this.playerCardKeys,
    required this.onPlayCard,
    required this.gameModeType,
    this.onLeaveGame,
    required this.onEmojiSelected,
    this.turnDurationSeconds = 15,
    this.onTurnTimeout,
  });

  @override
  State<PWF_PlayerActionPanel> createState() => _PWF_PlayerActionPanelState();
}

class _PWF_PlayerActionPanelState extends State<PWF_PlayerActionPanel> {
  bool _playedFiveSecSound = false;
  LottieBuilder? _selectedEmojiAnimation;
  bool _showSelectedEmoji = false;

  @override
  void didUpdateWidget(covariant PWF_PlayerActionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    // Turn just switched TO this player
    if (widget.isMyTurn && !oldWidget.isMyTurn) {
      audioManager.playSfx(
        "assets/audios/UI/SFX/Gamification_SFX/PlayerTurn.mp3",
      );
      _playedFiveSecSound = false; // reset for this turn
    }

    // Turn left this player => reset 5s flag
    if (!widget.isMyTurn && oldWidget.isMyTurn) {
      _playedFiveSecSound = false;
    }
  }

  Widget _buildStatusBanner() {
    Color bannerColor = Colors.transparent;
    String bannerText = '';

    if (widget.eliminated) {
      bannerColor = Colors.redAccent;
      bannerText = tr(context).out;
    } else if (widget.gameModeType == GameModeType.elimination &&
        widget.hand.isEmpty) {
      bannerColor = Colors.blueAccent;
      bannerText = tr(context).qual;
    } else if (widget.isMyTurn && !widget.eliminated && !widget.isSpectating) {
      bannerColor = Colors.greenAccent;
      bannerText = tr(context).turn;
    }

    if (bannerText.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: -1,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        height: 14,
        width: 10,
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(1, 1),
            )
          ],
        ),
        child: Text(
          bannerText,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    return Positioned(
      bottom: 2,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // 🔹 Top Row: Player info + Draw + Avatar + Timer
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cards remaining badge
                !widget.eliminated
                    ? CardCountBadge(
                  remaining: widget.hand.length,
                  fontSize: 14,
                )
                    : const SizedBox.shrink(),

                // Draw / Leave game buttons
                Row(
                  children: [
                    if (!widget.eliminated && !widget.isSpectating)
                      ElevatedButton(
                        onPressed: (!widget.isAnimating && widget.isMyTurn)
                            ? widget.onDraw
                            : null,
                        child: const Text(
                          'Draw',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    const SizedBox(width: 6),
                    if (widget.gameModeType == GameModeType.elimination &&
                        widget.eliminated)
                      ElevatedButton(
                        onPressed: widget.onLeaveGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(tr(context).leaveGame),
                      ),
                  ],
                ),

                // Username + Emoji + Avatar + Timer
                Row(
                  children: [
                    const SizedBox(width: 3),
                    Text(
                      widget.eliminated
                          ? tr(context).eliminated
                          : widget.isSpectating
                          ? tr(context).spectating
                          : widget.username,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.eliminated
                            ? Colors.red
                            : (widget.isSpectating
                            ? Colors.grey
                            : Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Emoji bubble
                    _showSelectedEmoji && _selectedEmojiAnimation != null
                        ? _selectedEmojiAnimation!
                        : GestureDetector(
                      onTap: () => _showEmojiDialog(context),
                      child: const Icon(
                        Icons.message,
                        color: Colors.orangeAccent,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 1),

                    // Avatar + Timer + Red alert + Status banner
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepPurple,
                          backgroundImage: widget.selectedAvatar != null
                              ? AssetImage(widget.selectedAvatar!)
                              : const AssetImage(
                            "assets/images/Skins/AvatarSkins/DefaultUser.png",
                          ),
                        ),

                        // 🔥 Turn timer for *this* player (online)
                        if (widget.isMyTurn &&
                            !widget.eliminated &&
                            !widget.isSpectating &&
                            widget.handDealt)
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TweenAnimationBuilder<double>(
                              // 15s ➜ 0
                              tween: Tween(
                                begin: widget.turnDurationSeconds.toDouble(),
                                end: 0,
                              ),
                              duration: Duration(
                                  seconds: widget.turnDurationSeconds),
                              onEnd: () {
                                if (!widget.eliminated &&
                                    !widget.isSpectating &&
                                    widget.handDealt &&
                                    widget.isMyTurn) {
                                  // Auto-draw
                                  widget.onDraw();
                                  _playedFiveSecSound = false;
                                  widget.onTurnTimeout?.call();
                                }
                              },
                              builder: (context, value, child) {
                                final bool showRedAlert =
                                    value <= 5 && value > 0;

                                // Play 5s remaining sound ONCE
                                if (showRedAlert && !_playedFiveSecSound) {
                                  _playedFiveSecSound = true;
                                  audioManager.playSfx(
                                    "assets/audios/UI/SFX/Gamification_SFX/Last5Seconds.mp3",
                                  );
                                }

                                final double progress =
                                    value / widget.turnDurationSeconds;

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 3,
                                        backgroundColor:
                                        Colors.grey.withOpacity(0.3),
                                        color: showRedAlert
                                            ? Colors.redAccent
                                            : Colors.greenAccent,
                                      ),
                                    ),
                                    if (showRedAlert)
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red.withOpacity(
                                            0.2 +
                                                0.3 *
                                                    (((value * 4) % 1)
                                                        .clamp(0.0, 1.0)),
                                          ),
                                        ),
                                      ),
                                    if (showRedAlert)
                                      Lottie.asset(
                                        'assets/animations/AnimationSFX/redAlert.json',
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),

                        _buildStatusBanner(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Hand / eliminated / spectating area
          if (widget.eliminated)
            Container(
              height: 135,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, color: Colors.red, size: 40),
                  Text(
                    tr(context).youHaveBeenEliminated,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  Text(
                    tr(context).pressLeaveGameToExit,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          else if (!widget.isSpectating)
            SizedBox(
              key: widget.handKey,
              height: 135,
              child: SingleChildScrollView(
                controller: widget.handScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(widget.hand.length, (i) {
                    if (i >= widget.playerCardKeys.length) {
                      widget.playerCardKeys.add(GlobalKey());
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: GestureDetector(
                        onTap: () => widget.onPlayCard(i),
                        child: AnimatedContainer(
                          key: widget.playerCardKeys[i],
                          duration: const Duration(milliseconds: 250),
                          width: widget.isMyTurn ? 72 : 69,
                          height: widget.isMyTurn ? 115 : 113,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                            borderRadius: BorderRadius.circular(2),
                            border: widget.isMyTurn
                                ? Border.all(
                              color: Colors.black.withOpacity(0.8),
                              width: 0.6,
                            )
                                : Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              widget.hand[i].assetName,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            )
          else
            Container(
              height: 135,
              alignment: Alignment.center,
              child: Text(
                tr(context).spectatingPressJoinGame,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  void _showEmojiDialog(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    final ScrollController scrollController = ScrollController();

    final List<Map<String, String>> emojiOptions = [
      {
        "lottie": "assets/animations/MessageAnimations/CoolEmoji.json",
        "sound": "assets/audios/UI/SFX/MessageSound/ohYeah.mp3"
      },
      {
        "lottie": "assets/animations/MessageAnimations/AngryEmoji.json",
        "sound": "assets/audios/UI/SFX/MessageSound/evilLaugh.mp3"
      },
      {
        "lottie": "assets/animations/MessageAnimations/LaughingCat.json",
        "sound": "assets/audios/UI/SFX/MessageSound/CatLaugh.mp3"
      },
      {
        "lottie": "assets/animations/MessageAnimations/cryingSmoothymon.json",
        "sound": "assets/audios/UI/SFX/MessageSound/CryingAziza.mp3"
      },
      {
        "lottie": "assets/animations/MessageAnimations/StreamOfHearts.json",
        "sound": "assets/audios/UI/SFX/MessageSound/ohYeah.mp3"
      },
    ];

    showDialog(
      context: context,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth * 0.9;
            double maxHeight = constraints.maxHeight * 0.25;

            return AlertDialog(
              backgroundColor: Colors.black87.withOpacity(0.6),
              contentPadding: const EdgeInsets.all(12),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: emojiOptions.map((emoji) {
                          return GestureDetector(
                            onTap: () {
                              final lottiePath = emoji["lottie"]!;
                              final soundPath = emoji["sound"]!;

                              audioManager.playSfx(soundPath);

                              // Local UI
                              setState(() {
                                _selectedEmojiAnimation = Lottie.asset(
                                  lottiePath,
                                  width: 55,
                                  height: 55,
                                  repeat: true,
                                );
                                _showSelectedEmoji = true;
                              });

                              // 🔥 Notify parent (for Firestore broadcast etc.)
                              widget.onEmojiSelected(lottiePath);

                              Navigator.of(context).pop();

                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  setState(() {
                                    _showSelectedEmoji = false;
                                    _selectedEmojiAnimation = null;
                                  });
                                }
                              });
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Lottie.asset(
                                emoji["lottie"]!,
                                width: 50,
                                height: 50,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Left Arrow
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          scrollController.animateTo(
                            scrollController.offset - 100,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.arrow_left,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    // Right Arrow
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          scrollController.animateTo(
                            scrollController.offset + 100,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
