import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../MainScreenIndex.dart';
import '../../../../tools/AudioManager/AudioManager.dart';
import '../../../main.dart';

class OfflineLoadingPopup {
  static Future<void> show(BuildContext context, {int durationSeconds = 3}) async {
    bool _isCompleted = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final audioManager = Provider.of<AudioManager>(context, listen: false);
        // Play sound once
        audioManager.playSfx(
          "assets/audios/UI/SFX/Gamification_SFX/PlayerSerchingPopUpSound.mp3",
        );

        // Automatically close dialog after duration
        Timer(Duration(seconds: durationSeconds), () {
          if (!_isCompleted && context.mounted) {
            _isCompleted = true;
            Navigator.of(context).pop();
          }
        });

        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                      color: Colors.yellow.shade600.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        "assets/animations/AnimationSFX/HezzFinal.json",
                        height: 180,
                        repeat: true,
                      ),
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(
                        color: Colors.yellowAccent,
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr(context).loading,
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tr(context).pleaseWait,
                        style: const TextStyle(
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
  }
}
