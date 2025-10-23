import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hezzstar/main.dart';

class OfflineBotPopup {
  /// Sleek animated Offline Bot Popup with glass effect and particle animation
  static void show(BuildContext context, String avatarPath) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue =
            Curves.easeOutBack.transform(animation.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0, curvedValue * -50, 0)
            ..scale(animation.value),
          child: Opacity(
            opacity: animation.value,
            child: _AnimatedBotDialog(avatarPath: avatarPath),
          ),
        );
      },
    );
  }
}

class _AnimatedBotDialog extends StatefulWidget {
  final String avatarPath;

  const _AnimatedBotDialog({required this.avatarPath});

  @override
  State<_AnimatedBotDialog> createState() => _AnimatedBotDialogState();
}

class _AnimatedBotDialogState extends State<_AnimatedBotDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    for (int i = 0; i < 30; i++) {
      _particles.add(_Particle.random());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final width = media.width * 0.65;
    final height = media.height * 0.45;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          for (var p in _particles) {
            p.update();
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              // 🌌 Background particles
              CustomPaint(
                size: Size(width, height),
                painter: _ParticlePainter(_particles),
              ),

              // 🧊 Glass container
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.tealAccent.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  backgroundBlendMode: BlendMode.overlay,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✨ Avatar with glow
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.tealAccent.withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: width * 0.22,
                        backgroundImage: AssetImage(widget.avatarPath),
                        backgroundColor: Colors.teal.withOpacity(0.2),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 💬 Title Text
                    Text(
                      tr(context).noConnection,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent.shade100,
                        letterSpacing: 1.2,
                          decoration: TextDecoration.none
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      tr(context).notConnectedToInternet,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,

                        decoration: TextDecoration.none
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🎛️ Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shadowColor: Colors.tealAccent.withOpacity(0.4),
                        elevation: 10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        tr(context).close,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 🪐 Particle system for background
class _Particle {
  double x, y, radius, dx, dy;
  final random = Random();

  _Particle(this.x, this.y, this.radius, this.dx, this.dy);

  factory _Particle.random() {
    final random = Random();
    return _Particle(
      random.nextDouble(),
      random.nextDouble(),
      0.5 + random.nextDouble() * 1.5,
      (random.nextDouble() - 0.5) * 0.002,
      (random.nextDouble() - 0.5) * 0.002,
    );
  }

  void update() {
    x += dx;
    y += dy;
    if (x < 0 || x > 1) dx = -dx;
    if (y < 0 || y > 1) dy = -dy;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.tealAccent.withOpacity(0.4);
    for (var p in particles) {
      canvas.drawCircle(
          Offset(p.x * size.width, p.y * size.height), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
