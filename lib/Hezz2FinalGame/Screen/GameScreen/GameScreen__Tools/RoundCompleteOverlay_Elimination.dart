import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RoundCompleteOverlay extends StatefulWidget {
  final int currentRound;
  final List<int> qualifiedPlayers;
  final int countdownSeconds; // how many seconds to wait

  const RoundCompleteOverlay({
    Key? key,
    required this.currentRound,
    required this.qualifiedPlayers,
    this.countdownSeconds = 5, // default 5 sec
  }) : super(key: key);

  @override
  State<RoundCompleteOverlay> createState() => _RoundCompleteOverlayState();
}

class _RoundCompleteOverlayState extends State<RoundCompleteOverlay> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Round complete title
              Text(
                'Round ${widget.currentRound} Complete!',
                style: const TextStyle(
                  fontSize: 34,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Qualified players
              Text(
                'Qualified: ${widget.qualifiedPlayers.map((p) => p == 0 ? "You" : "Player $p").join(", ")}',
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Lottie animation instead of progress indicator
              SizedBox(
                height: 120,
                child: Lottie.asset(
                  'assets/animations/AnimationSFX/HezzFinal.json', // 👈 put your loading/preparing animation here
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Preparing text + countdown
              Text(
                'Preparing next round in $_remainingSeconds...',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
