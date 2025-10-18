import 'package:flutter/material.dart';

import '../../../../main.dart';

class RewardButton extends StatefulWidget {
  final VoidCallback onPressed;
  const RewardButton({super.key, required this.onPressed});

  @override
  State<RewardButton> createState() => _RewardButtonState();
}

class _RewardButtonState extends State<RewardButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.06).animate(CurvedAnimation(
          parent: _pulseController,
          curve: Curves.easeInOut,
        ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orangeAccent.shade200,
                Colors.deepOrangeAccent.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.6),
                blurRadius: 14,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.yellowAccent.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: Colors.yellowAccent, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children:  [
              const Icon(Icons.card_giftcard, color: Colors.white, size: 22),
             const SizedBox(width: 8),
              Text(
                tr(context).prizes,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
