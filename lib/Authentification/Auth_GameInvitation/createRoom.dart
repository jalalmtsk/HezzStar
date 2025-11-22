// lib/CreateRoomScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../FirebaseServiceManagement.dart';
import 'LobbyScreen.dart';
import '../../ExperieneManager.dart';
import '../../tools/AudioManager/AudioManager.dart';
import '../../main.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  int _maxPlayers = 2;
  bool _creating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final xp = context.read<ExperienceManager>();
    _nicknameController.text = xp.username ?? "Player";
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final audio = context.read<AudioManager>();
    audio.playEventSound('sandClick');

    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      setState(() => _error = "tr(context).enterNickname" ?? "Please enter a nickname.");
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final gameService = context.read<FirebaseGameService>();
      final xpManager = Provider.of<ExperienceManager>(context, listen: false);
      final roomId = await gameService.createRoom(
        nickname: xpManager.username ?? "Player",
        maxPlayers: _maxPlayers,
        avatarPath: xpManager.selectedAvatar.toString(),
      );

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
        setState(() => _creating = false);
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
                  Color(0xFF120d25),
                  Color(0xFF5f2581),
                  Color(0xFFf4b415),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
                    "tr(context).createRoom" ?? "Create Room",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "tr(context).createRoomDescription" ??
                        "Set your nickname and choose how many players can join.",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 24),

                  // nickname field
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.amberAccent, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "tr(context).maxPlayers" ?? "Max players",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 10,
                    children: [2, 3, 4, 5].map((p) {
                      final bool selected = _maxPlayers == p;
                      return ChoiceChip(
                        label: Text(
                          "$p ${tr(context).players ?? "players"}",
                          style: TextStyle(
                            color: selected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: selected,
                        selectedColor: Colors.amberAccent,
                        backgroundColor: Colors.black.withOpacity(0.35),
                        onSelected: (_) {
                          setState(() => _maxPlayers = p);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

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
                      icon: _creating
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : const Icon(Icons.play_arrow, color: Colors.black),
                      label: Text(
                        _creating
                            ? ("tr(context).creating" ?? "Creating...")
                            : ("tr(context).createAndEnter" ?? "Create & Enter Lobby"),
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
                      onPressed: _creating ? null : _createRoom,
                    ),
                  ),

                  const Spacer(),

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
