import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hezzstar/FirebaseServiceManagement.dart';
import 'LobbyScreen.dart';
import 'package:hezzstar/ExperieneManager.dart';

class OnlineMatchHomeScreen extends StatefulWidget {
  const OnlineMatchHomeScreen({super.key});

  @override
  State<OnlineMatchHomeScreen> createState() => _OnlineMatchHomeScreenState();
}

class _OnlineMatchHomeScreenState extends State<OnlineMatchHomeScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  late TextEditingController _nicknameController;

  int _selectedPlayers = 2;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final xp = context.read<ExperienceManager>();
    _nicknameController = TextEditingController(
      text: xp.userProfile.username ?? 'Player',
    );
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameService = context.read<FirebaseGameService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hezz2 Online'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Create Room',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Text('Players: '),
                DropdownButton<int>(
                  value: _selectedPlayers,
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                    DropdownMenuItem(value: 4, child: Text('4')),
                    DropdownMenuItem(value: 5, child: Text('5')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedPlayers = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Room'),
                onPressed: () async {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  try {
                    final xpManager = Provider.of<ExperienceManager>(context, listen: false);
                    final roomId = await gameService.createRoom(
                        nickname: xpManager.username ?? "Player",
                      maxPlayers: _selectedPlayers,
                        avatarPath: xpManager.selectedAvatar.toString(),
                    );

                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MultiplayerLobbyScreen(roomId: roomId),
                      ),
                    );
                  } catch (e) {
                    setState(() => _error = e.toString());
                  } finally {
                    if (mounted) {
                      setState(() => _loading = false);
                    }
                  }
                },
              ),

            const Divider(height: 40),

            const Text(
              'Join Room',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _roomCodeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Room Code',
                helperText: 'Ask your friend for the 6-letter code',
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Join Room'),
              onPressed: () async {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                try {
                  final xpManager = Provider.of<ExperienceManager>(context, listen: false);
                  final roomId = await gameService.joinRoom(
                    roomCode: _roomCodeController.text.trim().toUpperCase(),
                    nickname: xpManager.username ?? "Player",
                    avatarPath: xpManager.selectedAvatar.toString(),
                  );
                  if (roomId == null) {
                    setState(() => _error = 'Room not found.');
                  } else {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MultiplayerLobbyScreen(roomId: roomId),
                      ),
                    );
                  }
                } catch (e) {
                  setState(() => _error = e.toString());
                } finally {
                  if (mounted) {
                    setState(() => _loading = false);
                  }
                }
              },
            ),

            const SizedBox(height: 16),

            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
