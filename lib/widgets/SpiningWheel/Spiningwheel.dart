import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tools/AdsManager/AdsManager.dart';
import '../../tools/AudioManager/AudioManager.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  bool _isSpinning = false;
  DateTime? _lastSpin;
  Duration _remainingTime = Duration.zero;
  Timer? _timer;
  int? _rewardAmount;
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _loadLastSpin();
    _lottieController = AnimationController(vsync: this);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lottieController.dispose();
    super.dispose();
  }

  // 🕓 Load last spin time from storage
  Future<void> _loadLastSpin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastSpinMillis = prefs.getInt('last_spin');
    if (lastSpinMillis != null) {
      _lastSpin = DateTime.fromMillisecondsSinceEpoch(lastSpinMillis);
    }
    _updateRemainingTime();
  }

  // ⏳ Update remaining time every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
    if (_lastSpin == null) {
      setState(() => _remainingTime = Duration.zero);
      return;
    }
    final now = DateTime.now();
    final difference = now.difference(_lastSpin!);
    final remaining = Duration(hours: 24) - difference;
    setState(() => _remainingTime = remaining.isNegative ? Duration.zero : remaining);
  }

  // 🎯 Handle the spin
  Future<void> _spinWheel() async {
    if (_isSpinning || _remainingTime > Duration.zero) return;

    setState(() {
      _isSpinning = true;
      _rewardAmount = null;
    });

  //  AudioManager.playSFX("spin_start");

    _lottieController.reset();
    _lottieController.forward();

    await Future.delayed(const Duration(seconds: 3)); // simulate spin duration

    final reward = _generateRandomReward();
    setState(() {
      _rewardAmount = reward;
      _isSpinning = false;
      _lastSpin = DateTime.now();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_spin', _lastSpin!.millisecondsSinceEpoch);

   // AudioManager.playSfx("spin_end");

    _showRewardDialog(reward);
  }

  // 🎁 Random reward generator
  int _generateRandomReward() {
    final rewards = [50, 100, 200, 300, 500];
    return rewards[Random().nextInt(rewards.length)];
  }

  void _showRewardDialog(int reward) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: Text('You won $reward coins!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0c0c1e),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const Text(
                "🎡 Daily Spin",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // ✨ Decorative Lottie
              Lottie.asset(
                "assets/animations/AnimationSFX/SpinAnimationHomeScreen.json",
                width: 120,
                height: 80,
                repeat: true,
              ),

              const SizedBox(height: 8),

              Text(
                _remainingTime == Duration.zero
                    ? "Ready to spin!"
                    : "Next spin in ${_formatDuration(_remainingTime)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 20),

              // Use Expanded to avoid unbounded height
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: GestureDetector(
                      onTap: _spinWheel,
                      child: _isSpinning
                          ? Lottie.asset(
                        "assets/animations/AnimationSFX/SpinWheelGame.json",
                        controller: _lottieController,
                        onLoaded: (comp) {
                          _lottieController.duration = comp.duration;
                          _lottieController.forward().then((_) {
                            _lottieController.stop();
                          });
                        },
                        fit: BoxFit.contain,
                      )
                          : Lottie.asset(
                        "assets/animations/AnimationSFX/SpinWheelGame.json",
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Reward display
              if (_rewardAmount != null)
                Text(
                  "You won $_rewardAmount coins!",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 20),

              // Watch ad button
              ElevatedButton.icon(
                onPressed: _isSpinning
                    ? null
                    : () async {
                  bool adWatched = await AdHelper.showRewardedAd(context);
                  if (adWatched) {
                    _lastSpin = DateTime.now();
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    await prefs.setInt(
                        'last_spin', _lastSpin!.millisecondsSinceEpoch);
                    _updateRemainingTime();
                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "🎬 Ad watched! Timer reset — come back in 24h for your next spin!",
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.ondemand_video, size: 18),
                label: const Text(
                  "Watch Ad to Reset Timer",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
