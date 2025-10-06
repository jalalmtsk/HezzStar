import 'package:flutter/material.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:provider/provider.dart';
import '../../../Models/Deck.dart';
import '../../../Tools/TextUI/CardReamingTextUi.dart';
import '../../../Tools/TextUI/MinimalBageText.dart';

class DeckCenterPanel extends StatefulWidget {
  final double top;
  final double left;
  final double right;
  final Function() onDraw;
  final dynamic deck; // deck object (with .cards and .isEmpty)
  final dynamic topCard; // top card (with .assetName)
  final List<dynamic> discard; // discard pile
  final GlobalKey deckKey;
  final GlobalKey centerKey;

  const DeckCenterPanel({
    super.key,
    required this.top,
    required this.left,
    required this.right,
    required this.onDraw,
    required this.deck,
    required this.topCard,
    required this.discard,
    required this.deckKey,
    required this.centerKey,
  });

  @override
  State<DeckCenterPanel> createState() => _DeckCenterPanelState();
}

class _DeckCenterPanelState extends State<DeckCenterPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  void playCardAnimation() async {
    await _controller.reverse(); // scale down
    await _controller.forward(); // scale up
  }

  @override
  void didUpdateWidget(covariant DeckCenterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation only if the top card changed
    if (oldWidget.topCard != widget.topCard && widget.topCard != null) {
      playCardSound();
      playCardAnimation();

    }
  }
  void playCardSound() {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playSfx('assets/audios/UI/SFX/CardTapTopCard.mp3'); // put your sound file in assets/sounds/
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Draw Pile
              GestureDetector(
                onTap: widget.onDraw,
                child: Column(
                  children: [
                    MinimalBadgeText(label: "Draw Pile", fontSize: 14),
                    const SizedBox(height: 4),
                    SizedBox(
                      key: widget.deckKey,
                      width: 70,
                      height: 110,
                      child: widget.deck.isEmpty
                          ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white70,
                        ),
                        child: const Center(child: Text('Empty')),
                      )
                          : Image.asset(
                        widget.deck.cards.last.backAsset(context),
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CardCountBadge(remaining: widget.deck.length),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Top Card with click animation
              Column(
                children: [
                  MinimalBadgeText(label: "Top Card"),
                  const SizedBox(height: 4),
                  SizedBox(
                    key: widget.centerKey,
                    width: 70,
                    height: 110,
                    child: widget.topCard == null
                        ? Container()
                        : ScaleTransition(
                      scale: _controller,
                      child:
                      Image.asset(widget.topCard.assetName, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 4),
                  CardCountBadge(remaining: widget.discard.length),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
