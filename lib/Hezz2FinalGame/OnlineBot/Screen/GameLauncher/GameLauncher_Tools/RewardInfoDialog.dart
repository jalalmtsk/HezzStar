import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:provider/provider.dart';

import '../../../../../main.dart';
import '../../../../Models/GameCardEnums.dart';


class RewardDialog extends StatelessWidget {
  final int botCount;
  final int betGold;
  final GameModeType gameMode;

  const RewardDialog({
    super.key,
    required this.botCount,
    required this.betGold,
    required this.gameMode,
  });

  String _formatNumber(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {

    final xpManager = Provider.of<ExperienceManager>(context, listen: false);

    final int playerCount = botCount + 1;
    final int totalPool = betGold * playerCount;

    // Compute prizes
    Map<int, int> prizes = {};
    if (gameMode == GameModeType.playToWin) {
      for (int i = 0; i < playerCount; i++) {
        prizes[i] = i == 0 ? totalPool : 0; // first player wins all
      }
    } else {
      List<int> weights =
      List.generate(playerCount, (i) => pow(2, playerCount - i - 1).toInt());
      int sumWeights = weights.reduce((a, b) => a + b);
      for (int i = 0; i < playerCount; i++) {
        prizes[i] = (totalPool * weights[i] / sumWeights).toInt();
      }
    }

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              tr(context).rewardDistribution,
              style: TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${tr(context).totalPool}: ${_formatNumber(totalPool)} G",
                      style: const TextStyle(
                          color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playerCount,
                itemBuilder: (context, index) {
                  double fraction = prizes[index]! / totalPool;
                  bool isWinner = prizes[index] == prizes.values.reduce(max);
                  int loss = betGold - prizes[index]!;

                  return Card(
                    color: Colors.grey[850],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          // Player header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isWinner ? Colors.amber : Colors.blueGrey[700],
                                    child: Text("${index + 1}",
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    index == 0 ? xpManager.username : "${tr(context).player} ${index + 1}",
                                    style: TextStyle(
                                        color: isWinner ? Colors.amberAccent : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              Text(
                                "+${_formatNumber(prizes[index]!)} G",
                                style: TextStyle(
                                    color: isWinner ? Colors.amber : Colors.yellowAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Bet / Win / Loss row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${tr(context).bet}: ${_formatNumber(betGold)} G",
                                  style: const TextStyle(color: Colors.white54)),

                              Text(
                                  "${tr(context).loss}: ${_formatNumber(loss > 0 ? loss : 0)} G",
                                  style: const TextStyle(color: Colors.redAccent)),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Progress bar visualization
                          Stack(
                            children: [
                              Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: fraction,
                                child: Container(
                                  height: 16,
                                  decoration: BoxDecoration(
                                    gradient: isWinner
                                        ? const LinearGradient(
                                        colors: [Colors.amber, Colors.orangeAccent])
                                        : const LinearGradient(
                                        colors: [Colors.blue, Colors.lightBlueAccent]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child:  Text(
                  tr(context).close,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
