import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Simple reusable loading overlay using an OverlayEntry.
/// Call LoadingScreen.show(context, ...) and LoadingScreen.hide().
class LoadingScreenDim {
  static OverlayEntry? _entry;
  static Timer? _timer;

  /// Show the loading overlay.
  ///
  /// [context] - required
  /// [seconds] - how many seconds before it auto-hides (default 2)
  /// [lottieAsset] - path to local Lottie asset (e.g. 'assets/lottie/loader.json').
  ///                 If null and [lottieUrl] is null, a small default spinner is shown.
  /// [lottieUrl] - url to a remote Lottie JSON (optional)
  /// [size] - size of the Lottie animation (default 150)
  /// [dimColor] - color for dim background (default Colors.black54)
  /// [dismissible] - if true, tapping outside will hide overlay
  /// [onComplete] - optional callback run after auto-hide
  static void show(
      BuildContext context, {
        int seconds = 2,
        String? lottieAsset,
        String? lottieUrl,
        double size = 150,
        Color dimColor = Colors.black54,
        bool dismissible = false,
        VoidCallback? onComplete,
      }) {
    // If already shown, reset timer and return
    if (_entry != null) {
      _resetTimer(seconds, onComplete);
      return;
    }

    _entry = OverlayEntry(
      builder: (context) => _LoadingOverlay(
        lottieAsset: lottieAsset,
        lottieUrl: lottieUrl,
        size: size,
        dimColor: dimColor,
        dismissible: dismissible,
        onBackgroundTap: dismissible ? hide : null,
      ),
    );

    Overlay.of(context)?.insert(_entry!);
    _resetTimer(seconds, onComplete);
  }

  /// Hide the loading overlay immediately.
  static void hide() {
    _timer?.cancel();
    _timer = null;
    try {
      _entry?.remove();
    } catch (_) {}
    _entry = null;
  }

  static void _resetTimer(int seconds, VoidCallback? onComplete) {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: seconds), () {
      hide();
      if (onComplete != null) onComplete();
    });
  }
}

class _LoadingOverlay extends StatelessWidget {
  final String? lottieAsset;
  final String? lottieUrl;
  final double size;
  final Color dimColor;
  final bool dismissible;
  final VoidCallback? onBackgroundTap;

  const _LoadingOverlay({
    Key? key,
    this.lottieAsset,
    this.lottieUrl,
    required this.size,
    required this.dimColor,
    required this.dismissible,
    this.onBackgroundTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Full-screen stack with dim background and centered animation
    return Stack(
      children: [
        // Modal barrier (blocks taps unless dismissible)
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBackgroundTap,
            child: Container(
              color: dimColor,
            ),
          ),
        ),

        // Centered content
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                )
              ],
            ),
            child: SizedBox(
              width: size,
              height: size,
              child: _buildAnimation(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimation() {
    if (lottieAsset != null) {
      return Lottie.asset(
        lottieAsset!,
        fit: BoxFit.contain,
      );
    } else if (lottieUrl != null) {
      return Lottie.network(
        lottieUrl!,
        fit: BoxFit.contain,
      );
    } else {
      // Fallback: CircularProgressIndicator inside padding
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
