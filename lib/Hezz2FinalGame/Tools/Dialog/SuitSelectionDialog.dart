import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hezzstar/main.dart';

class SuitSelectionDialog extends StatefulWidget {
  final String previousSuit;

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
        setState(() => _timeLeft--);
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
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  tr(context).chooseASuit,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 46,
                  height: 46,
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

            // Grid of suits
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suits.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
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
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
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
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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
