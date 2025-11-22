import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../../MainScreenIndex.dart';
import '../../../../../main.dart';
import '../../../../../tools/AudioManager/AudioManager.dart';
import '../../../../../tools/ConnectivityManager/ConnectivityManager.dart';
import '../../../../Models/GameCardEnums.dart';

class SearchingPopup {
  static Future<void> show(
      BuildContext context, int players, GameMode mode) async {
    int foundPlayers = 0;
    bool _showDisconnectedOverlay = false;

    Future<void> _attemptReconnect() async {
      const double totalTime = 1; // seconds
      double remaining = totalTime;

      final connectivityService = context.read<ConnectivityService>();
      OverlayEntry? countdownOverlay;

      countdownOverlay = OverlayEntry(
        builder: (context) {
          return Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                     Text(
                      tr(context).disconnected,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${tr(context).redirectingIn} ${remaining.toStringAsFixed(1)}',
                      style: const TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      Overlay.of(context)?.insert(countdownOverlay);

      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!context.mounted || connectivityService.isConnected) {
          timer.cancel();
          countdownOverlay?.remove();
          return;
        }

        remaining -= 0.1; // decrease by 0.1 second per tick
        countdownOverlay?.markNeedsBuild();

        if (remaining <= 0) {
          timer.cancel();
          countdownOverlay?.remove();
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen()),
            );
          }
        }
      });
    }


    return showDialog(
      context: context,
      barrierDismissible: false,
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
            if (foundPlayers == 0) {
              final audioManager =
              Provider.of<AudioManager>(context, listen: false);
              audioManager.playSfx(
                  "assets/audios/UI/SFX/Gamification_SFX/PlayerSerchingPopUpSound.mp3");
              findNextPlayer(setState);
            }

            // --- Connectivity overlay logic for online mode ---
            if (mode == GameMode.online) {
              final connectivityService = context.read<ConnectivityService>();
              _showDisconnectedOverlay = !connectivityService.isConnected;

              if (!connectivityService.isConnected) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!context.mounted) return;
                  setState(() => _showDisconnectedOverlay = true);
                  await _attemptReconnect();
                });
              }

              connectivityService.addListener(() async {
                if (!context.mounted) return;

                if (connectivityService.isConnected) {
                  setState(() => _showDisconnectedOverlay = false);
                } else {
                  setState(() => _showDisconnectedOverlay = true);
                  await _attemptReconnect();
                }
              });
            }

            return WillPopScope(
              onWillPop: () async => false,
              child: Stack(
                children: [
                  Dialog(
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Lottie.asset(
                            'assets/animations/AnimationSFX/World.json',
                            fit: BoxFit.cover,
                            repeat: true,
                          ),
                        ),
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
                                    ? tr(context).searchingForPlayers
                                    : tr(context).matchFound,
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
                                    duration:
                                    const Duration(milliseconds: 400),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 6),
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
                               Text(
                                tr(context).pleaseWait,
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
                  // Optional: Disconnected overlay inside the dialog itself
                  if (_showDisconnectedOverlay)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.85),
                        child:  Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.wifi_off,
                                  size: 80, color: Colors.white),
                              SizedBox(height: 20),
                              Text(
                                tr(context).disconnected,
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
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
