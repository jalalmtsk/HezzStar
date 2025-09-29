import 'package:flutter/material.dart';
import 'package:hezzstar/widgets/LoadingScreen/LoadinScreenDim.dart';
import '../../../IndexPages/Settings/SettingDialog.dart';
import '../../../MainScreenIndex.dart';
import 'GameInfoDialog.dart';
import 'InstructionDialog.dart';

class MenuOverlayButton extends StatefulWidget {
  final String gameModeName;
  final int botCount;
  final int selectedBet;
  final int currentPlayer;
  

  const MenuOverlayButton({
    super.key,
    required this.gameModeName,
    required this.botCount,
    required this.selectedBet,
    required this.currentPlayer,
  });

  @override
  State<MenuOverlayButton> createState() => _MenuOverlayButtonState();
}

class _MenuOverlayButtonState extends State<MenuOverlayButton> {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  Future<void> _toggleOverlay() async{
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
                    showDialog(context: context, builder: (_) => const SettingsDialog());
                  },
                  onInstructions: () {
                    _closeOverlay();
                    showDialog(context: context, builder: (_) => const InstructionsDialog());
                  },
                  onExit: () async {
                     _closeOverlay();
                    if (widget.currentPlayer != 0) {
                      // Show "Wait your turn" dialog
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text(
                            "Wait Your Turn",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            "You cannot exit now. Please wait for your turn.",
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text("OK", style: TextStyle(color: Colors.amber)),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    // If it's the current player's turn, proceed with normal exit
                    await _closeOverlay();

                    final shouldExit = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text(
                          "Exit Game?",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          "Are you sure you want to exit and return to the launcher?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              LoadingScreenDim.show(
                                ctx,
                                seconds: 2,
                                lottieAsset: 'assets/animations/AnimationSFX/HezzFinal.json',
                                onComplete: () {
                                  Navigator.of(ctx).pop(true);
                                },
                              );
                            },
                            child: const Text("Exit"),
                          ),
                        ],
                      ),
                    );

                    if (shouldExit == true) {
                      await Future.delayed(const Duration(milliseconds: 200));
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => MainScreen()),
                      );
                    }
                  },
                  currentPlayer: widget.currentPlayer,
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

    // Wait for the AnimatedContainer to finish its 200ms animation
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
