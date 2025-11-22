// lib/Hezz2FinalGame/Dialogs/SuitSelectionDialog.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hezzstar/main.dart';
import 'package:lottie/lottie.dart';

class PWF_SuitSelectionDialog extends StatefulWidget {
  final String previousSuit;

  const PWF_SuitSelectionDialog({
    super.key,
    required this.previousSuit,
  });

  @override
  State<PWF_SuitSelectionDialog> createState() => _SuitSelectionDialogState();
}

class _SuitSelectionDialogState extends State<PWF_SuitSelectionDialog>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> suits = [
    {"name": "Coins", "asset": "assets/images/CardSuits/CoinSuit_Icon.png"},
    {"name": "Cups", "asset": "assets/images/CardSuits/CupSuit_Icon.png"},
    {"name": "Swords", "asset": "assets/images/CardSuits/SwordSuit_Icon.png"},
    {"name": "Clubs", "asset": "assets/images/CardSuits/ClubsSuit_Icon.png"},
  ];

  late Timer _timer;
  int _timeLeft = 7;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // Smooth pop-in animation
    _scaleController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnimation =
        Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(
          parent: _scaleController,
          curve: Curves.easeOutBack,
        ));

    _scaleController.forward();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 1) {
        timer.cancel();
        if (mounted) Navigator.of(context).pop(widget.previousSuit);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dimmed background with blur
        GestureDetector(
          onTap: () {}, // block dismiss on tap outside
          child: Container(
            color: Colors.black.withOpacity(0.65),
          ),
        ),

        // Dialog
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title + 7s timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr(context).chooseASuit,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _timeLeft / 7,
                              strokeWidth: 4,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.redAccent,
                            ),
                            Text(
                              '$_timeLeft',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Suit grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: suits.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final suit = suits[index];

                      return GestureDetector(
                        onTap: () {
                          _timer.cancel();
                          Navigator.of(context).pop(suit["name"]);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.95),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(2, 3),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    suit["asset"]!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                suit["name"]!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
