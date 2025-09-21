import 'dart:async';
import 'package:flutter/material.dart';

class SuitSelectionDialog extends StatefulWidget {
  final String previousSuit; // fallback if time runs out

  const SuitSelectionDialog({super.key, required this.previousSuit});

  @override
  State<SuitSelectionDialog> createState() => _SuitSelectionDialogState();
}

class _SuitSelectionDialogState extends State<SuitSelectionDialog> {
  final List<Map<String, String>> suits = [
    {"name": "Coins", "asset": "assets/images/CardSuits/CoinSuit_Icon.png"},
    {"name": "Cups", "asset": "assets/images/CardSuits/CupSuit_Icon.png"},
    {"name": "Swords", "asset": "assets/images/CardSuits/SwordSuit_Icon.png"},
    {"name": "Clubs", "asset": "assets/images/CardSuits/ClubsSuit_Icon.png"},
  ];

  late Timer _timer;
  int _timeLeft = 7;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 1) {
        timer.cancel();
        if (mounted) Navigator.of(context).pop(widget.previousSuit);
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 70, vertical: 120),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular countdown timer

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Choose a Suit",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _timeLeft / 7, // fraction of time left
                        strokeWidth: 5,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.redAccent,
                      ),
                      Text(
                        '$_timeLeft',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suits.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final suit = suits[index];
                return GestureDetector(
                  onTap: () {
                    _timer.cancel();
                    Navigator.of(context).pop(suit["name"]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          suit["asset"]!,
                          height: 75,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          suit["name"]!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
