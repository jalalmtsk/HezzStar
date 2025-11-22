// lib/JoinRoomScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../FirebaseServiceManagement.dart';
import 'LobbyScreen.dart';
import '../../ExperieneManager.dart';
import '../../tools/AudioManager/AudioManager.dart';
import '../../main.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  bool _joining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final xp = context.read<ExperienceManager>();
    _nicknameController.text = xp.username ?? "Player";
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final audio = context.read<AudioManager>();
    audio.playEventSound('sandClick');

    final roomCode = _roomCodeController.text.trim().toUpperCase();
    final nickname = _nicknameController.text.trim();

    if (roomCode.isEmpty || roomCode.length < 4) {
      setState(() => _error = "tr(context).enterValidRoomCode" ?? "Please enter a valid room code.");
      return;
    }
    if (nickname.isEmpty) {
      setState(() => _error = "tr(context).enterNickname" ?? "Please enter a nickname.");
      return;
    }

    setState(() {
      _joining = true;
      _error = null;
    });

    try {
      final gameService = context.read<FirebaseGameService>();
      final xpManager = Provider.of<ExperienceManager>(context, listen: false);
      final roomId = await gameService.joinRoom(
        roomCode: roomCode,
        nickname: xpManager.username ?? "Player",
          avatarPath: xpManager.selectedAvatar.toString(),   // 👈 your avatar system
      );

      if (roomId == null) {
        setState(() {
          _error = "tr(context).roomNotFound" ?? "Room not found or already playing.";
        });
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiplayerLobbyScreen(roomId: roomId),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _joining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final xpManager = context.watch<ExperienceManager>();

    return Scaffold(
      body: Stack(
        children: [
          // background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0f0b1f),
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
                  // back
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "tr(context).joinRoom" ?? "Join Room",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "tr(context).joinRoomDescription" ??
                        "Enter the 6-letter room code shared by your friend.",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 24),

                  // room code
                  TextField(
                    controller: _roomCodeController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      counterText: "",
                      labelText: "tr(context).roomCode" ?? "Room Code",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Colors.amberAccent, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // nickname
                  TextField(
                    controller: _nicknameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "tr(context).nickname" ?? "Nickname",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Colors.amberAccent, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _joining
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : const Icon(Icons.login, color: Colors.black),
                      label: Text(
                        _joining
                            ? ("tr(context).joining" ?? "Joining...")
                            : ("tr(context).joinNow" ?? "Join Now"),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _joining ? null : _joinRoom,
                    ),
                  ),

                  const Spacer(),

                  Center(
                    child: Text(
                      "tr(context).tipShareCode" ??
                          "Tip: Ask your friend to send you the room code from the lobby.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: xpManager.selectedAvatar != null
                            ? AssetImage(xpManager.selectedAvatar!)
                            : const AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png"),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        xpManager.username ?? "You",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
