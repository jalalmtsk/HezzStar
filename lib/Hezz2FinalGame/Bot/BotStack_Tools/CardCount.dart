import 'package:flutter/material.dart';

class CardCount extends StatelessWidget {
  final int count;
  const CardCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      "$count cards",
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))],
      ),
    );
  }
}
