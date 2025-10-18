import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../tools/ConnectivityManager/ConnectivityWidget.dart';

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
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: size * 3.9,
      height: size * 1.5,
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
            color: Colors.green.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.lightGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: backgroundImage != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          backgroundImage!,
          fit: BoxFit.cover,
          width: size * 2,
          height: size * 1,
        ),
      )
          : null,
    );
  }

  Widget _buildGlassCard(BuildContext context) {
    return Container(
      width: size * 3.9,
      height: size * 1.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 4),
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
                const SizedBox(width: 10),
                _buildPlayerInfo(context),
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
          width: size ,
          height: size ,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: [Colors.blue, Colors.purple, Colors.red, Colors.orange, Colors.blue],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(1),
                blurRadius: 10,
                spreadRadius: 6,
              ),
            ],
          ),
        ),
        Container(
          width: size ,
          height: size,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
        ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.greenAccent.withOpacity(0.8), blurRadius: 6, offset: const Offset(2, 4)),
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

  Widget _buildPlayerInfo(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '- ${tr(context).player} -',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.75),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                playerName,
                style: const TextStyle(
                  fontFamily: 'Aladin', // <-- your asset font family
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(2, 2)),
                  ],
                ),
              ),
              const SizedBox(width: 6,),
              Icon(Icons.edit, color: Colors.white, size: 11,)
            ],
          )

        ],
      ),
    );
  }
}
