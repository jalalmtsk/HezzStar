import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SearchingPopup {
  static Future<void> show(BuildContext context, int players) async {
    int foundPlayers = 0;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        void findNextPlayer(void Function(void Function()) setState) {
          if (foundPlayers >= players) {
            Future.delayed(const Duration(seconds: 1), () {
              if (Navigator.canPop(context)) Navigator.of(context).pop();
            });
            return;
          }

          // Random delay between 1s and 3s
          final randomDelay =
          Duration(milliseconds: 1000 + Random().nextInt(2001));
          Future.delayed(randomDelay, () {
            if (!Navigator.canPop(context)) return;
            setState(() {
              foundPlayers++;
            });
            findNextPlayer(setState);
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            if (foundPlayers == 0) {
              findNextPlayer(setState);
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🔥 JSON Lottie animation background
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Lottie.asset(
                      'assets/animations/AnimationSFX/World.json', // your animation file
                      fit: BoxFit.cover,
                      repeat: true,
                    ),
                  ),

                  // 🔹 Overlay content
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.yellowAccent.withOpacity(0.4), width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            child:
                            Lottie.asset(
                                height: 200,
                                "assets/animations/AnimationSFX/HezzFinal.json", repeat: true)),
                        Text(
                          "$foundPlayers/$players",
                          style: const TextStyle(
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          foundPlayers < players
                              ? "Searching for players..."
                              : "⚡ Match Found!",
                          style: TextStyle(
                            color: foundPlayers < players
                                ? Colors.white70
                                : Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(players, (index) {
                            bool isActive = index < foundPlayers;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.yellowAccent
                                    : Colors.grey[700],
                                shape: BoxShape.circle,
                                boxShadow: isActive
                                    ? [
                                  BoxShadow(
                                    color: Colors.yellowAccent.withOpacity(0.8),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  )
                                ]
                                    : [],
                              ),
                              child: isActive
                                  ? const Icon(Icons.person,
                                  size: 18, color: Colors.black87)
                                  : null,
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Please wait...",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
