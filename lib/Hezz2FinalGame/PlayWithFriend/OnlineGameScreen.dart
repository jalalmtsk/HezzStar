import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hezzstar/FirebaseServiceManagement.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/Cards.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:hezzstar/Hezz2FinalGame/Tools/Banner/CenteredImageEffect.dart';
import 'package:hezzstar/Hezz2FinalGame/Tools/Banner/CenterdLottieAnimation.dart';
import 'package:hezzstar/Hezz2FinalGame/Tools/Banner/CenterBanner.dart';

import 'package:hezzstar/MainScreenIndex.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:hezzstar/tools/ConnectivityManager/ConnectivityManager.dart';
import 'package:hezzstar/widgets/userStatut/SimpleUserStatusBar.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';
import '../Bot/BotStack.dart';
import '../OnlineBot/Screen/GameScreen/GameScreen__Tools/DeckCenteredPanel.dart';
import '../OnlineBot/Screen/GameScreen/GameScreen__Tools/PlayerActionPanel.dart';
import '../OnlineBot/Screen/GameScreen/GameScreen__Tools/TableBackground.dart';
import 'PWF_Screen/OnlineGameScreen_Tools/PWF_PlayerActionPanel.dart';

/// Small adapter so DeckCenterPanel can work with Firestore deck codes.
class OnlineDeckAdapter {
  final List<String> deckCodes;
  OnlineDeckAdapter(this.deckCodes);

  bool get isEmpty => deckCodes.isEmpty;
  int get length => deckCodes.length;

  // We only care about last card for backAsset()
  List<PlayingCard> get cards {
    return deckCodes.map((code) {
      final parts = code.split('_');
      final suit = parts[0];
      final rank = int.tryParse(parts[1]) ?? 1;
      return PlayingCard(suit: suit, rank: rank);
    }).toList();
  }
}

class OnlineGameScreen extends StatefulWidget {
  final String roomId;

  const OnlineGameScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  // For mapping Firestore → visuals
  String? _lastTopCardCode;
  int _lastPendingDraw = 0;

  // Center VFX (Hezz2, Skip, etc.)
  CenterLottieEffect? _centerLottie;
  CenterImageEffect? _centerImage;
  CenterBanner? _centerBanner;

  // For reconnection overlay
  bool _showDisconnectedOverlay = false;

  @override
  void initState() {
    super.initState();

    final connectivityService =
    context.read<ConnectivityService>();

    _showDisconnectedOverlay = !connectivityService.isConnected;

    connectivityService.addListener(() {
      if (!mounted) return;
      setState(() {
        _showDisconnectedOverlay = !connectivityService.isConnected;
      });
    });
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // Trigger central visual effects when special cards happen.
  void _handleVisualEffects(String? newTopCardCode, int pendingDraw) {
    if (newTopCardCode == null) return;
    if (newTopCardCode == _lastTopCardCode &&
        pendingDraw == _lastPendingDraw) return;

    final parts = newTopCardCode.split('_');
    if (parts.length != 2) {
      _lastTopCardCode = newTopCardCode;
      _lastPendingDraw = pendingDraw;
      return;
    }
    final suit = parts[0];
    final rank = int.tryParse(parts[1]) ?? 0;

    setState(() {
      _centerBanner = null;
      _centerImage = null;
      _centerLottie = null;
    });

    // Hezz2 card -> rank 2
    if (rank == 2 && pendingDraw > 0) {
      setState(() {
        _centerBanner = CenterBanner(
          text: "+$pendingDraw",
          color: Colors.orangeAccent,
          onEnd: () => setState(() => _centerBanner = null),
        );
        _centerImage = CenterImageEffect(
          imagePath: "assets/UI/Containers/Hezz2_Effect.png",
          onEnd: () => setState(() => _centerImage = null),
        );
      });
    }

    // Skip (rank 1)
    if (rank == 1) {
      setState(() {
        _centerBanner = CenterBanner(
          text: tr(context).skip,
          color: Colors.orangeAccent,
          onEnd: () => setState(() => _centerBanner = null),
        );
        _centerLottie = CenterLottieEffect(
          lottieAsset: 'assets/animations/AnimationSFX/StopPlaying.json',
          size: 300,
          onEnd: () => setState(() => _centerLottie = null),
        );
      });
    }

    _lastTopCardCode = newTopCardCode;
    _lastPendingDraw = pendingDraw;
  }

  @override
  Widget build(BuildContext context) {
    final gameService = context.read<FirebaseGameService>();
    final xpManager = context.read<ExperienceManager>();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop) {
            final quit = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text("Quit Game?"),
                content: Text(tr(context).confirmLeaveMatch),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(tr(context).cancel),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx, true);
                      try {
                        await gameService.leaveRoom(widget.roomId);
                      } catch (_) {}
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainScreen(),
                          ),
                        );
                      }
                    },
                    child: Text(tr(context).exit),
                  ),
                ],
              ),
            );

            if (quit == true && mounted) {
              try {
                await gameService.leaveRoom(widget.roomId);
              } catch (_) {}
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainScreen()),
              );
            }
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: TableBackground()),

              if (_showDisconnectedOverlay)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off,
                              size: 80, color: Colors.white),
                          const SizedBox(height: 12),
                          Text(
                            tr(context).disconnected,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: gameService.watchRoom(widget.roomId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final doc = snapshot.data!;
                  if (!doc.exists) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Room closed.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MainScreen(),
                                ),
                              );
                            },
                            child: const Text('Back'),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = doc.data()!;
                  final status = data['status'] ?? 'lobby';
                  final hostId = data['hostId'] as String;
                  final playersRaw = List<Map<String, dynamic>>.from(
                    (data['players'] as List<dynamic>? ?? [])
                        .map((p) => Map<String, dynamic>.from(p)),
                  );

                  final gameState = Map<String, dynamic>.from(
                      data['gameState'] ?? <String, dynamic>{});

                  final myUid = gameService.currentUserIdSync ?? '';
                  final myEntry = playersRaw.firstWhere(
                        (p) => p['uid'] == myUid,
                    orElse: () => <String, dynamic>{},
                  );

                  // If I'm not in players list => kicked, go home
                  if (myEntry.isEmpty) {
                    Future.microtask(() {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr(context).youHaveBeenEliminated)),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MainScreen(),
                        ),
                      );
                    });
                    return const SizedBox.shrink();
                  }

                  // === Map Firestore -> in-game seats ===
                  final List<_OnlineSeat> seats = [];
                  int seatIndexCounter = 0;
                  for (final p in playersRaw) {
                    final uid = p['uid'] as String;
                    final nickname = p['nickname'] ?? 'Player';
                    final isMe = uid == myUid;
                    final seatIndex = isMe ? 0 : ++seatIndexCounter;
                    seats.add(
                      _OnlineSeat(
                        uid: uid,
                        nickname: nickname,
                        isMe: isMe,
                        seatIndex: seatIndex,
                      ),
                    );
                  }

                  // Sort by seat index (0 = me, then 1..4 other players)
                  seats.sort((a, b) => a.seatIndex.compareTo(b.seatIndex));

                  // Limit display to up to 5 seats: me + 4
                  final visibleSeats = seats.where((s) => s.seatIndex <= 4).toList();

                  final handsRaw = Map<String, dynamic>.from(
                      gameState['hands'] ?? <String, dynamic>{});

                  // Build hand codes & PlayingCards
                  final Map<String, List<String>> handCodes = {};
                  final Map<String, List<PlayingCard>> handCards = {};
                  for (final seat in visibleSeats) {
                    final uid = seat.uid;
                    final codes = List<String>.from(
                        handsRaw[uid] ?? <String>[]);
                    handCodes[uid] = codes;

                    handCards[uid] = codes.map((code) {
                      final parts = code.split('_');
                      final suit = parts[0];
                      final rank = int.tryParse(parts[1]) ?? 1;
                      return PlayingCard(suit: suit, rank: rank);
                    }).toList();
                  }

                  final deckCodes =
                  List<String>.from(gameState['deck'] ?? <String>[]);
                  final deckAdapter = OnlineDeckAdapter(deckCodes);

                  final topCardCode = gameState['topCard'] as String?;
                  PlayingCard? topCard;
                  if (topCardCode != null) {
                    final parts = topCardCode.split('_');
                    if (parts.length == 2) {
                      final suit = parts[0];
                      final rank = int.tryParse(parts[1]) ?? 1;
                      topCard = PlayingCard(suit: suit, rank: rank);
                    }
                  }

                  // Compute discard length: 40 total cards
                  const int totalCards = 40;
                  int inHandsCount = 0;
                  handCodes.values.forEach((list) {
                    inHandsCount += list.length;
                  });
                  final discardCount =
                  max(0, totalCards - deckCodes.length - inHandsCount);
                  final List<PlayingCard> discardDummy = List.generate(
                    discardCount,
                        (_) => PlayingCard(suit: 'Coins', rank: 1),
                  );

                  final String currentTurnUid =
                      gameState['currentTurnUid'] as String? ?? myUid;
                  final int pendingDraw =
                  (gameState['pendingDraw'] ?? 0) as int;
                  final winnerUid =
                  gameState['winnerUid'] as String?;

                  // Trigger VFX when top card / pending draw changes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleVisualEffects(topCardCode, pendingDraw);
                  });

                  // If game finished & winner set → show dialog once
                  if (status == 'finished' && winnerUid != null) {
                    Future.microtask(() {
                      if (!mounted) return;
                      final winnerSeat = seats.firstWhere(
                            (s) => s.uid == winnerUid,
                        orElse: () => seats.first,
                      );
                      final winnerName = winnerSeat.isMe
                          ? (xpManager.username ?? 'You')
                          : winnerSeat.nickname;

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => AlertDialog(
                          title: Text(tr(context).quitGame),
                          content: Text(
                            "${tr(context).wins}: $winnerName",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MainScreen(),
                                  ),
                                );
                              },
                              child: Text("tr(context).ok"),
                            ),
                          ],
                        ),
                      );
                    });
                  }

                  // Map currentTurnUid to seat index for PlayerActionPanel/PlayerCard logic
                  final currentSeatIndex = seats
                      .firstWhere(
                        (s) => s.uid == currentTurnUid,
                    orElse: () => seats.first,
                  )
                      .seatIndex;

                  // Local player data
                  final mySeat =
                  seats.firstWhere((s) => s.isMe, orElse: () => seats.first);
                  final myHandCards = handCards[mySeat.uid] ?? <PlayingCard>[];
                  final myHandCodes = handCodes[mySeat.uid] ?? <String>[];

                  // Layout like your offline board
                  final w = MediaQuery.of(context).size.width;
                  final h = MediaQuery.of(context).size.height;

                  // Keys for animations (DeckCenterPanel & PlayerActionPanel expect them)
                  final GlobalKey deckKey = GlobalKey();
                  final GlobalKey centerKey = GlobalKey();
                  final GlobalKey handKey = GlobalKey();
                  final ScrollController handScroll = ScrollController();
                  final List<GlobalKey> playerCardKeys = [];

                  return Stack(
                    children: [
                      // Top bar (menu + status)
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Room: ${data['roomCode'] ?? '??????'}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        currentTurnUid == myUid
                                            ? "tr(context).yourTurn"
                                            : "tr(context).waitingForOthers",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                flex: 4,
                                child: SimpleUserStatusBar(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Opponents (top row: seats 2 & 3)
                      if (visibleSeats.length > 2)
                        Positioned(
                          top: 110,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (visibleSeats.any((s) => s.seatIndex == 2))
                                _buildOpponentCard(
                                  seat: visibleSeats
                                      .firstWhere((s) => s.seatIndex == 2),
                                  handCards: handCards,
                                  currentSeatIndex: currentSeatIndex,
                                ),
                              if (visibleSeats.any((s) => s.seatIndex == 3))
                                _buildOpponentCard(
                                  seat: visibleSeats
                                      .firstWhere((s) => s.seatIndex == 3),
                                  handCards: handCards,
                                  currentSeatIndex: currentSeatIndex,
                                ),
                            ],
                          ),
                        ),

                      // Left: seat 1
                      if (visibleSeats.any((s) => s.seatIndex == 1))
                        Positioned(
                          left: 2,
                          top: h * 0.42,
                          child: _buildOpponentCard(
                            seat: visibleSeats
                                .firstWhere((s) => s.seatIndex == 1),
                            handCards: handCards,
                            currentSeatIndex: currentSeatIndex,
                          ),
                        ),

                      // Right: seat 4
                      if (visibleSeats.any((s) => s.seatIndex == 4))
                        Positioned(
                          right: 2,
                          top: h * 0.42,
                          child: _buildOpponentCard(
                            seat: visibleSeats
                                .firstWhere((s) => s.seatIndex == 4),
                            handCards: handCards,
                            currentSeatIndex: currentSeatIndex,
                          ),
                        ),

                      // Center deck & top card
                      DeckCenterPanel(
                        top: h * 0.42,
                        left: w * 0.18,
                        right: w * 0.18,
                        onDraw: () async {
                          // Only allow local player to draw on their turn
                          if (currentTurnUid != myUid) {
                            _showSnack("tr(context).notYourTurn");
                            return;
                          }
                          try {
                            await gameService.drawCard(widget.roomId);
                          } catch (e) {
                            _showSnack('Error: $e');
                          }
                        },
                        deck: deckAdapter,
                        topCard: topCard,
                        discard: discardDummy,
                        deckKey: deckKey,
                        centerKey: centerKey,
                      ),

                      // Online player panel (bottom)
                      PWF_PlayerActionPanel(
                        eliminated: false,
                        isSpectating: false,
                        isAnimating: false,
                        handDealt: true,
                        isMyTurn: currentTurnUid == myUid,
                        hand: myHandCards,
                        selectedAvatar: xpManager.selectedAvatar,
                        username: xpManager.username ?? mySeat.nickname,
                        onDraw: () async {
                          if (currentTurnUid != myUid) {
                            _showSnack("tr(context).notYourTurn");
                            return;
                          }
                          try {
                            await gameService.drawCard(widget.roomId);
                          } catch (e) {
                            _showSnack('Error: $e');
                          }
                        },
                        handKey: handKey,
                        handScrollController: handScroll,
                        playerCardKeys: playerCardKeys,
                        onPlayCard: (index) async {
                          if (currentTurnUid != myUid) {
                            _showSnack("tr(context).notYourTurn");
                            return;
                          }
                          if (index < 0 || index >= myHandCodes.length) {
                            return;
                          }
                          final cardCode = myHandCodes[index];
                          try {
                            await gameService.playCard(
                              roomId: widget.roomId,
                              cardCode: cardCode,
                            );
                          } catch (e) {
                            _showSnack('Error: $e');
                          }
                        },
                        gameModeType: GameModeType.playToWin,
                        onLeaveGame: () async {
                          try {
                            await gameService.leaveRoom(widget.roomId);
                          } catch (_) {}
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MainScreen(),
                              ),
                            );
                          }
                        },
                        onEmojiSelected: (filePath) {
                          // Local-only emotes for now (no sync)
                        },
                      ),

                      // Center VFX
                      if (_centerBanner != null) Center(child: _centerBanner!),
                      if (_centerLottie != null) Center(child: _centerLottie!),
                      if (_centerImage != null) Center(child: _centerImage!),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpponentCard({
    required _OnlineSeat seat,
    required Map<String, List<PlayingCard>> handCards,
    required int currentSeatIndex,
  }) {
    final cards = handCards[seat.uid] ?? <PlayingCard>[];
    return PlayerCard(
      bot: seat.seatIndex, // reuse as “seat index”
      vertical: seat.seatIndex == 1 || seat.seatIndex == 4,
      isEliminated: false,
      isQualified: false,
      isTurn: currentSeatIndex == seat.seatIndex,
      handDealt: true,
      cardCount: cards.length,
      hand: cards,
      playerKey: GlobalKey(),
      mode: GameMode.online,
    );
  }
}

class _OnlineSeat {
  final String uid;
  final String nickname;
  final bool isMe;
  final int seatIndex;

  _OnlineSeat({
    required this.uid,
    required this.nickname,
    required this.isMe,
    required this.seatIndex,
  });
}
