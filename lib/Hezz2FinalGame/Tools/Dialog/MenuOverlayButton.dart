import 'package:flutter/material.dart';
import 'package:hezzstar/widgets/LoadingScreen/LoadinScreenDim.dart';
import 'package:lottie/lottie.dart';
import '../../../IndexPages/Settings/SettingDialog.dart';
import '../../../MainScreenIndex.dart';
import '../../../main.dart';
import 'GameInfoDialog.dart';
import 'InstructionDialog.dart';

class MenuOverlayButton extends StatefulWidget {
  final String gameModeName;
  final int botCount;
  final int selectedBet;

  const MenuOverlayButton({
    super.key,
    required this.gameModeName,
    required this.botCount,
    required this.selectedBet,
  });

  @override
  State<MenuOverlayButton> createState() => _MenuOverlayButtonState();
}

class _MenuOverlayButtonState extends State<MenuOverlayButton> {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  Future<void> _toggleOverlay() async {
    if (_isOpen) return _closeOverlay();
    _openOverlay();
  }

  void _openOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeOverlay, // close if tapped outside
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              child: Material(
                color: Colors.transparent,
                child: GameInfoDialog(
                  mode: widget.gameModeName,
                  players: widget.botCount + 1,
                  prize: widget.selectedBet * (widget.botCount + 1),
                  onSettings: () {
                    _closeOverlay();
                    showDialog(
                      context: context,
                      builder: (_) => const SettingsDialog(),
                    );
                  },
                  onInstructions: () {
                    _closeOverlay();
                    showDialog(
                      context: context,
                      builder: (_) => const InstructionsDialog(),
                    );
                  },

                    onExit: () async {
                      _closeOverlay();

                      final shouldExit = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(45),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon / Animation
                                Lottie.asset(
                                  'assets/animations/Win/SwordBattle.json',
                                  width: 120,
                                  height: 120,
                                  repeat: false,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Exit Game?",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                 Text(
                                  "${tr(context).confirmLeaveGame}\n ${tr(context).returnToLauncher}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontSize: 15),
                                ),
                                const SizedBox(height: 25),

                                // Buttons Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Cancel
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      label:  Text(tr(context).cancel, style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow.withOpacity(0.7),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15)),
                                      ),
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                    ),

                                    // Exit
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.exit_to_app, color: Colors.white),
                                      label:  Text(tr(context).exit, style: TextStyle(color: Colors.white),),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15)),
                                      ),
                                      onPressed: () {
                                        LoadingScreenDim.show(
                                          ctx,
                                          seconds: 2,
                                          lottieAsset:
                                          'assets/animations/AnimationSFX/HezzFinal.json',
                                          onComplete: () {
                                            Navigator.of(ctx).pop(true);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      if (shouldExit == true) {
                        await Future.delayed(const Duration(milliseconds: 200));
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => MainScreen()),
                        );
                      }
                    },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
    setState(() {});

    // auto-close optional
    Future.delayed(const Duration(seconds: 6), () {
      if (_isOpen) _closeOverlay();
    });
  }

  Future<void> _closeOverlay() async {
    if (!_isOpen) return;
    _isOpen = false;
    setState(() {});

    // Wait for the AnimatedContainer to finish its 150ms animation
    await Future.delayed(const Duration(milliseconds: 150));

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleOverlay,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isOpen ? Colors.red : Colors.black54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(_isOpen ? Icons.close : Icons.list, color: Colors.white),
      ),
    );
  }
}
