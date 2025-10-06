import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../tools/AudioManager/AudioManager.dart';

class SearchingPopup {
  static Future<void> show(BuildContext context, int players) async {
    int foundPlayers = 0;

    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent outside taps
      builder: (context) {
        void findNextPlayer(void Function(void Function()) setState) {
          if (foundPlayers >= players) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            });
            return;
          }

          // Random delay between 1s and 3s
          final randomDelay =
          Duration(milliseconds: 1000 + Random().nextInt(4000));
          Future.delayed(randomDelay, () {
            if (!context.mounted) return;

            if (foundPlayers < players) {
              setState(() {
                foundPlayers++;
              });
              findNextPlayer(setState);
            }
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            // Play sound only once, when the popup first appears
            if (foundPlayers == 0) {
              // Call your audio here
              final audioManager = Provider.of<AudioManager>(context, listen: false); // Or get it from Provider if using one
              audioManager.playSfx("assets/audios/UI/SFX/Gamification_SFX/PlayerSerchingPopUpSound.mp3");
              findNextPlayer(setState);
            }


            return WillPopScope(
              onWillPop: () async => false, // Block back button
              child: Dialog(
                insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                        'assets/animations/AnimationSFX/World.json',
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
                        border: Border.all(
                            color: Colors.yellowAccent.withOpacity(0.4),
                            width: 2),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            "assets/animations/AnimationSFX/HezzFinal.json",
                            height: 200,
                            repeat: true,
                          ),
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
                                margin:
                                const EdgeInsets.symmetric(horizontal: 6),
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
                                      color: Colors.yellowAccent
                                          .withOpacity(0.8),
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
              ),
            );
          },
        );
      },
    );
  }
}
