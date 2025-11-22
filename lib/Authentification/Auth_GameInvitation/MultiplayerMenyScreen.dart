// lib/MultiplayerMenuScreen.dart
import 'package:flutter/material.dart';
import 'package:hezzstar/MainScreenIndex.dart';
import 'package:provider/provider.dart';

import 'createRoom.dart';
import '../../FirebaseServiceManagement.dart';
import 'LobbyScreen.dart'; // <- this is your MultiplayerLobbyScreen file
import '../../ExperieneManager.dart';
import 'joinRoom.dart';
import '../../tools/AudioManager/AudioManager.dart';
import '../../main.dart'; // for tr(context) if you want localization

class MultiplayerMenuScreen extends StatelessWidget {
  const MultiplayerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final xpManager = context.watch<ExperienceManager>();

    void playClick() {
      final audio = context.read<AudioManager>();
      audio.playEventSound('sandClick');
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (gold + purple)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1b1035),
                  Color(0xFF5f2581),
                  Color(0xFFf4b415),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
                    },
                  ),
                  const SizedBox(height: 8),

                  // Title + player avatar
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: xpManager.selectedAvatar != null
                            ? AssetImage(xpManager.selectedAvatar!)
                            : const AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png"),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "tr(context).multiplayerOnlineTitle" ?? "Hezz2 Online",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              xpManager.username ?? "Guest",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "tr(context).chooseOnlineMode" ?? "Choose an online mode",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CREATE ROOM CARD
                  _ModeCard(
                    title: "tr(context).createRoom" ?? "Create Room",
                    subtitle: "tr(context).createRoomSubtitle" ??
                        "Create a room, share code, invite friends.",
                    icon: Icons.casino,
                    emoji: "🎲",
                    onTap: () {
                      playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateRoomScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // JOIN ROOM CARD
                  _ModeCard(
                    title: "tr(context).joinRoom" ?? "Join Room",
                    subtitle: "tr(context).joinRoomSubtitle" ??
                        "Enter a 6-letter code to join your friend.",
                    icon: Icons.group,
                    emoji: "🪬",
                    onTap: () {
                      playClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JoinRoomScreen(),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  Center(
                    child: Text(
                     " tr(context).onlineNotice" ??
                          "Online mode requires a stable internet connection.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3c1c5b),
              Color(0xFFf4b415),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.black.withOpacity(0.3),
              child: Icon(icon, color: Colors.amberAccent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$emoji  $title",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 28),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
