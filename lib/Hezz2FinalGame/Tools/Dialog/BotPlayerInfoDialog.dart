import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

import '../../../ExperieneManager.dart';
import '../../../main.dart';
import '../../Bot/BotAvatars.dart';
import '../../Bot/BotInfoModel.dart';
import '../../Bot/BotNames.dart';
import '../../Bot/BotStack.dart';

class BotDetailsPopup {
  static final Map<int, BotInfo> botInfos = {};

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
                      _buildStat(tr(context).level, info.level.toString(), width),
                      _buildStat(tr(context).gold, info.gold.toString(), width),
                      _buildStat(tr(context).totalEarnings, info.totalEarnings.toString(), width),
                      _buildStat(tr(context).wins1v1, info.wins1v1.toString(), width),
                      _buildStat(tr(context).wins3Players, info.wins3.toString(), width),
                      _buildStat(tr(context).wins4Players, info.wins4.toString(), width),
                      _buildStat(tr(context).wins5Players, info.wins5.toString(), width),
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
                    child: Text(tr(context).close, style: TextStyle(fontSize: width * 0.045)),
                  )
                ],
              ),
            ),
            // Gift Button positioned at top-right
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
