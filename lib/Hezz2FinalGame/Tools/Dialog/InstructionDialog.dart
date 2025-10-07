// file: instructions_dialog_custom.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../tools/AudioManager/AudioManager.dart';

class InstructionsDialog extends StatefulWidget {
  const InstructionsDialog({super.key});

  @override
  State<InstructionsDialog> createState() => _InstructionsDialogState();
}

class _InstructionsDialogState extends State<InstructionsDialog> with TickerProviderStateMixin {
  bool _controlsOpen = true;
  bool _rewardsOpen = false;
  bool _tipsOpen = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  Color primaryAccent = Colors.greenAccent;
  Color secondaryAccent = Colors.tealAccent;

  @override
  void initState() {
    super.initState();

    // Pulsing animation for buttons or headers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePanel(String key) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    if (!mounted) return;

    audioManager.playEventSound('PopClick');

    setState(() {
      switch (key) {
        case 'controls':
          _controlsOpen = !_controlsOpen;
          break;
        case 'rewards':
          _rewardsOpen = !_rewardsOpen;
          break;
        case 'tips':
          _tipsOpen = !_tipsOpen;
          break;
      }
    });
  }

  Widget _luxHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
          boxShadow: [
            BoxShadow(color: primaryAccent.withOpacity(0.32), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            const Text(
              "📖 Instructions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel({
    required String id,
    required IconData icon,
    required String title,
    required Color accent,
    required bool open,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: open ? accent.withOpacity(0.75) : Colors.white12, width: open ? 2.2 : 1.0),
        boxShadow: open
            ? [BoxShadow(color: accent.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 8))]
            : [BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 4))],
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(open ? 0.04 : 0.02), Colors.black.withOpacity(open ? 0.04 : 0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: accent.withAlpha(40), child: Icon(icon, color: accent)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              GestureDetector(
                onTap: () => _togglePanel(id),
                child: AnimatedRotation(
                  turns: open ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(padding: const EdgeInsets.only(top: 12), child: child),
            crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 350),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeOutBack,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.78,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
              boxShadow: [BoxShadow(color: primaryAccent.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 12))],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _luxHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                    child: ListView(
                      children: [
                        _buildPanel(
                          id: 'controls',
                          icon: Icons.gamepad,
                          title: "Game Setup & Controls",
                          accent: Colors.tealAccent,
                          open: _controlsOpen,
                          child: const Text(
                            "• 1 human player + 1-5 bots\n"
                                "• Modes: PlayToWin (first to finish hand) or Elimination\n"
                                "• Player can spectate\n"
                                "• Start with a hand of cards; deck is shuffled\n"
                                "• Click card to play if valid\n"
                                "• Draw card if no valid plays\n"
                                "• Turn-based gameplay\n"
                                "• Bot turns are delayed to simulate thinking",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        _buildPanel(
                          id: 'rewards',
                          icon: Icons.military_tech,
                          title: "Special Cards & Effects",
                          accent: Colors.amberAccent,
                          open: _rewardsOpen,
                          child: SizedBox(
                            height: 250, // Fixed height for PageView
                            child: PageView(
                              children: [
                                _specialCardPage(
                                  imagePath: 'assets/images/cards/clubs_1.png', // replace with your Skip card image
                                  title: '1: Skip',
                                  description:
                                  '• Skips the next player\'s turn.',
                                ),
                                _specialCardPage(
                                  imagePath: 'assets/images/Tutorials/StackOf2_Tuto.png',
                                  title: '2: Draw +2',
                                  description:
                                  '• Adds +2 to pending draw.\n• Can chain with another 2.',
                                ),
                                _specialCardPage(
                                  imagePath: 'assets/images/cards/clubs_7.png',
                                  title: '7: Change Suit',
                                  description:
                                  '• Allows player to change the current suit.\n• Players choose suit via dialog.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildPanel(
                          id: 'tips',
                          icon: Icons.lightbulb,
                          title: "Gameplay Tips",
                          accent: Colors.greenAccent,
                          open: _tipsOpen,
                          child: const Text(
                            "• Aim to empty your hand first (PlayToWin)\n"
                                "• In Elimination, avoid finishing last\n"
                                "• Watch for special card combos (1,2,7)\n"
                                "• Animations & banners show card effects\n"
                                "• Quitting waits for all animations to finish to avoid glitches\n"
                                "• Overlay entries and animation controllers are properly disposed",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              audioManager.playEventSound('cancelButton');
                              Navigator.of(context).pop();
                            },
                            child: ScaleTransition(
                              scale: _pulseAnim,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
                                  boxShadow: [
                                    BoxShadow(color: primaryAccent.withOpacity(0.28), blurRadius: 8, offset: const Offset(0, 6))
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.close, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function for PageView
  Widget _specialCardPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 17),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
