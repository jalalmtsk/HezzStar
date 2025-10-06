import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ConnectivityManager.dart';

class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Provider.of<ConnectivityService>(context);
    final bool connected = connectivity.isConnected;

    return Stack(
      alignment: Alignment.center,
      children: [
        // WiFi icon
        Icon(
          connected ? Icons.wifi : Icons.wifi_off,
          size: 28,
          color: connected ? Colors.green : Colors.grey,
        ),

        // Status dot overlay (bottom-right corner of the icon)
        Positioned(
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: connected ? Colors.green : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: connected
                      ? Colors.green.withOpacity(0.8)
                      : Colors.red.withOpacity(0.8),
                  blurRadius: connected ? 8 : 4,
                  spreadRadius: connected ? 2 : 1,
                ),
              ],
            ),
            child: connected
                ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              onEnd: () {},
            )
                : const _BlinkingDot(),
          ),
        ),
      ],
    );
  }
}

// Reusable blinking dot for disconnected state
class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: const SizedBox());
  }
}
