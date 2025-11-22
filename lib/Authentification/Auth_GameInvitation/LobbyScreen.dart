import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hezzstar/FirebaseServiceManagement.dart';
import '../../Hezz2FinalGame/PlayWithFriend/OnlineGameScreen.dart';
import 'OnlineGameScreen.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  final String roomId;

  const MultiplayerLobbyScreen({super.key, required this.roomId});

  @override
  State<MultiplayerLobbyScreen> createState() =>
      _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  bool _starting = false;
  bool _leaving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final gameService = context.read<FirebaseGameService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hezz2 Lobby'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _leaving
              ? null
              : () async {
            setState(() => _leaving = true);
            try {
              await gameService.leaveRoom(widget.roomId);
            } catch (_) {}
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: gameService.watchRoom(widget.roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.exists) {
            return const Center(
              child: Text('Room closed.'),
            );
          }

          final data = snapshot.data!.data()!;
          final status = data['status'] ?? 'lobby';
          final players = List<Map<String, dynamic>>.from(
            (data['players'] as List<dynamic>? ?? [])
                .map((p) => Map<String, dynamic>.from(p)),
          );
          final hostId = data['hostId'] as String;
          final myUid = gameService.currentUserIdSync ?? '';

          final me = players.firstWhere(
                (p) => p['uid'] == myUid,
            orElse: () => <String, dynamic>{},
          );
          final bool isHost = myUid == hostId;
          final bool amReady = (me['isReady'] ?? false) as bool;

          // If game already started, go to game screen
          if (status == 'playing') {
            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => OnlineGameScreen(roomId: widget.roomId),
                ),
              );
            });
          }

          final allReady = players.isNotEmpty &&
              players.every((p) => (p['isReady'] ?? false) == true);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Room Code: ${data['roomCode'] ?? '??????'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  isHost
                      ? 'You are the host. Start the game when everyone is ready.'
                      : 'Waiting for the host to start the game…',
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final p = players[index];
                      final uid = p['uid'] as String;
                      final nickname = p['nickname'] ?? 'Player';
                      final isReady = (p['isReady'] ?? false) as bool;
                      final isPlayerHost = uid == hostId;

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            isPlayerHost ? Icons.star : Icons.person,
                            color:
                            isPlayerHost ? Colors.orange : Colors.white,
                          ),
                          title: Text(nickname),
                          subtitle: Text(
                            isPlayerHost
                                ? 'Host'
                                : (isReady ? 'Ready' : 'Not ready'),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (uid == myUid)
                                Switch(
                                  value: amReady,
                                  onChanged: (val) async {
                                    try {
                                      await gameService.setReady(
                                        roomId: widget.roomId,
                                        isReady: val,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                          Text('Error: $e'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              if (isHost && uid != myUid)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () async {
                                    try {
                                      await gameService.kickPlayer(
                                        roomId: widget.roomId,
                                        playerUid: uid,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                          Text('Error: $e'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(
                        amReady ? Icons.check_circle : Icons.radio_button_unchecked,
                      ),
                      label: Text(amReady ? 'Ready' : 'Set Ready'),
                      onPressed: () async {
                        try {
                          await gameService.setReady(
                            roomId: widget.roomId,
                            isReady: !amReady,
                          );
                        } catch (e) {
                          setState(() => _error = e.toString());
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    if (isHost)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Game'),
                        onPressed: !_starting
                            ? () async {
                          setState(() {
                            _starting = true;
                            _error = null;
                          });
                          try {
                            await gameService.startGame(
                              widget.roomId,
                              handSize: 5,
                            );
                          } catch (e) {
                            setState(() => _error = e.toString());
                          } finally {
                            if (mounted) {
                              setState(() => _starting = false);
                            }
                          }
                        }
                            : null,
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                if (isHost && !allReady)
                  const Text(
                    'All players must be ready to start.',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
