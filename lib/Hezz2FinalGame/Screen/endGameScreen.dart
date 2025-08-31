import 'package:flutter/material.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/Cards.dart';
import '../../ExperieneManager.dart';
import 'package:provider/provider.dart';

class EndGameScreen extends StatefulWidget {
  final List<List<PlayingCard>> hands;
  final int winnerIndex;
  final GameModeType gameModeType;
  final int currentRound;
  final int betAmount;

  const EndGameScreen({
    required this.hands,
    required this.winnerIndex,
    required this.gameModeType,
    required this.currentRound,
    required this.betAmount,
    super.key,
  });

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  bool _rewardGiven = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_rewardGiven) {
      _giveReward();
      _rewardGiven = true;
    }
  }

  void _giveReward() {
    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
    final int playerCount = widget.hands.length;
    final int totalPool = playerCount * widget.betAmount;

    int reward = 0;

    if (widget.gameModeType == GameModeType.playToWin) {
      reward = widget.winnerIndex == 0 ? totalPool : 0;
    } else {
      // Elimination Mode with percentage split
      List<double> percentages = [0.5, 0.25, 0.15, 0.10];
      reward = (totalPool *
          (widget.winnerIndex < percentages.length
              ? percentages[widget.winnerIndex]
              : 0))
          .toInt();
    }

    // Add only to winner
    if (reward > 0) {
      xpManager.addGold(reward);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int playerCount = widget.hands.length;
    final int totalPool = playerCount * widget.betAmount;

    Map<int, int> prizes = {};

    if (widget.gameModeType == GameModeType.playToWin) {
      for (int i = 0; i < playerCount; i++) {
        prizes[i] = i == widget.winnerIndex ? totalPool : 0;
      }
    } else {
      List<double> percentages = [0.5, 0.25, 0.15, 0.10];
      for (int i = 0; i < playerCount; i++) {
        prizes[i] =
            (totalPool * (i < percentages.length ? percentages[i] : 0)).toInt();
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Game Over')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              '${widget.winnerIndex == 0 ? 'You' : 'Bot ${widget.winnerIndex}'} Wins!',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent),
            ),
            const SizedBox(height: 12),
            Text(
              'Game Mode: ${widget.gameModeType == GameModeType.playToWin ? 'Play To Win' : 'Elimination'}',
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            if (widget.gameModeType == GameModeType.elimination)
              Text(
                'Rounds Played: ${widget.currentRound}',
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: playerCount,
                itemBuilder: (context, index) {
                  final gold = prizes[index] ?? 0;
                  final isWinner = index == widget.winnerIndex;

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: isWinner ? Colors.orangeAccent : Colors.white,
                    margin:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor:
                        isWinner ? Colors.white : Colors.grey[300],
                        child: Text(
                          index == 0 ? 'You' : 'B$index',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                            isWinner ? Colors.orangeAccent : Colors.black87,
                          ),
                        ),
                      ),
                      title: Text(
                        isWinner ? 'Winner' : 'No Reward',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isWinner ? Colors.white : Colors.black87,
                        ),
                      ),
                      trailing: Text(
                        isWinner ? '+$gold Gold' : '+0 Gold',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isWinner ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text(
                'Back to Main Menu',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
