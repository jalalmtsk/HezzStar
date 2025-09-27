import 'package:flutter/material.dart';

import '../Tools/Dialog/BotPlayerInfoDialog.dart';
import 'BotInfoModel.dart';

// ================= PLAYER CARD =================
class PlayerCard extends StatelessWidget {
  final int bot;
  final bool vertical;
  final bool isEliminated;
  final bool isQualified;
  final bool isTurn;
  final int cardCount;
  final List<dynamic> hand; // Replace with your Card type
  final Key? playerKey;

  const PlayerCard({
    super.key,
    required this.bot,
    required this.vertical,
    required this.isEliminated,
    required this.isQualified,
    required this.isTurn,
    required this.cardCount,
    required this.hand,
    this.playerKey,
  });

  @override
  Widget build(BuildContext context) {
    // Lazily get bot info
    final info = BotDetailsPopup.getBotInfo(bot);

    Color borderColor = Colors.white70;
    Color statusColor = Colors.white;
    String statusText = '';

    if (isEliminated) {
      borderColor = Colors.redAccent;
      statusColor = Colors.redAccent;
      statusText = 'OUT';
    } else if (isQualified) {
      borderColor = Colors.blueAccent;
      statusColor = Colors.blueAccent;
      statusText = 'QUAL';
    } else if (isTurn) {
      borderColor = Colors.greenAccent;
      statusColor = Colors.greenAccent;
      statusText = 'TURN';
    }

    return Container(
      key: playerKey,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(2, 3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlayerHeader(info: info, statusColor: statusColor, statusText: statusText, isTurn: isTurn),
          const SizedBox(height: 8),
          _CardPreview(hand: hand, vertical: vertical),
          const SizedBox(height: 6),
          _CardCount(count: cardCount),
        ],
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  final BotInfo info;
  final Color statusColor;
  final String statusText;
  final bool isTurn;

  const _PlayerHeader({
    required this.info,
    required this.statusColor,
    required this.statusText,
    this.isTurn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isTurn)
              SizedBox(
                width: 38,
                height: 38,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: 0),
                  duration: const Duration(seconds: 10),
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      color: statusColor,
                      backgroundColor: statusColor.withOpacity(0.2),
                      strokeWidth: 3,
                    );
                  },
                ),
              ),
            CircleAvatar(
              radius: 16,
              backgroundColor: statusColor.withOpacity(0.15),
              backgroundImage: AssetImage(info.avatarPath),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          info.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black,
                offset: Offset(1, 1),
              )
            ],
          ),
        ),
        if (statusText.isNotEmpty) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ]
      ],
    );
  }
}

class _CardPreview extends StatelessWidget {
  final List<dynamic> hand;
  final bool vertical;

  const _CardPreview({required this.hand, required this.vertical});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: vertical ? 50 : 60,
      height: vertical ? 65 : 75,
      child: Stack(
        children: [
          for (int i = 0; i < hand.length && i < 3; i++)
            Positioned(
              left: i * 6,
              top: i * 3,
              child: Image.asset(
                hand.isNotEmpty
                    ? hand.first.backAsset(context)
                    : 'assets/images/cards/backCard.png',
                width: 55,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}

class _CardCount extends StatelessWidget {
  final int count;
  const _CardCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      "$count cards",
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [Shadow(blurRadius: 3, color: Colors.black, offset: Offset(1, 1))],
      ),
    );
  }
}