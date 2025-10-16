import 'package:flutter/material.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../Models/GameCardEnums.dart';
import '../../../Tools/MessagesInGame/AnimatedMessages.dart';
import '../../../Tools/TextUI/CardReamingTextUi.dart';

class PlayerActionPanel extends StatefulWidget {
  final bool eliminated;
  final bool isSpectating;
  final bool isAnimating;
  final bool handDealt;
  final int currentPlayer;
  final List<dynamic> hand;
  final String? selectedAvatar;
  final String username;
  final Function() onDraw;
  final GlobalKey handKey;
  final ScrollController handScrollController;
  final List<GlobalKey> playerCardKeys;
  final Function(int) onPlayCard;
  final GameModeType gameModeType;
  final Function()? onLeaveGame;
  final Function(String) onEmojiSelected;

  const PlayerActionPanel({
    super.key,
    required this.eliminated,
    required this.isSpectating,
    required this.isAnimating,
    required this.handDealt,
    required this.currentPlayer,
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
  });

  @override
  _PlayerActionPanelState createState() => _PlayerActionPanelState();
}

class _PlayerActionPanelState extends State<PlayerActionPanel> {
  int? _lastTurnPlayer;
  bool _playedFiveSecSound = false;
  bool isLastFiveSeconds = false;
  LottieBuilder? _selectedEmojiAnimation;
  bool _showSelectedEmoji = false;

  @override
  void didUpdateWidget(covariant PlayerActionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    // Play sound only when the turn changes to the local player (0)
    if (widget.currentPlayer == 0 && _lastTurnPlayer != 0) {
      audioManager.playSfx(
          "assets/audios/UI/SFX/Gamification_SFX/PlayerTurn.mp3");
      _playedFiveSecSound = false; // reset sound for new turn
    }

    _lastTurnPlayer = widget.currentPlayer;
  }



  Widget _buildStatusBanner() {
    Color bannerColor = Colors.transparent;
    String bannerText = '';

    if (widget.eliminated) {
      bannerColor = Colors.redAccent;
      bannerText = 'OUT';
    } else if (widget.gameModeType == GameModeType.elimination &&
        widget.hand.isEmpty) {
      bannerColor = Colors.blueAccent;
      bannerText = 'QUAL';
    } else if (widget.currentPlayer == 0 && !widget.eliminated) {
      bannerColor = Colors.greenAccent;
      bannerText = 'TURN';
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
          // Top Row: Player info + avatar + timer
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                !widget.eliminated
                    ? CardCountBadge(
                  remaining: widget.hand.length,
                  fontSize: 14,
                )
                    : const SizedBox.shrink(),
                Row(
                  children: [
                    if (!widget.eliminated && !widget.isSpectating)
                      ElevatedButton(
                        onPressed: (!widget.isAnimating &&
                            widget.currentPlayer == 0)
                            ? widget.onDraw
                            : null,
                        child: const Text('Draw', style: TextStyle(color: Colors.black),),
                      ),
                    const SizedBox(width: 6),
                    if (widget.gameModeType == GameModeType.elimination &&
                        widget.eliminated)
                      ElevatedButton(
                        onPressed: widget.onLeaveGame,
                        style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Leave Game'),
                      ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: 3),
                    Text(
                      widget.eliminated
                          ? 'Eliminated'
                          : widget.isSpectating
                          ? 'Spectating'
                          : widget.username,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.eliminated
                            ? Colors.red
                            : (widget.isSpectating ? Colors.grey : Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),

                    _showSelectedEmoji && _selectedEmojiAnimation != null ?
                      _selectedEmojiAnimation!:

                    GestureDetector(
                      onTap:() => _showEmojiDialog(context),
                      child: Icon(
                        Icons.message,
                        color: Colors.orangeAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 1),
                    // Avatar + Timer + Red Alert Lottie
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepPurple,
                          backgroundImage: widget.selectedAvatar != null
                              ? AssetImage(widget.selectedAvatar!)
                              : const AssetImage(
                              "assets/images/Skins/AvatarSkins/DefaultUser.png"),
                        ),

                        // Timer + flash
                        if (widget.currentPlayer == 0 &&
                            !widget.eliminated &&
                            !widget.isSpectating &&
                            widget.handDealt)
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 15, end: 0),
                              duration: const Duration(seconds: 15),
                              onEnd: () {
                                if (!widget.eliminated &&
                                    !widget.isSpectating &&
                                    widget.handDealt &&
                                    widget.currentPlayer == 0) {
                                  widget.onDraw();
                                  _playedFiveSecSound = false;
                                }
                              },
                              builder: (context, value, child) {
                                final bool showRedAlert = value <= 5 && value > 0;
                                // Build the circular timer + flash effect
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator(
                                        value: value / 15,
                                        strokeWidth: 3,
                                        backgroundColor: Colors.grey.withOpacity(0.3),
                                        color: showRedAlert ? Colors.redAccent : Colors.greenAccent,
                                      ),
                                    ),
                                    if (showRedAlert)
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red.withOpacity(
                                              0.2 + 0.3 * ((value * 4) % 1)), // pulsating effect
                                        ),
                                      ),
                                    if(showRedAlert)
                                      Lottie.asset('assets/animations/AnimationSFX/redAlert.json')
                                  ],
                                );
                              },

                            ),
                          ),

                        _buildStatusBanner(), // <-- This shows TURN / QUAL / ELIM

                        // Avatar
                      ],
                    ),

                  ],
                ),
              ],
            ),
          ),



          // Cards / eliminated / spectating messages
          if (widget.eliminated)
            Container(
              height: 135,
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, color: Colors.red, size: 40),
                  Text('You have been eliminated.',
                      style: TextStyle(fontSize: 16, color: Colors.red)),
                  Text('Press "Leave Game" to exit.',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                    if (i >= widget.playerCardKeys.length)
                      widget.playerCardKeys.add(GlobalKey());
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: GestureDetector(
                        onTap: () => widget.onPlayCard(i),
                        child: AnimatedContainer(
                          key: widget.playerCardKeys[i],
                          duration: const Duration(milliseconds: 250),
                          width: widget.currentPlayer == 0 ? 72 : 69,
                          height: widget.currentPlayer == 0 ? 115 : 113,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                            borderRadius: BorderRadius.circular(2),
                            border: widget.currentPlayer == 0
                                ? Border.all(
                                color: Colors.black.withOpacity(0.8),
                                width: 0.6)
                                : Border.all(color: Colors.white, width: 2),
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
              child: const Text(
                'You are spectating. Press "Join Game" to play again.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }


  void _showEmojiDialog(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
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

        return AlertDialog(
          backgroundColor: Colors.black87.withValues(alpha: 0.6),
          content: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: emojiOptions.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    // Play sound
                    audioManager.playSfx(emoji["sound"]!);

                    // Show selected animation
                    setState(() {
                      _selectedEmojiAnimation = Lottie.asset(
                        emoji["lottie"]!,
                        width: 55,
                        height: 55,
                        repeat: true,
                      );
                      _showSelectedEmoji = true;
                    });

                    Navigator.of(context).pop(); // close dialog

                    // Hide after 2 seconds
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          _showSelectedEmoji = false;
                          _selectedEmojiAnimation = null;
                        });
                      }
                    });
                  },
                  child: Lottie.asset(emoji["lottie"]!, width: 50, height: 50),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
