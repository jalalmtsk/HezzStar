import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Manager/HelperClass/FlyingRewardManager.dart';
import '../../Manager/HelperClass/RewardDimScreen.dart';
import '../../tools/AdsManager/AdsManager.dart';
import '../../widgets/SpiningWheel/Spiningwheel.dart';
import 'package:hezzstar/widgets/userStatut/userStatus.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final GlobalKey goldEventKey = GlobalKey();
  final GlobalKey gemsEventKey = GlobalKey();
  final GlobalKey xpEventKey = GlobalKey();

  bool _isSpinning = false;

  Duration spinCooldown = const Duration(hours: 24);
  DateTime? _lastSpinTime;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  final Random _random = Random();

  static const String lastSpinKey = 'lastSpinTime';

  @override
  void initState() {
    super.initState();
    _loadLastSpinTime();
    _startCountdownTimer();
  }

  // Load the last spin time from SharedPreferences
  Future<void> _loadLastSpinTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastSpinStr = prefs.getString(lastSpinKey);

    if (lastSpinStr != null) {
      setState(() {
        _lastSpinTime = DateTime.tryParse(lastSpinStr);
      });
    }
  }

  // Save the last spin time to SharedPreferences
  Future<void> _saveLastSpinTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_lastSpinTime != null) {
      await prefs.setString(lastSpinKey, _lastSpinTime!.toIso8601String());
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lastSpinTime == null) {
        setState(() => _remainingTime = Duration.zero);
      } else {
        final elapsed = DateTime.now().difference(_lastSpinTime!);
        final remaining = spinCooldown - elapsed;
        setState(() {
          _remainingTime = remaining.isNegative ? Duration.zero : remaining;
        });
      }
    });
  }

  void _startSpin() {
    if (_isSpinning) return;

    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playSfx("assets/audios/UI/SFX/Gamification_SFX/SeeMoney.mp3");
    if (_remainingTime.inSeconds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "You can spin again in ${_remainingTime.inHours}h ${_remainingTime.inMinutes % 60}m ${_remainingTime.inSeconds % 60}s"),
      ));
      return;
    }

    setState(() => _isSpinning = true);

    // Duration of the spin animation
    const spinDuration = Duration(seconds: 13);

    Timer(spinDuration, () async {
      setState(() => _isSpinning = false);
      _lastSpinTime = DateTime.now();
      await _saveLastSpinTime(); // save the spin time
      _showRandomReward();
    });
  }

  void _showRandomReward() {
    List<int> rewards = [500, 500, 500, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000];
    int rewardAmount = rewards[_random.nextInt(rewards.length)];

    RewardDimScreen.show(
      context,
      start: const Offset(200, 400),
      endKey: goldEventKey,
      amount: rewardAmount,
      type: RewardType.gold,
    );
  }

  void _resetCooldown() async {
    setState(() {
      _lastSpinTime = null;
      _remainingTime = Duration.zero;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(lastSpinKey);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "Ready!";
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    bool isReady = _remainingTime == Duration.zero;

    return Scaffold(
      backgroundColor: Colors.transparent, // ✅ Keep original background untouched
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Title
                    Text(
                      "🎡 Spin Wheel 🎡",
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Timer
                    Text(
                      _formatDuration(_remainingTime),
                      style: TextStyle(
                        color: isReady ? Colors.greenAccent : Colors.white70,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Glow behind wheel when ready
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isReady)
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orangeAccent.withOpacity(0.4),
                                  blurRadius: 25,
                                  spreadRadius: 20,
                                ),
                                BoxShadow(
                                  color: Colors.deepOrangeAccent.withOpacity(0.8),
                                  blurRadius: 10,
                                  spreadRadius: 25,
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: Lottie.asset(
                            "assets/animations/AnimationSFX/SpinAnimationHomeScreen.json",
                            repeat: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),

                    // Buttons Column
                    Column(
                      children: [
                        // Spin Button
                        Row(
                          children: [
                            // Spin Button
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: IgnorePointer(
                                  ignoring: !isReady ? true : false, // Prevent clicks when not ready
                                  child: ElevatedButton(
                                    onPressed: _startSpin, // always defined
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(35)),
                                      backgroundColor: isReady ? Colors.yellowAccent : Colors.grey.shade800,
                                      foregroundColor: Colors.black,
                                      elevation: 14,
                                      shadowColor: Colors.yellowAccent,
                                    ),
                                    child: Text(
                                      "Spin",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Watch Ad Button
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: IgnorePointer(
                                  ignoring: isReady, // Prevent clicks but keep visible
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      bool adWatched = await AdHelper.showRewardedAd(context);
                                      if (adWatched) {
                                        _resetCooldown();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Cooldown reset! You can spin now.'),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                      backgroundColor: isReady
                                          ? Colors.grey.shade800
                                          : Colors.greenAccent.shade700,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: isReady ? 4 : 10,
                                      shadowColor: isReady
                                          ? Colors.grey.shade600
                                          : Colors.greenAccent,
                                    ),
                                    child: Text(
                                      isReady ? "🎁 Timer Ready" : "🎁 Spin Again",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Reset Timer Button
                        ElevatedButton(
                          onPressed: _resetCooldown,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 14),
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 10,
                            shadowColor: Colors.redAccent.shade700,
                          ),
                          child: const Text(
                            "Reset Timer (Test)",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),


                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),

          // Lottie spinning overlay
          if (_isSpinning)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Lottie.asset(
                  "assets/animations/AnimationSFX/SpinWheelGame.json",
                  width: 600,
                  height: 600,
                  repeat: false,
                ),
              ),
            ),

          // Top user status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: UserStatusBar(
              goldKey: goldEventKey,
              gemsKey: gemsEventKey,
              xpKey: xpEventKey,
            ),
          ),
        ],
      ),
    );
  }

}
