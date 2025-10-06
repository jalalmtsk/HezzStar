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
                        child: const Text('Draw'),
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
                    const SizedBox(width: 7),
                    AnimatedLottieEmojiBubble(
                      onSelected: widget.onEmojiSelected,
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

                                // Play ticking sound at 5 seconds remaining, once
                                if (!_playedFiveSecSound && value <= 5 && value > 0) {
                                  audioManager.playSfx(
                                      "assets/audios/UI/SFX/Gamification_SFX/TimerTicking.mp3");
                                  _playedFiveSecSound = true; // mark as played
                                }

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
                                  ],
                                );
                              },

                            ),
                          ),
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
                          width: widget.currentPlayer == 0 ? 70 : 69,
                          height: widget.currentPlayer == 0 ? 114 : 113,
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
}
