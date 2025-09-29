import 'package:flutter/material.dart';

import '../../../Models/GameCardEnums.dart';
import '../../../Tools/MessagesInGame/AnimatedMessages.dart';
import '../../../Tools/TextUI/CardReamingTextUi.dart';

class PlayerActionPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 2,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Top Row: Player info + avatar + timer
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                !eliminated ? CardCountBadge(remaining: hand.length, fontSize: 14) : SizedBox.shrink(),
                Row(
                  children: [
                    if (!eliminated && !isSpectating)
                      ElevatedButton(
                        onPressed: (!isAnimating && currentPlayer == 0) ? onDraw : null,
                        child: const Text('Draw'),
                      ),
                    const SizedBox(width: 6),
                    if (gameModeType == GameModeType.elimination && eliminated)
                      ElevatedButton(
                        onPressed: onLeaveGame,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Leave Game'),
                      ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: 3),
                    Text(
                      eliminated
                          ? 'Eliminated'
                          : isSpectating
                          ? 'Spectating'
                          : username,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: eliminated ? Colors.red : (isSpectating ? Colors.grey : Colors.white),
                      ),
                    ),
                    const SizedBox(width: 7),
                    AnimatedLottieEmojiBubble(
                      onSelected: onEmojiSelected,
                    ),
                    const SizedBox(width: 1),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (currentPlayer == 0 && !eliminated && !isSpectating && handDealt)
                          SizedBox(
                            width: 55,
                            height: 55,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 1, end: 0),
                              duration: const Duration(seconds: 15),
                              onEnd: () {
                                // Automatically draw a card when timer finishes
                                if (!eliminated && !isSpectating && handDealt && currentPlayer == 0) {
                                  onDraw();
                                }
                              },
                              builder: (context, value, child) {
                                return CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 3,
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                  color: Colors.greenAccent,
                                );
                              },
                            )

                          ),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepPurple,
                          backgroundImage: selectedAvatar != null
                              ? AssetImage(selectedAvatar!)
                              : const AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Cards / eliminated / spectating messages
          if (eliminated)
            Container(
              height: 135,
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, color: Colors.red, size: 40),
                  Text('You have been eliminated.', style: TextStyle(fontSize: 16, color: Colors.red)),
                  Text('Press "Leave Game" to exit.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            )
          else if (!isSpectating)
            SizedBox(
              key: handKey,
              height: 135,
              child: SingleChildScrollView(
                controller: handScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(hand.length, (i) {
                    if (i >= playerCardKeys.length) playerCardKeys.add(GlobalKey());
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: GestureDetector(
                        onTap: () => onPlayCard(i),
                        child: AnimatedContainer(
                          key: playerCardKeys[i],
                          duration: const Duration(milliseconds: 250),
                          width: currentPlayer == 0 ? 70 : 69,
                          height: currentPlayer == 0 ? 114 : 113,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                            borderRadius: BorderRadius.circular(2),
                            border: currentPlayer == 0
                                ? Border.all(color: Colors.black.withOpacity(0.8), width: 0.6)
                                : Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              hand[i].assetName,
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
