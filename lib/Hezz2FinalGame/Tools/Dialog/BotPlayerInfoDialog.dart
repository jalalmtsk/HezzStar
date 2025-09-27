import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

import '../../Bot/BotInfoModel.dart';
import '../../Bot/BotNames.dart';

class BotDetailsPopup {
  // Stores info per bot
  static final Map<int, BotInfo> botInfos = {};

  // Initialize bot info if it doesn't exist
  static BotInfo getBotInfo(int bot) {
    return botInfos.putIfAbsent(bot, () {
      final random = Random();
      List<String> botAvatars = [
        "assets/images/Skins/AvatarSkins/CardMaster/CardMaster1.png",
        "assets/images/Skins/AvatarSkins/CardMaster/CardMaster2.png",
        "assets/images/Skins/AvatarSkins/CardMaster/CardMaster3.png",
        "assets/images/Skins/AvatarSkins/CardMaster/CardMaster4.png",
        "assets/images/Skins/AvatarSkins/CardMaster/CardMaster5.png",
        "assets/images/Skins/AvatarSkins/CardMaster/CardMaster6.png",
      ];
      int nameIndex = random.nextInt(botNames.length);
      int avatarIndex = random.nextInt(botAvatars.length);

      return BotInfo(
        name: botNames[nameIndex],
        avatarPath: botAvatars[avatarIndex],
        level: random.nextInt(50) + 1,
        gold: random.nextInt(10000),
        totalEarnings: random.nextInt(50000),
        wins1v1: random.nextInt(100),
        wins2: random.nextInt(50),
        wins3: random.nextInt(30),
        wins4: random.nextInt(20),
        wins5: random.nextInt(10),
      );
    });
  }

  static void show(
      BuildContext context,
      int bot,
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
        backgroundColor: Colors.black87,
        child: Container(
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