import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:hezzstar/ExperieneManager.dart';

class AvatarDetailsPopup {
  static void show(BuildContext context, ExperienceManager xpManager) {
    final media = MediaQuery.of(context).size;
    final width = media.width * 0.85;
    final height = media.height * 0.75;

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
            border: Border.all(color: Colors.amberAccent, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Avatar with sparkling Lottie behind
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: width * 0.4,
                    height: width * 0.4,
                    child: Lottie.asset(
                      'assets/animations/AnimationSFX/RewawrdLightEffect.json',
                      repeat: true,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: width * 0.3,
                    height: width * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.amberAccent.withOpacity(0.8), Colors.transparent],
                        radius: 0.9,
                        center: Alignment.center,
                      ),
                      border: Border.all(color: Colors.amber, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amberAccent.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      backgroundImage: xpManager.selectedAvatar != null
                          ? AssetImage(xpManager.selectedAvatar!)
                          : const AssetImage(
                          "assets/images/Skins/AvatarSkins/DefaultUser.png"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),

              // Name + Edit
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      xpManager.userProfile.username ?? "UserName",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: width * 0.007),
                  GestureDetector(
                    onTap: () => _showEditUsernameDialog(context, xpManager),
                    child: Icon(Icons.edit, color: Colors.amber, size: width * 0.06),
                  ),
                ],
              ),
              SizedBox(height: height * 0.007),
              Text(
                "Rank: (UnRanked)",
                style: TextStyle(color: Colors.amber, fontSize: width * 0.045),
              ),
              SizedBox(height: height * 0.007),

              // Stats using Wrap (no scroll, auto-wrap)
              Wrap(
                spacing: width * 0.02,
                runSpacing: height * 0.015,
                alignment: WrapAlignment.center,
                children: [
                  _buildStat("Level", xpManager.level.toString(), width),
                  _buildStat("Total Earnings", "12,450", width),
                  _buildStat("Gold", xpManager.gold.toString(), width),
                  _buildStat("Wins 1v1", "85", width),
                  _buildStat("Wins 2 Players", "40", width),
                  _buildStat("Wins 3 Players", "22", width),
                  _buildStat("Wins 4 Players", "18", width),
                  _buildStat("Wins 5 Players", "10", width),
                ],
              ),

              SizedBox(height: height * 0.007),
              Divider(color: Colors.white24),
              SizedBox(height: height * 0.015),

              // Unlocks Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildUnlock("Skins", xpManager.unlockedCards.length.toString(), width)),
                  Expanded(child: _buildUnlock("Tables", xpManager.unlockedTableSkins.length.toString(), width)),
                  Expanded(child: _buildUnlock("Avatars", xpManager.unlockedAvatars.length.toString(), width)),
                ],
              ),
              SizedBox(height: height * 0.02),

              // Close Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.1),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Close", style: TextStyle(fontSize: width * 0.045)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showEditUsernameDialog(BuildContext context, ExperienceManager xpManager) {
    final controller = TextEditingController(text: xpManager.userProfile.username ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.black87,
        title: const Text("Edit Username", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new username",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber, width: 2)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await xpManager.setUsername(controller.text.trim());
              }
              Navigator.pop(context);
              Navigator.pop(context);
              show(context, xpManager);
            },
            child: const Text("Save", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  static Widget _buildStat(String title, String value, double width) {
    return Container(
      width: width * 0.4, // each stat takes 40% width
      padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: width * 0.025),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(color: Colors.white, fontSize: width * 0.045, fontWeight: FontWeight.bold)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title, style: TextStyle(color: Colors.white70, fontSize: width * 0.035)),
          ),
        ],
      ),
    );
  }

  static Widget _buildUnlock(String title, String value, double width) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              style: TextStyle(color: Colors.white, fontSize: width * 0.05, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: width * 0.01),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(title, style: TextStyle(color: Colors.white70, fontSize: width * 0.04)),
        ),
      ],
    );
  }
}
