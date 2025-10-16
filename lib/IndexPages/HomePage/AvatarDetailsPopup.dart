import 'package:flutter/material.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:lottie/lottie.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:provider/provider.dart';

class AvatarDetailsPopup {
  static void show(BuildContext context, ExperienceManager xpManager) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // base scale depending on shortest side
            final base = constraints.biggest.shortestSide;
            final scale = base / 400.0; // 400 = reference size (medium phone)
            final audioManager = Provider.of<AudioManager>(context, listen: false);
            audioManager.playEventSound("sandClick");
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.8,
                maxWidth: constraints.maxWidth * 0.95,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black87, Colors.grey[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(color: Colors.amberAccent, width: 1.5 * scale),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar with sparkling Lottie behind
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120 * scale,
                            height: 120 * scale,
                            child: Lottie.asset(
                              'assets/animations/AnimationSFX/RewawrdLightEffect.json',
                              repeat: true,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: 90 * scale,
                            height: 90 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Colors.amberAccent.withOpacity(0.8), Colors.transparent],
                                radius: 0.9,
                                center: Alignment.center,
                              ),
                              border: Border.all(color: Colors.amber, width: 2 * scale),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amberAccent.withOpacity(0.6),
                                  blurRadius: 8 * scale,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.withOpacity(0.3),
                              backgroundImage: xpManager.selectedAvatar != null
                                  ? AssetImage(xpManager.selectedAvatar!)
                                  : const AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10 * scale),

                      // Name + Edit
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              xpManager.userProfile.username ?? "UserName",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          GestureDetector(
                            onTap: () => _showEditUsernameDialog(context, xpManager),
                            child: Icon(Icons.edit, color: Colors.amber, size: 18 * scale),
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        "Rank: (UnRanked)",
                        style: TextStyle(color: Colors.amber, fontSize: 14 * scale),
                      ),
                      SizedBox(height: 8 * scale),

                      // Stats using Wrap (auto-wrap to avoid overflow)
                      Wrap(
                        spacing: 6 * scale,
                        runSpacing: 6 * scale,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildStat("Level", xpManager.level.toString(), scale),
                          _buildStat("Total Earnings", xpManager.totalGoldEarned.toString(), scale),
                          _buildStat("Gold", xpManager.gold.toString(), scale),
                          _buildStat("Wins 1v1", xpManager.wins1v1.toString(), scale),
                          _buildStat("Wins 3 Players", xpManager.wins3Players.toString(), scale),
                          _buildStat("Wins 4 Players", xpManager.wins4Players.toString(), scale),
                          _buildStat("Wins 5 Players", xpManager.wins5Players.toString(), scale),

                        ],
                      ),

                      SizedBox(height: 10 * scale),
                      Divider(color: Colors.white24),
                      SizedBox(height: 10 * scale),

                      // Unlocks Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: _buildUnlock("Skins", xpManager.unlockedCards.length.toString(), scale)),
                          Expanded(child: _buildUnlock("Tables", xpManager.unlockedTableSkins.length.toString(), scale)),
                          Expanded(child: _buildUnlock("Avatars", xpManager.unlockedAvatars.length.toString(), scale)),
                        ],
                      ),
                      SizedBox(height: 14 * scale),

                      // Close Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
                          padding: EdgeInsets.symmetric(vertical: 10 * scale, horizontal: 20 * scale),
                        ),
                        onPressed: () {
                          final audioManager = Provider.of<AudioManager>(context, listen: false);
                          audioManager.playEventSound("sandClick");
                          Navigator.pop(context);},
                        child: Text("Close", style: TextStyle(fontSize: 14 * scale)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static void _showEditUsernameDialog(BuildContext context, ExperienceManager xpManager) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playEventSound("sandClick");
    final controller = TextEditingController(
      text: xpManager.userProfile.username ?? "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.black87,
        title: const Text("Edit Username", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLength: 9, // Limit input to 9 characters
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new username",
            hintStyle: TextStyle(color: Colors.white54),
            counterStyle: TextStyle(color: Colors.white54), // optional: counter color
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber, width: 2)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                final audioManager = Provider.of<AudioManager>(context, listen: false);
                audioManager.playEventSound("sandClick");
                Navigator.pop(context);},
              child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              String newName = controller.text.trim();
              if (newName.isNotEmpty) {
                if (newName.length > 9) newName = newName.substring(0, 9); // truncate if somehow exceeded
                await xpManager.setUsername(newName);
              }
              Navigator.pop(context); // close edit dialog
              Navigator.pop(context); // close popup
              show(context, xpManager); // reopen popup with updated name
            },
            child: const Text("Save", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }


  static Widget _buildStat(String title, String value, double scale) {
    return Container(
      width: 140 * scale,
      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(color: Colors.white, fontSize: 14 * scale, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 12 * scale)),
        ],
      ),
    );
  }

  static Widget _buildUnlock(String title, String value, double scale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(color: Colors.white, fontSize: 16 * scale, fontWeight: FontWeight.bold)),
        SizedBox(height: 4 * scale),
        Text(title, style: TextStyle(color: Colors.white70, fontSize: 13 * scale)),
      ],
    );
  }
}
