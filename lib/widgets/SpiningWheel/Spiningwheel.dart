import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Manager/HelperClass/FlyingRewardManager.dart';
import '../../Manager/HelperClass/RewardDimScreen.dart';
import '../../tools/AdsManager/AdsManager.dart';

class SpinWheelScreen extends StatefulWidget {
  final GlobalKey goldKey;
  const SpinWheelScreen({super.key, required this.goldKey});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  bool _isSpinning = false;
  late final AnimationController _controller;
  DateTime? _lastSpin;
  Duration _remainingTime = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadLastSpin();

    // Live countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lastSpin != null) {
        _updateRemainingTime();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastSpin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? timestamp = prefs.getInt('last_spin');
    if (timestamp != null) {
      _lastSpin = DateTime.fromMillisecondsSinceEpoch(timestamp);
      _updateRemainingTime();
    }
    setState(() {});
  }

  void _updateRemainingTime() {
    if (_lastSpin != null) {
      final now = DateTime.now();
      final nextSpin = _lastSpin!.add(const Duration(hours: 24));
      _remainingTime = nextSpin.difference(now);
      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
        _lastSpin = null; // allow spin immediately
      }
    } else {
      _remainingTime = Duration.zero;
    }
  }

  Future<void> _spinWheel({bool isAdSpin = false}) async {
    _updateRemainingTime();
    if (_isSpinning) return;

    // Prevent daily spin if time hasn't passed (for normal spins)
    if (!isAdSpin && _remainingTime > Duration.zero) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Next spin in ${_remainingTime.inHours}h ${_remainingTime.inMinutes % 60}m'),
      ));
      return;
    }

    setState(() => _isSpinning = true);

    int reward = _getRandomReward();

    if (!isAdSpin) {
      // Normal daily spin → save timestamp
      _lastSpin = DateTime.now();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_spin', _lastSpin!.millisecondsSinceEpoch);
    }

    _controller.reset();

    // Spinning wheel animation
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Lottie.asset(
          "assets/animations/AnimationSFX/SpinWheelGame.json",
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
            _controller.addStatusListener((status) {
              if (status == AnimationStatus.completed) Navigator.of(context).pop();
            });
          },
          width: 400,
          height: 400,
        ),
      ),
    );

    RewardDimScreen.show(
      context,
      start: const Offset(200, 400),
      endKey: widget.goldKey,
      amount: reward,
      type: RewardType.gold,
    );

    _updateRemainingTime(); // refresh timer after spin
    setState(() => _isSpinning = false);
  }


  int _getRandomReward() {
    final rewards = {
      500: 20,
      1000: 15,
      2000: 10,
      3000: 8,
      4000: 5,
      5000: 4,
      7000: 2,
      10000: 1,
    };

    List<int> weightedList = [];
    rewards.forEach((value, weight) {
      for (int i = 0; i < weight; i++) weightedList.add(value);
    });

    return weightedList[Random().nextInt(weightedList.length)];
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey[850],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 6)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Daily Spin',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _spinWheel(),
              child: Lottie.asset(
                "assets/animations/AnimationSFX/SpinAnimationHomeScreen.json",
                height: 150,
                width: 150,
              ),
            ),
            const SizedBox(height: 6),
            if (_remainingTime > Duration.zero)
              Text(
                'Next: ${_formatDuration(_remainingTime)}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  bool adWatched = await AdHelper.showRewardedAd(context);
                  if (adWatched) _spinWheel(isAdSpin: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.ondemand_video, size: 16),
                    SizedBox(width: 4),
                    Text('Extra Spin', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
