import 'package:flutter/material.dart';

import '../../../main.dart';

class CardCountBadge extends StatelessWidget {
  final int remaining;
  final Color accentColor; // optional accent line color
  final double fontSize;

  const CardCountBadge({
    super.key,
    required this.remaining,
    this.accentColor = Colors.lightBlueAccent,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small accent circle on top
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 3),
        // Badge background
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Text(
            '$remaining ${tr(context).cards}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
