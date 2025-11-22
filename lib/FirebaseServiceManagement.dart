// lib/FirebaseServiceManagement.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service that handles online multiplayer logic via Firebase/Firestore.
class FirebaseGameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseGameService() {
    _ensureSignedIn();
  }

  // ---------- AUTH ----------

  Future<User> _ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  Future<String> getCurrentUserId() async {
    final user = await _ensureSignedIn();
    return user.uid;
  }

  String? get currentUserIdSync => _auth.currentUser?.uid;

  // ---------- ROOMS COLLECTION ----------

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection('rooms').withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) =>
        (snap.data() ?? <String, dynamic>{}),
        toFirestore: (value, _) => value,
      );

  // ---------- CARD HELPERS ----------

  // We store cards in Firestore as strings like "Coins_2"
  String encodeCard(String suit, int rank) => '$suit\_$rank';

  Map<String, dynamic> decodeCardCode(String code) {
    final parts = code.split('_');
    return {
      'suit': parts[0],
      'rank': int.parse(parts[1]),
    };
  }

  List<String> _buildDeckCodes() {
    // same as your Deck._build()
    const suits = ['Coins', 'Cups', 'Swords', 'Clubs'];
    const ranks = [1, 2, 3, 4, 5, 6, 7, 10, 11, 12];

    final List<String> deck = [];
    for (final s in suits) {
      for (final r in ranks) {
        deck.add(encodeCard(s, r));
      }
    }
    deck.shuffle(Random());
    return deck;
  }

  // ---------- ROOM MANAGEMENT ----------

  /// Create a new room, become host, and return the roomId.
  /// [maxPlayers] = number of human players (2 to 5 typically).
  Future<String> createRoom({
    required String nickname,
    required int maxPlayers,
    required String avatarPath,
  }) async {
    final uid = await getCurrentUserId();
    final roomCode = _generateRoomCode();

    final docRef = await _rooms.add({
      'roomCode': roomCode,
      'hostId': uid,
      'status': 'lobby',
      'createdAt': FieldValue.serverTimestamp(),
      'maxPlayers': maxPlayers,
      'players': [
        {
          'uid': uid,
          'nickname': nickname,
          'avatar': avatarPath,           // 👈 ADDED
          'isHost': true,
          'isReady': false,
        }
      ],
      'gameState': null,
    });

    return docRef.id;
  }


  /// Join a room by its 6-character roomCode.
  /// Returns roomId or null if not found.
  Future<String?> joinRoom({
    required String roomCode,
    required String nickname,
    required String avatarPath,
  }) async {
    final uid = await getCurrentUserId();

    final query = await _rooms
        .where('roomCode', isEqualTo: roomCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    final data = doc.data();

    final List players = List.from(data['players'] ?? []);

    final alreadyIn = players.any((p) => p['uid'] == uid);
    if (!alreadyIn) {
      players.add({
        'uid': uid,
        'nickname': nickname,
        'avatar': avatarPath,      // 👈 ADDED
        'isHost': false,
        'isReady': false,
      });

      await doc.reference.update({'players': players});
    }

    return doc.id;
  }


  /// Stream updates for a specific room.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchRoom(String roomId) {
    return _rooms.doc(roomId).snapshots();
  }

  /// Toggle ready state for current user in the room.
  Future<void> setReady({
    required String roomId,
    required bool isReady,
  }) async {
    final uid = await getCurrentUserId();

    await _db.runTransaction((transaction) async {
      final roomRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(roomRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      if (data['status'] != 'lobby') return;

      final List players = List.from(data['players'] ?? []);
      bool changed = false;

      for (int i = 0; i < players.length; i++) {
        final p = Map<String, dynamic>.from(players[i]);
        if (p['uid'] == uid) {
          p['isReady'] = isReady;
          players[i] = p;
          changed = true;
          break;
        }
      }

      if (!changed) return;

      transaction.update(roomRef, {'players': players});
    });
  }

  /// Leave the room. If host leaves, we delete the room.
  Future<void> leaveRoom(String roomId) async {
    final uid = await getCurrentUserId();

    await _db.runTransaction((transaction) async {
      final roomRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(roomRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final String hostId = data['hostId'];
      final List players = List.from(data['players'] ?? []);

      // Host leaving -> delete room
      if (uid == hostId) {
        transaction.delete(roomRef);
        return;
      }

      // Normal player -> remove from players list
      players.removeWhere((p) => p['uid'] == uid);
      transaction.update(roomRef, {'players': players});
    });
  }

  /// Host can kick a player out of the room.
  Future<void> kickPlayer({
    required String roomId,
    required String playerUid,
  }) async {
    final uid = await getCurrentUserId();

    await _db.runTransaction((transaction) async {
      final roomRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(roomRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      if (data['hostId'] != uid) {
        throw Exception('Only host can kick players');
      }

      final List players = List.from(data['players'] ?? []);
      players.removeWhere((p) => p['uid'] == playerUid);

      transaction.update(roomRef, {'players': players});
    });
  }

  // ---------- GAME FLOW ----------

  /// Start the game as host: build deck, deal cards, set first player.
  /// All players in the list are considered in-game.
  Future<void> startGame(String roomId, {int handSize = 5}) async {
    final uid = await getCurrentUserId();

    await _db.runTransaction((transaction) async {
      final roomRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        throw Exception('Room not found');
      }

      final data = snapshot.data()!;
      if (data['hostId'] != uid) {
        throw Exception('Only host can start the game');
      }

      final List players = List.from(data['players'] ?? []);
      if (players.length < 2) {
        throw Exception('Need at least 2 players to start');
      }

      // Require everyone ready (optional, but good UX)
      final notReady =
      players.where((p) => (p['isReady'] ?? false) == false).toList();
      if (notReady.isNotEmpty) {
        throw Exception('All players must be ready before starting.');
      }

      // Build deck of card codes
      final deck = _buildDeckCodes();

      // Deal cards
      final Map<String, List<String>> hands = {};
      for (final p in players) {
        final pid = p['uid'] as String;
        hands[pid] = [];
      }

      for (int r = 0; r < handSize; r++) {
        for (final p in players) {
          final pid = p['uid'] as String;
          if (deck.isEmpty) break;
          hands[pid]!.add(deck.removeLast());
        }
      }

      // Pick top card
      if (deck.isEmpty) {
        throw Exception('Deck empty after dealing (should not happen)');
      }
      final topCard = deck.removeLast();

      final gameState = {
        'currentTurnUid': (players.first)['uid'],
        'direction': 1, // 1 = clockwise, -1 = counter-clockwise
        'topCard': topCard,
        'deck': deck,
        'hands': hands,
        'pendingDraw': 0,
        'skipNext': false,
        'winnerUid': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      transaction.update(roomRef, {
        'status': 'playing',
        'gameState': gameState,
      });
    });
  }

  bool _isPlayableCard({
    required String cardCode,
    required String? topCardCode,
    required int pendingDraw,
  }) {
    final card = decodeCardCode(cardCode);
    if (pendingDraw > 0) {
      return card['rank'] == 2; // only 2 can be chained
    }
    if (topCardCode == null) return true;

    final top = decodeCardCode(topCardCode);
    return card['suit'] == top['suit'] || card['rank'] == top['rank'];
  }

  /// Player plays a card from their hand.
  Future<void> playCard({
    required String roomId,
    required String cardCode,
  }) async {
    final uid = await getCurrentUserId();

    await _db.runTransaction((transaction) async {
      final roomRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) throw Exception('Room not found');

      final data = snapshot.data()!;
      if (data['status'] != 'playing') {
        throw Exception('Game not in playing state');
      }

      final gameState =
      Map<String, dynamic>.from(data['gameState'] ?? {});
      if (gameState.isEmpty) throw Exception('Game not started');

      if (gameState['currentTurnUid'] != uid) {
        throw Exception('Not your turn');
      }

      final Map<String, dynamic> handsRaw =
      Map<String, dynamic>.from(gameState['hands'] ?? {});
      final List<String> myHand =
      List<String>.from(handsRaw[uid] ?? []);

      if (!myHand.contains(cardCode)) {
        throw Exception('Card not in your hand');
      }

      final String? topCardCode = gameState['topCard'] as String?;
      final int pendingDraw = (gameState['pendingDraw'] ?? 0) as int;

      if (!_isPlayableCard(
        cardCode: cardCode,
        topCardCode: topCardCode,
        pendingDraw: pendingDraw,
      )) {
        throw Exception('Card not playable');
      }

      // Remove card from hand
      myHand.remove(cardCode);
      handsRaw[uid] = myHand;

      // Handle special effects (similar to your offline logic)
      int newPendingDraw = pendingDraw;
      bool skipNext = gameState['skipNext'] ?? false;
      final decoded = decodeCardCode(cardCode);
      final int rank = decoded['rank'] as int;

      if (rank == 2) {
        newPendingDraw += 2; // Hezz2 chain
      } else if (rank == 1) {
        skipNext = true; // Skip next
      }

      // Turn handling
      final List players = List.from(data['players'] ?? []);
      final currentIndex =
      players.indexWhere((p) => p['uid'] == uid);
      final int dir = (gameState['direction'] ?? 1) as int;

      int nextIndex =
      ((currentIndex + 1 * dir) % players.length).toInt();
      if (nextIndex < 0) nextIndex += players.length;

      if (skipNext) {
        skipNext = false;
        nextIndex =
            ((nextIndex + 1 * dir) % players.length).toInt();
        if (nextIndex < 0) nextIndex += players.length;
      }

      final String nextUid = players[nextIndex]['uid'];

      // Win check
      String? winnerUid = gameState['winnerUid'];
      if (myHand.isEmpty) {
        winnerUid = uid;
      }

      gameState['hands'] = handsRaw;
      gameState['topCard'] = cardCode;
      gameState['currentTurnUid'] = winnerUid == null ? nextUid : uid;
      gameState['pendingDraw'] = newPendingDraw;
      gameState['skipNext'] = skipNext;
      gameState['winnerUid'] = winnerUid;
      gameState['lastUpdated'] = FieldValue.serverTimestamp();

      final newStatus =
      winnerUid != null ? 'finished' : data['status'];

      transaction.update(roomRef, {
        'status': newStatus,
        'gameState': gameState,
      });
    });
  }

  /// Player draws card(s).
  Future<void> drawCard(String roomId) async {
    final uid = await getCurrentUserId();

    await _db.runTransaction((transaction) async {
      final roomRef = _rooms.doc(roomId);
      final snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) throw Exception('Room not found');

      final data = snapshot.data()!;
      if (data['status'] != 'playing') {
        throw Exception('Game not in playing state');
      }

      final gameState =
      Map<String, dynamic>.from(data['gameState'] ?? {});
      if (gameState.isEmpty) throw Exception('Game not started');

      if (gameState['currentTurnUid'] != uid) {
        throw Exception('Not your turn');
      }

      List deck =
      List<String>.from(gameState['deck'] ?? <String>[]);
      final Map<String, dynamic> handsRaw =
      Map<String, dynamic>.from(gameState['hands'] ?? {});
      final List<String> myHand =
      List<String>.from(handsRaw[uid] ?? []);

      int pendingDraw = (gameState['pendingDraw'] ?? 0) as int;
      int drawCount = pendingDraw > 0 ? pendingDraw : 1;

      if (deck.isEmpty) {
        throw Exception('Deck empty');
      }

      for (int i = 0; i < drawCount; i++) {
        if (deck.isEmpty) break;
        myHand.add(deck.removeLast());
      }

      handsRaw[uid] = myHand;
      pendingDraw = 0; // reset after drawing

      // Advance turn
      final List players = List.from(data['players'] ?? []);
      final currentIndex =
      players.indexWhere((p) => p['uid'] == uid);
      final int dir = (gameState['direction'] ?? 1) as int;

      int nextIndex =
      ((currentIndex + 1 * dir) % players.length).toInt();
      if (nextIndex < 0) nextIndex += players.length;

      final String nextUid = players[nextIndex]['uid'];

      gameState['deck'] = deck;
      gameState['hands'] = handsRaw;
      gameState['pendingDraw'] = pendingDraw;
      gameState['currentTurnUid'] = nextUid;
      gameState['lastUpdated'] = FieldValue.serverTimestamp();

      transaction.update(roomRef, {
        'gameState': gameState,
      });
    });
  }

  // ---------- UTILS ----------

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(
      6,
          (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
