import 'package:flutter/material.dart';

class MinimalBadgeText extends StatelessWidget {
  final String label;
  final Color accentColor; // optional accent line color
  final double fontSize;

  const MinimalBadgeText({
    super.key,
    required this.label,
    this.accentColor = Colors.yellowAccent,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small accent line
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 2),
        // Badge background
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Text(
            label,
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
