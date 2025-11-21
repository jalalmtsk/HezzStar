import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hezzstar/MainScreenIndex.dart';

import 'package:provider/provider.dart';

import '../../tools/AudioManager/AudioManager.dart';
import 'CompanyLogoScreen.dart';
import 'LoadingScreen/LoadingScreen.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  static const routeName = 'SplashPage';
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  bool _showLoadingScreen = false;
  double _progress = 0.0;
  late List<_PreloadTask> _tasks;
  bool _loadingComplete = false;

  late AnimationController _logoFadeController;
  late Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();

    _logoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoFade = CurvedAnimation(
      parent: _logoFadeController,
      curve: Curves.easeInOut,
    );

    _tasks = [
      _PreloadTask("Preload Assets", () => _preloadAssets((p) {
        setState(() => _progress = p);
      })),
      _PreloadTask("Initialize AdMob", _initAdMob),
      _PreloadTask("Final Setup", _finalSetup),
    ];

    _startIntro();
  }

  void _startIntro() async {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playAlert("assets/audios/UI/SplashScreen_Audio/modern_logo.mp3");
    audioManager.playSfx("assets/audios/UI/SplashScreen_Audio/openingZoom.mp3");

    _logoFadeController.forward();

    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      setState(() => _showLoadingScreen = true);
      _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    // 1️⃣ Preload assets and update progress per asset
    await _preloadAssets((p) => setState(() => _progress = p * 0.8));
    // *multiply by 0.8 so assets loading covers 0-80%*

    // 2️⃣ Initialize AdMob (animate from 80% → 95%)
    await _runWithTimeout("Initialize AdMob", _initAdMob);
    await _animateProgress(0.95); // smoothly goes 80 → 95%

    // 3️⃣ Final setup (animate from 95% → 100%)
    await _runWithTimeout("Final Setup", _finalSetup);
    await _animateProgress(1.0); // smoothly goes 95 → 100%

    // 4️⃣ Go to main screen
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(key: mainScreenKey),
      ),
    );
  }

  Future<void> _runWithTimeout(String name, Future<void> Function() action) async {
    debugPrint("Starting $name...");
    try {
      await action().timeout(const Duration(seconds: 4));
      debugPrint("$name completed!");
    } catch (e) {
      debugPrint("$name failed or timed out: $e");
    }
  }

  Future<void> _animateProgress(double target) async {
    final completer = Completer<void>();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final animation = Tween<double>(begin: _progress, end: target)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    animation.addListener(() {
      setState(() => _progress = animation.value);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) completer.complete();
    });

    controller.forward();
    await completer.future;
    controller.dispose();
  }

  @override
  void dispose() {
    _logoFadeController.dispose();
    super.dispose();
  }

  Future<void> _preloadAssets(Function(double) onProgress) async {
    final assets = [
      // 🎵 Audios


      // 🎨 Modes
      'assets/UI/modes/mode_1.png',
      'assets/UI/modes/mode_2.png',
      'assets/UI/modes/mode_3.png',
      'assets/UI/modes/mode_4.png',

      // 🖼️ Icons
      'assets/UI/Icons/AvatarProfile_Icon.png',
      'assets/UI/Icons/Collection_Icon.png',
      'assets/UI/Icons/Events_Icon.png',
      'assets/UI/Icons/Home_Icon.png',
      'assets/UI/Icons/Locked_Icon.png',
      'assets/UI/Icons/Settings_Icon.png',
      'assets/UI/Icons/SettingsHome_Icon.png',
      'assets/UI/Icons/Shop_Icon.png',
    ];

    for (int i = 0; i < assets.length; i++) {
      final path = assets[i];

      // Differentiate between images and audios
      if (path.endsWith(".png") || path.endsWith(".jpg")) {
        await precacheImage(AssetImage(path), context);
      } else if (path.endsWith(".mp3")) {
        await rootBundle.load(path);
      }

      // 🔥 Update progress
      onProgress((i + 1) / assets.length);
    }
  }


  Future<void> _initAdMob() async {
    await MobileAds.instance.initialize();
  }

  Future<void> _finalSetup() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1200), // longer fade
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _showLoadingScreen
            ? LoadingScreen(
          key: const ValueKey('LoadingScreen'),
          progress: _progress,
          loadingComplete: _loadingComplete,
        )
            : CompanyLogoScreen(
          key: const ValueKey('CompanyLogoScreen'),
          fadeAnimation: _logoFade,
        ),
      ),
    );
  }

}

class _PreloadTask {
  final String name;
  final Future<void> Function() action;
  _PreloadTask(this.name, this.action);
}
