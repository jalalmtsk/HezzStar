import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../tools/ConnectivityManager/ConnectivityManager.dart';
import '../../../tools/ConnectivityManager/ConnectivityWidget.dart';
import 'BlinkRedDot.dart';

class AvatarCard extends StatelessWidget {
  final String playerName;
  final String avatarPath;
  final double size;
  final VoidCallback? onTap;
  final String? backgroundImage;

  const AvatarCard({
    super.key,
    required this.playerName,
    required this.avatarPath,
    this.size = 100,
    this.onTap,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildBackground(),
            _buildGlassCard(context),
            _buildShineEffect(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: size * 2.5,
      height: size * 1.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb), Color(0xFFf5576c)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: backgroundImage != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          backgroundImage!,
          fit: BoxFit.cover,
          width: size * 2.5,
          height: size * 1.3,
        ),
      )
          : null,
    );
  }

  Widget _buildGlassCard(BuildContext context) {
    return Container(
      width: size * 4.6,
      height: size * 1.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildAnimatedAvatar(),
                const SizedBox(width: 20),
                _buildPlayerInfo(),
                const ConnectivityIndicator()
              ]),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size + 14,
          height: size + 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: [Colors.blue, Colors.purple, Colors.red, Colors.orange, Colors.blue],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 18,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
        Container(
          width: size + 6,
          height: size + 6,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
        ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              avatarPath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 12, spreadRadius: 2)],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerInfo() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLAYER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.75),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            playerName,
            style: const TextStyle(
              fontFamily: 'Aladin', // <-- your asset font family
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(2, 2)),
              ],
            ),
          )

        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final connectivity = Provider.of<ConnectivityService>(context);
    final bool connected = connectivity.isConnected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? Colors.green : Colors.red,
        boxShadow: [
          BoxShadow(
            color: connected ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
            blurRadius: connected ? 12 : 6,
            spreadRadius: connected ? 3 : 1,
          ),
        ],
      ),
      // Add a pulsing effect only when connected
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
          : BlinkingDot(), // <-- custom blinking when disconnected
    );
  }



  Widget _buildShineEffect() {
    return Container(
      width: size * 4.6,
      height: size * 1.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
    );
  }
}
