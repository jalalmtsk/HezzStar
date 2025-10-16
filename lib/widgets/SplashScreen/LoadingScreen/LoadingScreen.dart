import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../tools/AudioManager/AudioManager.dart';

class LoadingScreen extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final bool loadingComplete;

  const LoadingScreen({
    super.key,
    required this.progress,
    required this.loadingComplete,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (widget.progress * 100).clamp(0, 100).toInt();

    return Stack(
      children: [
        // === Full-screen background image ===
        Positioned.fill(
          child: Image.asset(
            'assets/ImpoImages/ImportantSplash.png',
            fit: BoxFit.cover,
          ),
        ),

        // === Optional top Lottie animation ===
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: SizedBox(
              height: 180,
              child: Lottie.asset(
                'assets/animations/AnimationSFX/HezzFinal.json',
                repeat: true,
              ),
            ),
          ),
        ),

        // === Center game logo ===
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amberAccent.withOpacity(0.7),
                  blurRadius: 35,
                  spreadRadius: 12,
                )
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/ImpoImages/Hezz2Star_Logo.png',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // === Bottom progress bar + text ===
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Percentage text
              Text(
                "${widget.loadingComplete ? "Tap to Start!" : "$progressPercent%"}",
                style: TextStyle(
                  fontFamily: "CinzelDecorative",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade200,
                  shadows: [
                    const Shadow(
                      color: Colors.black87,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                    Shadow(
                      color: Colors.yellow.withOpacity(0.6),
                      blurRadius: 10,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  height: 28,
                  color: Colors.grey.shade800, // background
                  child: Align(
                    alignment: Alignment.centerLeft, // 👈 ensures left-to-right growth
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft, // 👈 keeps progress pinned left
                      widthFactor: widget.progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orangeAccent.withOpacity(0.7),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
