import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

import '../../Bot/BotInfoModel.dart';
import '../../Bot/BotNames.dart';

class BotDetailsPopup {
  static final Map<int, BotInfo> botInfos = {};

  static BotInfo getBotInfo(int bot) {
    return botInfos.putIfAbsent(bot, () {
      final random = Random();
      const String defaultAvatar = "assets/images/Skins/AvatarSkins/DefaultUser.png";

      List<String> botAvatars = [
        "assets/images/Skins/AvatarSkins/DefaultUser.png",
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster1.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster2.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster3.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster4.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster5.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster6.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster7.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster8.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster9.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster10.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster11.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster12.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster13.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster14.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster15.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster16.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster17.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster18.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster19.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster20.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster21.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster22.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster23.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster24.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster25.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster26.png',
        'assets/images/Skins/AvatarSkins/CardMaster/CardMaster27.png',

        'assets/images/Skins/AvatarSkins/Elements/Elements1.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements2.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements3.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements4.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements5.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements6.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements7.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements8.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements9.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements10.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements11.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements12.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements13.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements14.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements15.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements16.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements17.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements18.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements19.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements20.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements21.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements22.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements23.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements24.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements25.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements26.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements27.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements28.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements29.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements30.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements31.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements32.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements33.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements34.png',
        'assets/images/Skins/AvatarSkins/Elements/Elements35.png',

        'assets/images/Skins/AvatarSkins/Warriors/Warrior1.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior2.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior3.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior4.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior5.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior6.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior7.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior8.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior9.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior10.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior11.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior12.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior13.png',
        'assets/images/Skins/AvatarSkins/Warriors/Warrior14.png',



      ];

      String avatarPath = botAvatars.isNotEmpty
          ? botAvatars[random.nextInt(botAvatars.length)]
          : defaultAvatar;

      String botName = botNames.isNotEmpty
          ? botNames[random.nextInt(botNames.length)]
          : 'User $bot';

      return BotInfo(
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
              child: IconButton(
                icon: Icon(Icons.card_giftcard, color: Colors.amberAccent, size: width * 0.08),
                onPressed: () {
                  Navigator.pop(context); // Close current bot dialog

                  // Show emoji selection dialog
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.black87,
                      title: Text(
                        "Choose a Gift",
                        style: TextStyle(color: Colors.amberAccent),
                      ),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _emojiButton(context, "🎁"),
                          _emojiButton(context, "💎"),
                          _emojiButton(context, "⭐"),
                          _emojiButton(context, "❤️"),
                          _emojiButton(context, "🔥"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _emojiButton(BuildContext context, String emoji) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close emoji dialog
        print("Selected emoji: $emoji"); // Handle selection
        // Here you can trigger showing the emoji on the bot's avatar
      },
      child: Text(
        emoji,
        style: TextStyle(fontSize: 32),
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
