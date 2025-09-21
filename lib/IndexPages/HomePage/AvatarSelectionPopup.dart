import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';

class AvatarDetailsPopup {
  static void show(BuildContext context, ExperienceManager xpManager) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.black87,
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Preview
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.withValues(alpha: 0.8),
                  backgroundImage: xpManager.selectedAvatar != null
                      ? AssetImage(xpManager.selectedAvatar!)
                      : const AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png"),
                ),
                const SizedBox(height: 10),

                // Name & Rank
                Text(
                  "Player Name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Rank: Diamond III",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),

                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _buildStat("Level", "27"),
                    _buildStat("Total Earnings", "12,450"),
                    _buildStat("Gold", "3,200"),
                    _buildStat("Wins 1v1", "85"),
                    _buildStat("Wins 2 Players", "40"),
                    _buildStat("Wins 3 Players", "22"),
                    _buildStat("Wins 4 Players", "18"),
                    _buildStat("Wins 5 Players", "10"),
                  ],
                ),
                const SizedBox(height: 20),

                // Unlocks Section
                Divider(color: Colors.white24),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildUnlock("Skins", "12"),
                    _buildUnlock("Tables", "6"),
                    _buildUnlock("Avatars", "9"),
                  ],
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildStat(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              )),
        ],
      ),
    );
  }

  static Widget _buildUnlock(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            )),
      ],
    );
  }
}
