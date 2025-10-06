import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

import '../../../ExperieneManager.dart';
import '../../Bot/BotAvatars.dart';
import '../../Bot/BotInfoModel.dart';
import '../../Bot/BotNames.dart';
import '../../Bot/BotStack.dart';

class BotDetailsPopup {
  static final Map<int, BotInfo> botInfos = {};

  // Make emojiCosts static
  static const Map<String, int> emojiCosts = {
    "🎁": 50,
    "💎": 100,
    "⭐": 75,
    "❤️": 60,
    "🔥": 120,
  };

  static BotInfo getBotInfo(int bot) {
    final random = Random();
    const String defaultAvatar = "assets/images/Skins/AvatarSkins/DefaultUser.png";

    String avatarPath = botAvatars.isNotEmpty
        ? botAvatars[random.nextInt(botAvatars.length)]
        : defaultAvatar;

    String botName = botNames.isNotEmpty
        ? botNames[random.nextInt(botNames.length)]
        : 'User $bot';

    return botInfos.putIfAbsent(bot, () => BotInfo(
      name: botName,
      avatarPath: avatarPath,
      level: random.nextInt(50) + 1,
      gold: random.nextInt(10000),
      totalEarnings: random.nextInt(50000),
      wins1v1: random.nextInt(100),
      wins2: random.nextInt(50),
      wins3: random.nextInt(30),
      wins4: random.nextInt(20),
      wins5: random.nextInt(10),
    ));
  }

  static void show(
      BuildContext context,
      int bot,
      ExperienceManager expManager,
      List<List<dynamic>> hands,
      List<bool> eliminatedPlayers,
      List<int> qualifiedPlayers,
      int currentPlayer,
      ) {
    final info = getBotInfo(bot);
    final media = MediaQuery.of(context).size;
    final width = media.width * 0.85;
    final height = media.height * 0.6;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: width,
              height: height,
              padding: EdgeInsets.all(width * 0.05),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.grey[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: width * 0.30,
                        height: width * 0.30,
                        child: Lottie.asset(
                          'assets/animations/AnimationSFX/RewawrdLightEffect.json',
                          repeat: true,
                          fit: BoxFit.cover,
                        ),
                      ),
                      CircleAvatar(
                        radius: width * 0.12,
                        backgroundColor: Colors.blueGrey.shade700,
                        backgroundImage: AssetImage(info.avatarPath),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    info.name,
                    style: TextStyle(
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Wrap(
                    spacing: width * 0.03,
                    runSpacing: height * 0.015,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildStat("Level", info.level.toString(), width),
                      _buildStat("Gold", info.gold.toString(), width),
                      _buildStat("Earnings", info.totalEarnings.toString(), width),
                      _buildStat("Wins 1v1", info.wins1v1.toString(), width),
                      _buildStat("Wins 2P", info.wins2.toString(), width),
                      _buildStat("Wins 3P", info.wins3.toString(), width),
                      _buildStat("Wins 4P", info.wins4.toString(), width),
                      _buildStat("Wins 5P", info.wins5.toString(), width),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.015, horizontal: width * 0.15),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close", style: TextStyle(fontSize: width * 0.045)),
                  )
                ],
              ),
            ),
            // Gift Button positioned at top-right
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.card_giftcard, color: Colors.amberAccent, size: width * 0.08),
                    onPressed: () {
                      Navigator.pop(context); // Close current bot dialog

                      // Show emoji selection dialog
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) {
                          final media = MediaQuery.of(context).size;
                          final dialogWidth = media.width * 0.8;
                          final dialogHeight = media.height * 0.25;

                          return Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                            child: Center(
                              child: Container(
                                width: dialogWidth,
                                height: dialogHeight,
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.grey.shade900, Colors.black87],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: Colors.amberAccent, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amberAccent.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Choose a Gift",
                                      style: TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: dialogWidth * 0.07,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(color: Colors.black, blurRadius: 4),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _emojiCard(context, "🎁", expManager),
                                          _emojiCard(context, "💎", expManager),
                                          _emojiCard(context, "⭐", expManager),
                                          _emojiCard(context, "❤️", expManager),
                                          _emojiCard(context, "🔥", expManager),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 static Widget _emojiCard(BuildContext context, String emoji, ExperienceManager expManager) {
    final int cost = BotDetailsPopup.emojiCosts[emoji] ?? 50;

    return GestureDetector(
      onTap: () async {
        bool success = await expManager.spendGold(cost);
        if (success) {
          Navigator.pop(context);
          print("Sent $emoji for $cost gold");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Not enough gold for $emoji!")),
          );
        }
      },
      child: Container(
        width: 60,
        height: 90,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.grey.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amberAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.amberAccent.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 32)),
            SizedBox(height: 6),
            Text(
              "$cost 💰",
              style: TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStat(String title, String value, double width) {
    return Container(
      width: width * 0.25,
      padding: EdgeInsets.symmetric(vertical: width * 0.025),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.bold)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: width * 0.035,
                )),
          ),
        ],
      ),
    );
  }

  static void resetBotInfos() {
    botInfos.clear();
  }
}
