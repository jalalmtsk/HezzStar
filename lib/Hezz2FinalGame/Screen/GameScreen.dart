import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../IndexPages/Settings/SettingDialog.dart';
import '../Models/Cards.dart';
import '../Models/Deck.dart';
import '../Tools/BotStack.dart';
import '../Tools/Dialog/GameInfoDialog.dart';
import '../Tools/Dialog/SuitSelectionDialog.dart';
import '../Tools/MessagesInGame/AnimatedMessages.dart';
import '../Tools/MessagesInGame/EmojiesBubble.dart';
import '../Tools/TextUI/CardReamingTextUi.dart';
import '../Tools/TextUI/MinimalBageText.dart';
import 'endGameScreen.dart';


class GameScreen extends StatefulWidget {
  final int startHandSize;
  final int botCount;
  final GameMode mode;
  final GameModeType gameModeType;
  final int selectedBet; // added

  const GameScreen({
    required this.startHandSize,
    required this.botCount,
    required this.mode,
    required this.gameModeType,
    required this.selectedBet,

    super.key
  });
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Deck deck;
  final ScrollController handScrollController = ScrollController();
  final botKeys = List.generate(5, (_) => GlobalKey());
  late List<List<PlayingCard>> hands;

  PlayingCard? topCard;
  List<PlayingCard> discard = [];

  int currentPlayer = 0;
  bool isAnimating = false;
  OverlayEntry? moving;
  bool handDealt = false;

  int pendingDraw = 0;
  bool skipNext = false;
  bool gameOver = false;
  String winner = '';

  final GlobalKey deckKey = GlobalKey();
  final GlobalKey centerKey = GlobalKey();
  final GlobalKey handKey = GlobalKey();
  List<GlobalKey> playerCardKeys = [];

  final Duration playDur = const Duration(milliseconds: 800);
  final Duration drawDur = const Duration(milliseconds: 200);

  // Elimination mode variables
  List<bool> eliminatedPlayers = [];
  List<int> qualifiedPlayers = [];
  int currentRound = 1;
  bool isBetweenRounds = false;


  @override
  void initState() {
    super.initState();
    hands = List.generate(widget.botCount + 1, (_) => []);
    eliminatedPlayers = List.generate(widget.botCount + 1, (_) => false);

    if (widget.mode == GameMode.online) {

    } else {
      _start();
    }
  }


  void _handleOnlineMessage(Map<String, dynamic> data) {
    // Handle online messages here
  }

  Future<void> _start() async {
    isAnimating = true;

    // Reset game state
    deck = Deck();
    deck.shuffle();
    for (var h in hands)
      h.clear();
    discard.clear();
    currentPlayer = 0;
    pendingDraw = 0;
    skipNext = false;
    gameOver = false;
    winner = '';
    qualifiedPlayers.clear();

    // For elimination mode, reset eliminations but keep track of rounds
    if (widget.gameModeType == GameModeType.elimination) {
      eliminatedPlayers = List.generate(widget.botCount + 1, (_) => false);
      isBetweenRounds = false;
    }

    await _precacheAssets(context);

    final toDeal = widget.startHandSize;

    for (int round = 0; round < toDeal; round++) {
      for (int p = 0; p <= widget.botCount; p++) {
        if (eliminatedPlayers[p]) continue;

        if (deck.isEmpty) _recycle();
        if (deck.isEmpty) break;

        final c = deck.draw();
        hands[p].add(c);

        final start = _rectFor(deckKey)?.center;
        Offset? end;
        if (p == 0) {
          final idx = hands[0].length - 1;
          if (idx < playerCardKeys.length) {
            end = _rectFor(playerCardKeys[idx])?.center;
          }
          end ??= Offset(MediaQuery
              .of(context)
              .size
              .width / 2, MediaQuery
              .of(context)
              .size
              .height - 90);
          if (start != null && end != null) await _animateMoveFaceDown(
              c, start, end);
        } else {
          final botPos = _cardStartForPlayer(p, hands[p].length - 1);
          if (start != null && botPos != null) await _animateMoveFaceDown(
              c, start, botPos);
        }

        setState(() {});
        await Future.delayed(const Duration(milliseconds: 90));
      }
    }

    if (deck.isEmpty) _recycle();
    topCard = deck.draw();
    discard.add(topCard!);
    setState(() {});

    await Future.delayed(const Duration(milliseconds: 400));
    isAnimating = false;
    handDealt = true;  // ✅ Turn timer can start now
    setState(() {});
    _maybeAutoPlay();
  }

  Future<void> _precacheAssets(BuildContext ctx) async {
    try {
      await precacheImage(
          const AssetImage('assets/images/cards/backCard.png'), ctx);
      final sample = PlayingCard(suit: 'Coins', rank: 1);
      await precacheImage(AssetImage(sample.assetName), ctx);
    } catch (_) {}
  }

  void _recycle() {
    if (discard.length <= 1) return;
    final top = discard.removeLast();
    deck.cards.addAll(discard);
    discard.clear();
    discard.add(top);
    deck.shuffle();
  }

  Rect? _rectFor(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox;
    final p = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(p.dx, p.dy, box.size.width, box.size.height);
  }

  Offset? _cardStartForPlayer(int p, int idx) {
    if (p == 0) {
      if (idx >= playerCardKeys.length) return null;
      final rect = _rectFor(playerCardKeys[idx]);
      if (rect == null) return null;
      return rect.center;
    } else {
      final rect = _rectFor(botKeys[p]);
      if (rect == null) return null;
      final center = rect.center;
      return center;
    }
  }

  Future<void> _animateMove(PlayingCard card, Offset from, Offset to,
      {required bool cinematic}) async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final dur = cinematic ? playDur : drawDur;
    final ctrl = AnimationController(vsync: this, duration: dur);
    final curve = CurvedAnimation(parent: ctrl, curve: Curves.easeInOutCubic);
    moving = OverlayEntry(builder: (_) {
      return AnimatedBuilder(animation: curve, builder: (_, __) {
        final pos = Offset.lerp(from, to, curve.value)!;
        final scale = cinematic ? (1.0 + 0.06 * sin(curve.value * pi)) : 1.0;
        final op = cinematic ? (0.5 + curve.value * 0.5) : 1.0;
        return Positioned(
            left: pos.dx - 43,
            top: pos.dy - 60,
            child: Opacity(
                opacity: op,
                child: Transform.scale(
                    scale: scale,
                    child: SizedBox(
                        width: 70,
                        height: 110,
                        child: Image.asset(card.assetName, fit: BoxFit.cover)
                    )
                )
            )
        );
      });
    });
    overlay.insert(moving!);
    await ctrl.forward();
    moving?.remove();
    moving = null;
    ctrl.dispose();
  }

  Future<void> _playCardByHuman(int idx) async {
    if (eliminatedPlayers[0]) return; // Skip if eliminated
    if (gameOver || isAnimating || isBetweenRounds || isSpectating) return;
    if (currentPlayer != 0) return;
    if (idx < 0 || idx >= hands[0].length) return;
    final card = hands[0][idx];
    if (!_isPlayable(card)) {
      _showSnack('Card not playable');
      return;
    }
    await _playCard(0, idx);
  }

  bool _isPlayable(PlayingCard card) {
    if (pendingDraw > 0) return card.rank == 2;
    if (topCard == null) return true;
    return card.suit == topCard!.suit || card.rank == topCard!.rank;
  }

  Future<void> _playCard(int player, int idx) async {
    if (isAnimating || eliminatedPlayers[player]) return;
    isAnimating = true;
    final card = hands[player][idx];
    final start = _cardStartForPlayer(player, idx);
    final centerRect = _rectFor(centerKey);
    final to = centerRect?.center ?? Offset(MediaQuery
        .of(context)
        .size
        .width / 2, MediaQuery
        .of(context)
        .size
        .height * 0.38);
    if (start != null) {
      final audioManager = Provider.of<AudioManager>(context, listen: false);
      audioManager.playSfx("assets/audios/UI/SFX/CardSwapVolumeUp.mp3");
      await _animateMove(card, start, to, cinematic: true);
    }
    setState(() {
      hands[player].removeAt(idx);
      topCard = card;
      discard.add(card);
    });

    await _handleSpecial(player, card);
    isAnimating = false;
    _checkWin(player);
    if (!gameOver && !isBetweenRounds) _advanceTurn();
  }

  Future<void> _handleSpecial(int player, PlayingCard card) async {
    if (card.rank == 2) {
      pendingDraw += 2;
      _showCenterBanner('+2', Colors.redAccent);
    } else if (card.rank == 1) {
      skipNext = true;
      _showCenterBanner('Skip', Colors.orangeAccent);
    } else if (card.rank == 7) {
      if (player == 0) {
        // get the current suit of the top card before change
        final previousSuit = topCard?.suit ?? "Coins";

        final choice = await _askSuit(previousSuit);

        if (choice != null) {
          final audioManager = Provider.of<AudioManager>(
            context,
            listen: false,
          );
          audioManager.playSfx("assets/audios/UI/SFX/CardSound.mp3");

          setState(() {
            topCard = PlayingCard(suit: choice, rank: 7);
            discard.removeLast();
            discard.add(topCard!);
          });

          _showCenterBanner('Suit: $choice', Colors.blueAccent);
        }
      } else {
        final suit = _botPickSuit(player);
        _showCenterBanner('Suit: $suit', Colors.blueAccent);
        await Future.delayed(const Duration(milliseconds: 600));

        setState(() {
          topCard = PlayingCard(suit: suit, rank: 7);
          discard.removeLast();
          discard.add(topCard!);
        });
      }
    }
  }


  Future<String?> _askSuit(String lastSuit) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => SuitSelectionDialog(previousSuit: lastSuit),
    );
  }



  String _botPickSuit(int bot) {
    final counts = {'Coins': 0, 'Cups': 0, 'Swords': 0, 'Clubs': 0};
    for (final c in hands[bot])
      counts[c.suit] = counts[c.suit]! + 1;
    var best = 'Coins';
    var b = -1;
    counts.forEach((k, v) {
      if (v > b) {
        b = v;
        best = k;
      }
    });
    return best;
  }

  void _showCenterBanner(String text, Color col) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final entry = OverlayEntry(builder: (_) {
      final c = _rectFor(centerKey)?.center ?? Offset(MediaQuery
          .of(context)
          .size
          .width / 2, MediaQuery
          .of(context)
          .size
          .height * 0.35);
      return Positioned(
          left: c.dx - 70,
          top: c.dy - 120,
          child: Material(
              color: Colors.transparent,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: col.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                      text,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)
                  )
              )
          )
      );
    });
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 800), () => entry.remove());
  }

  void _showSnack(String t) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(t),
            duration: const Duration(milliseconds: 700)
        )
    );
  }

  void _advanceTurn() {
    int next = (currentPlayer + 1) % (widget.botCount + 1);

    // Skip eliminated players, qualified players, and spectating players
    while (eliminatedPlayers[next] ||
        (widget.gameModeType == GameModeType.elimination &&
            qualifiedPlayers.contains(next)) ||
        (next == 0 && isSpectating)) {
      next = (next + 1) % (widget.botCount + 1);
    }

    if (skipNext) {
      skipNext = false;
      next = (next + 1) % (widget.botCount + 1);

      // Skip again after skipping
      while (eliminatedPlayers[next] ||
          (widget.gameModeType == GameModeType.elimination &&
              qualifiedPlayers.contains(next)) ||
          (next == 0 && isSpectating)) {
        next = (next + 1) % (widget.botCount + 1);
      }
    }

    currentPlayer = next;
    setState(() {});
    _maybeAutoPlay();
  }

  void _maybeAutoPlay() {
    if (gameOver || isBetweenRounds) return;

    // Skip if current player is eliminated
    if (eliminatedPlayers[currentPlayer]) {
      _advanceTurn();
      return;
    }

    if (currentPlayer == 0) return;
    if (widget.mode == GameMode.online) return;
    if (currentPlayer > widget.botCount) return;

    Future.delayed(
        Duration(milliseconds: 600 + Random().nextInt(700)), () async {
      if (gameOver || isBetweenRounds) return;

      // Double-check that the bot isn't eliminated before playing
      if (!eliminatedPlayers[currentPlayer]) {
        await _botTurn(currentPlayer);
      } else {
        _advanceTurn();
      }
    });
  }

  Future<void> _botTurn(int bot) async {
    // Skip if bot is eliminated or qualified in elimination mode
    if (eliminatedPlayers[bot] ||
        (widget.gameModeType == GameModeType.elimination &&
            qualifiedPlayers.contains(bot))) {
      _advanceTurn();
      return;
    }

    if (deck.isEmpty) _recycle();
    if (deck.isEmpty) return;

    if (pendingDraw > 0) {
      final chainable = hands[bot].indexWhere((c) => c.rank == 2);
      if (chainable != -1) {
        await Future.delayed(
            Duration(milliseconds: 400 + Random().nextInt(400)));
        await _playCard(bot, chainable);
        return;
      } else {
        for (int i = 0; i < pendingDraw; i++) {
          if (deck.isEmpty) _recycle();
          if (deck.isEmpty) break;
          final d = deck.draw();
          hands[bot].add(d);
          final start = _rectFor(deckKey)?.center;
          final botPos = _cardStartForPlayer(bot, hands[bot].length - 1);
          if (start != null && botPos != null) await _animateMoveFaceDown(
              d, start, botPos);
          await Future.delayed(const Duration(milliseconds: 90));
        }
        _showCenterBanner('Drew $pendingDraw cards', Colors.purpleAccent);
        pendingDraw = 0;
        await Future.delayed(const Duration(milliseconds: 300));
        _advanceTurn();
        return;
      }
    }

    final playable = <int>[];
    for (int i = 0; i < hands[bot].length; i++) {
      if (_isPlayable(hands[bot][i])) playable.add(i);
    }

    if (playable.isEmpty) {
      if (deck.isEmpty) _recycle();
      if (deck.isEmpty) {
        _advanceTurn();
        return;
      }
      final d = deck.draw();
      hands[bot].add(d);
      final start = _rectFor(deckKey)?.center;
      final botPos = _cardStartForPlayer(bot, hands[bot].length - 1);
      if (start != null && botPos != null) await _animateMoveFaceDown(
          d, start, botPos);

      _showCenterBanner('Drew & skipped', Colors.purpleAccent);
      await Future.delayed(const Duration(milliseconds: 300));
      _advanceTurn();
      return;
    }

    int choice = playable.first;
    for (final i in playable) {
      final r = hands[bot][i].rank;
      if (r == 2 || r == 1 || r == 7) {
        choice = i;
        break;
      }
    }

    await Future.delayed(Duration(milliseconds: 350 + Random().nextInt(450)));
    await _playCard(bot, choice);
  }

  Future<void> _animateMoveFaceDown(PlayingCard card, Offset from,
      Offset to) async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final ctrl = AnimationController(vsync: this, duration: drawDur);
    final curve = CurvedAnimation(parent: ctrl, curve: Curves.easeInOutCubic);
    final movingEntry = OverlayEntry(builder: (_) {
      return AnimatedBuilder(
        animation: curve,
        builder: (_, __) {
          final pos = Offset.lerp(from, to, curve.value)!;
          return Positioned(
            left: pos.dx - 43,
            top: pos.dy - 60,
            child: SizedBox(
              width: 70,
              height: 110,
              child: Image.asset(card.backAsset(context), fit: BoxFit.cover),
            ),
          );
        },
      );
    });
    overlay.insert(movingEntry);
    await ctrl.forward();
    movingEntry.remove();
    ctrl.dispose();
  }

  Future<void> _playerDraw() async {
    if (eliminatedPlayers[0]) {
      return;
    }
    if (isAnimating || gameOver || isBetweenRounds) return;
    if (currentPlayer != 0) return;

    // Skip if player is eliminated
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playSfx("assets/audios/UI/SFX/CardSwapVolumeUp.mp3");
    if (isSpectating) {
      return;
    }
    // Skip if player is qualified in elimination mode
    if (widget.gameModeType == GameModeType.elimination &&
        qualifiedPlayers.contains(0)) {
      return;
    }

    if (deck.isEmpty) _recycle();
    if (deck.isEmpty) {
      _showSnack('Deck empty');
      return;
    }

    isAnimating = true;

    int drawCount = pendingDraw > 0 ? pendingDraw : 1;
    for (int i = 0; i < drawCount; i++) {
      if (deck.isEmpty) _recycle();
      if (deck.isEmpty) break;

      final d = deck.draw();

      final start = _rectFor(deckKey)?.center;

      final idx = hands[0].length;
      Offset handPos;
      if (idx < playerCardKeys.length) {
        handPos = _rectFor(playerCardKeys[idx])?.center ??
            Offset(MediaQuery
                .of(context)
                .size
                .width / 2, MediaQuery
                .of(context)
                .size
                .height - 90);
      } else {
        final w = MediaQuery
            .of(context)
            .size
            .width;
        handPos = Offset(w * 0.5 + idx * 86 / 2, MediaQuery
            .of(context)
            .size
            .height - 90);
      }

      if (start != null) {
        await _animateMoveFaceDownToFaceUp(d, start, handPos);
      }

      setState(() {
        hands[0].add(d);
      });

      await Future.delayed(const Duration(milliseconds: 50));
    }

    pendingDraw = 0;
    isAnimating = false;

    handScrollController.animateTo(
      handScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );

    if (isAnimating || gameOver || isBetweenRounds) return;

    _showSnack('Drew $drawCount card${drawCount > 1 ? 's' : ''} & skipped');
    _advanceTurn();
  }

  Future<void> _animateMoveFaceDownToFaceUp(PlayingCard card, Offset from,
      Offset to) async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    final curve = CurvedAnimation(parent: ctrl, curve: Curves.easeInOutCubic);

    OverlayEntry? entry;
    entry = OverlayEntry(builder: (_) {
      return AnimatedBuilder(
        animation: curve,
        builder: (_, __) {
          final pos = Offset.lerp(from, to, curve.value)!;
          final flip = curve.value < 0.5 ? pi * curve.value : pi *
              (1 - curve.value);
          final showFront = curve.value > 0.5;

          return Positioned(
            left: pos.dx - 43,
            top: pos.dy - 60,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(flip),
              child: SizedBox(
                width: 70,
                height: 110,
                child: Image.asset(
                  showFront ? card.assetName : card.backAsset(context),
                  fit: BoxFit.cover,
                ),

              ),
            ),
          );
        },
      );
    });
    overlay.insert(entry);
    await ctrl.forward();
    entry.remove();
    ctrl.dispose();
  }

  void _checkWin(int p) {
    if (hands[p].isEmpty) {
      if (widget.gameModeType == GameModeType.playToWin) {
        // Play To Win mode - first to finish wins
        gameOver = true;
        winner = p == 0 ? 'You' : 'Bot $p';
        _showEnd();
      } else {
        // Elimination mode - player qualifies
        setState(() {
          if (!qualifiedPlayers.contains(p)) {
            qualifiedPlayers.add(p);
          }

          // Check if we should eliminate someone
          int activePlayers = 0;
          int lastActivePlayer = -1;

          for (int i = 0; i <= widget.botCount; i++) {
            if (!eliminatedPlayers[i] && !qualifiedPlayers.contains(i) &&
                hands[i].isNotEmpty) {
              activePlayers++;
              lastActivePlayer = i;
            }
          }

          // If only one player remains who hasn't qualified, eliminate them
          if (activePlayers == 1) {
            eliminatedPlayers[lastActivePlayer] = true;
            _showCenterBanner('Player ${lastActivePlayer == 0
                ? "You"
                : "Bot $lastActivePlayer"} eliminated!', Colors.red);

            // Check if the eliminated player is the current player
            // If so, advance the turn immediately
            if (currentPlayer == lastActivePlayer) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _advanceTurn();
              });
            }

            // Check if game is over (only one player remains)
            int remainingPlayers = 0;
            int winnerIndex = -1;

            for (int i = 0; i <= widget.botCount; i++) {
              if (!eliminatedPlayers[i]) {
                remainingPlayers++;
                winnerIndex = i;
              }
            }

            if (remainingPlayers == 1) {
              gameOver = true;
              winner = winnerIndex == 0 ? 'You' : 'Bot $winnerIndex';
              _showEnd();
            } else {
              // Start next round
              _startNextRound();
            }
          }
        });
      }
    }
  }


  bool isSpectating = false;

  void _toggleSpectate() {
    // Don't allow eliminated players to toggle spectate
    if (eliminatedPlayers[0]) return;

    setState(() {
      isSpectating = !isSpectating;
      if (isSpectating) {
        _showSnack('You are now spectating');
        // If it's the player's turn and they choose to spectate, advance the turn
        if (currentPlayer == 0) {
          _advanceTurn();
        }
      } else {
        _showSnack('You are back in the game');
      }
    });
  }


  void _startNextRound() {
    setState(() {
      isBetweenRounds = true;
      isSpectating = false; // Reset spectating state
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        currentRound++;
        isBetweenRounds = false;

        // Reset hands but keep track of eliminated players
        deck = Deck();
        deck.shuffle();
        for (int i = 0; i < hands.length; i++) {
          hands[i].clear();
          if (!eliminatedPlayers[i]) {
            for (int j = 0; j < widget.startHandSize; j++) {
              if (deck.isEmpty) _recycle();
              hands[i].add(deck.draw());
            }
          }
        }

        // Reset top card
        if (deck.isEmpty) _recycle();
        topCard = deck.draw();
        discard.clear();
        discard.add(topCard!);

        // Reset round state
        pendingDraw = 0;
        skipNext = false;
        qualifiedPlayers.clear();

        // Set current player to first non-eliminated
        currentPlayer = 0;
        while (eliminatedPlayers[currentPlayer]) {
          currentPlayer = (currentPlayer + 1) % (widget.botCount + 1);
        }
      });

      // 🔑 Kick the bots after UI updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeAutoPlay();
      });
    });
  }


  void _showEnd() {
    int winnerIndex = -1;
    for (int i = 0; i < hands.length; i++) {
      if (hands[i].isEmpty && !eliminatedPlayers[i]) {
        winnerIndex = i;
        break;
      }
    }

    if (winnerIndex == -1) {
      // Find the last non-eliminated player (for elimination mode)
      for (int i = 0; i < eliminatedPlayers.length; i++) {
        if (!eliminatedPlayers[i]) {
          winnerIndex = i;
          break;
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EndGameScreen(
              hands: hands,
              winnerIndex: winnerIndex,
              gameModeType: widget.gameModeType,
              currentRound: currentRound,
              betAmount: widget.selectedBet, // pass the actual bet amount
            ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showGameSummaryDialog(BuildContext context,
      List<Map<String, dynamic>> players, int totalPool) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Game Summary",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Total Pool: $totalPool DH",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 15),
                ...players.map((player) {
                  return ListTile(
                    title: Text(player["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Bet: ${player["bet"]} DH"),
                    trailing: Text(
                      player["isWinner"]
                          ? "+${totalPool} DH"
                          : "0 DH",
                      style: TextStyle(
                        color: player["isWinner"] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                ),
                child: const Text("Close",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        );
      },
    );
  }
  String? _shownEmoji;
  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context,listen: false);

    final w = MediaQuery
        .of(context)
        .size
        .width;
    final h = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildTableBackground(),

            if (isBetweenRounds)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Round $currentRound Complete!',
                          style: const TextStyle(fontSize: 32, color: Colors
                              .white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Qualified: ${qualifiedPlayers.map((p) =>
                          p == 0
                              ? "You"
                              : "Bot $p").join(", ")}',
                          style: const TextStyle(fontSize: 24, color: Colors
                              .white),
                        ),
                        const SizedBox(height: 30),
                        const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white)),
                        const SizedBox(height: 20),
                        const Text(
                          'Preparing next round...',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (!isBetweenRounds) ...[
              Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (widget.botCount >= 2)
                      GestureDetector(
                        onTap: () => _showPlayerDetails(context, 2),
                        child: PlayerCard(
                          bot: 2,
                          vertical: false,
                          isEliminated: eliminatedPlayers[2],
                          isQualified: qualifiedPlayers.contains(2),
                          isTurn: currentPlayer == 2,
                          cardCount: hands[2].length,
                          hand: hands[2],
                          playerKey: botKeys[2],
                        ),
                      ),

                    if (widget.botCount >= 3)
                      PlayerCard(
                        bot: 3,
                        vertical: false,
                        isEliminated: eliminatedPlayers[3],
                        isQualified: qualifiedPlayers.contains(3),
                        isTurn: currentPlayer == 3,
                        cardCount: hands[3].length,
                        hand: hands[3],
                        playerKey: botKeys[3],
                      ),],
                ),
              ),

              if (widget.botCount >= 1)
                Positioned(
                  left: 12,
                  top: h * 0.35,
                  child: PlayerCard(
                    bot: 1,
                    vertical: true,
                    isEliminated: eliminatedPlayers[1],
                    isQualified: qualifiedPlayers.contains(1),
                    isTurn: currentPlayer == 1,
                    cardCount: hands[1].length,
                    hand: hands[1],
                    playerKey: botKeys[1],
                  ),
                ),
              if (widget.botCount >= 4)
                Positioned(
                  right: 12,
                  top: h * 0.35,
                  child: PlayerCard(
                    bot: 4,
                    vertical: true,
                    isEliminated: eliminatedPlayers[4],
                    isQualified: qualifiedPlayers.contains(4),
                    isTurn: currentPlayer == 4,
                    cardCount: hands[4].length,
                    hand: hands[4],
                    playerKey: botKeys[4],
                  ),
                ),

              Positioned(
                  top: h * 0.30,
                  left: w * 0.18,
                  right: w * 0.18,
                  child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: _playerDraw,
                                  child: Column(
                                    children: [
                                      MinimalBadgeText(label: "Draw Pile", fontSize: 14,),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                          key: deckKey,
                                          width: 70,
                                          height: 110,
                                          child: deck.isEmpty
                                              ? Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius
                                                      .circular(8),
                                                  color: Colors.white70
                                              ),
                                              child: const Center(
                                                  child: Text('Empty'))
                                          )
                                              : Image.asset(
                                              deck.cards.last.backAsset(
                                                  context), fit: BoxFit.cover)
                                      ),
                                      const SizedBox(height: 4,),
                                      CardCountBadge(remaining: deck.length,)
                                    ],
                                  )
                              ),
                              const SizedBox(width: 20),
                              Column(
                                  children: [
                                    MinimalBadgeText(label: "Top Card"),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                        key: centerKey,
                                        width: 70,
                                        height: 110,
                                        child: topCard == null
                                            ? Container()
                                            : Image.asset(topCard!.assetName,
                                            fit: BoxFit.cover)
                                    ),
                                    const SizedBox(height: 4,),
                                    CardCountBadge(remaining: discard.length,)

                                  ]
                              )
                            ]
                        )
                      ]
                  )
              ),

              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Top Row: Player info + avatar + timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Player status text
                        Expanded(
                          child: Text(
                            eliminatedPlayers[0]
                                ? 'Eliminated'
                                : isSpectating
                                ? 'Spectating'
                                : 'Your Hand${currentPlayer == 0 && !isSpectating ? ' (Your turn)' : ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: eliminatedPlayers[0]
                                  ? Colors.red
                                  : (isSpectating ? Colors.grey : Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Avatar + emoji/lottie overlay
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Circular turn timer
                            if (currentPlayer == 0 &&
                                !eliminatedPlayers[0] &&
                                !isSpectating &&
                                handDealt)
                              SizedBox(
                                width: 55,
                                height: 55,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 1, end: 0),
                                  duration: const Duration(seconds: 15),
                                  builder: (context, value, child) {
                                    if (value == 0) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                                        await _playerDraw();
                                      });
                                    }
                                    return CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 3,
                                      backgroundColor: Colors.grey.withOpacity(0.3),
                                      color: Colors.greenAccent,
                                    );
                                  },
                                ),
                              ),

                            // Player avatar
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.deepPurple,
                              backgroundImage: xpManager.selectedAvatar != null
                                  ? AssetImage(xpManager.selectedAvatar!)
                                  : const AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png"),
                            ),

                            // ✅ Show emoji OR lottie animation
                            if (_shownEmoji != null && !_shownEmoji!.endsWith(".json"))
                              Positioned(
                                top: 10,
                                child: Text(
                                  _shownEmoji!,
                                  style: const TextStyle(fontSize: 25, color: Colors.white),
                                ),
                              ),
                            if (_shownEmoji != null && _shownEmoji!.endsWith(".json"))
                              Positioned(
                                top: -20,
                                child: SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Lottie.asset(
                                    _shownEmoji!, // plays the lottie instead of showing text
                                    repeat: false,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),

                        // Emoji bubble button
                        AnimatedEmojiBubble(
                          onSelected: (emoji) {
                            setState(() {
                              _shownEmoji = emoji;
                            });
                            Future.delayed(const Duration(milliseconds: 1600), () {
                              setState(() {
                                _shownEmoji = null;
                              });
                            });
                          },
                        ),

                        // Lottie animation bubble button
                        AnimatedLottieEmojiBubble(
                          onSelected: (filePath) {
                            setState(() {
                              _shownEmoji = filePath; // ✅ Play animation directly
                            });
                            Future.delayed(const Duration(milliseconds: 2000), () {
                              setState(() {
                                _shownEmoji = null;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    // Action buttons
                    Row(
                      children: [
                        if (!eliminatedPlayers[0] && !isSpectating)
                          ElevatedButton(
                            onPressed: (!isAnimating && currentPlayer == 0)
                                ? () => _playerDraw()
                                : null,
                            child: const Text('Draw'),
                          ),
                        CardCountBadge(remaining:hands[0].length, fontSize: 14,),
                        const SizedBox(width: 6),
                        if (widget.gameModeType == GameModeType.elimination)
                          if (eliminatedPlayers[0])
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Leave Game'),
                            )
                          else if (!qualifiedPlayers.contains(0))
                            ElevatedButton(
                              onPressed: _toggleSpectate,
                              child: Text(isSpectating ? 'Join Game' : 'Spectate'),
                            ),
                      ],
                    ),
                    // Cards or eliminated/spectating messages
                    if (eliminatedPlayers[0])
                      Container(
                        height: 135,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.block, color: Colors.red, size: 40),
                            Text(
                              'You have been eliminated.',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                            Text(
                              'Press "Leave Game" to exit.',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else if (!isSpectating)
                      SizedBox(
                        key: handKey,
                        height: 135,
                        child: SingleChildScrollView(
                          controller: handScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: List.generate(hands[0].length, (i) {
                              if (i >= playerCardKeys.length) playerCardKeys.add(GlobalKey());
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: GestureDetector(
                                  onTap: () => _playCardByHuman(i),
                                  child: AnimatedContainer(
                                    key: playerCardKeys[i],
                                    duration: const Duration(milliseconds: 250),
                                    width: currentPlayer == 0 ? 70 : 69,
                                    height: currentPlayer == 0 ? 114 : 113,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.8),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(2),
                                      border: currentPlayer == 0
                                          ? Border.all(color: Colors.black.withOpacity(0.8), width: 0.6)
                                          : Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.asset(
                                        hands[0][i].assetName,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 135,
                        alignment: Alignment.center,
                        child: const Text(
                          'You are spectating. Press "Join Game" to play again.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),


              // TOP APPBAR
              Positioned(
                top: 8,
                left: 8,
                child: Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        final renderBox = context.findRenderObject() as RenderBox;
                        final offset = renderBox.localToGlobal(Offset.zero);
                        final size = renderBox.size;

                        final overlay = Overlay.of(context);
                        OverlayEntry? entry;

                        entry = OverlayEntry(
                          builder: (context) => Positioned(
                            left: offset.dx,
                            top: offset.dy + size.height + 4,
                            child: GameInfoDialog(
                              mode: widget.gameModeType.name,
                              players: widget.botCount + 1,
                              prize: widget.selectedBet * (widget.botCount + 1),
                              onSettings: () {
                                entry?.remove(); // keep your logic if you’re using OverlayEntry
                                // ✅ Open the settings dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => const SettingsDialog(),
                                );
                              },

                              onExit: () {
                                entry?.remove();
                                //_exitGame();
                              },
                              onInstructions: () {
                                entry?.remove();
                                //_showInstructions();
                              },
                            ),
                          ),
                        );

                        overlay.insert(entry);

                        // Auto remove after 5 seconds
                        Future.delayed(const Duration(seconds: 5), () {
                          entry?.remove();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.list,color: Colors.white,),
                      ),
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }




  Widget _buildTableBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/Skins/TableSkins/table1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay (darkens edges, focus on center)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.black.withOpacity(0.2), // center focus
                  Colors.black.withOpacity(0.7), // edges darker
                ],
                stops: [0.6, 1],
              ),
            ),
          ),

          // Extra Top/Bottom Overlay for cinematic effect
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
                stops: [0.0, 0.25, 0.75, 1.0],
              ),
            ),
          ),

          // Subtle Blur Overlay (gives depth)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 1.5),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }



  void _showPlayerDetails(BuildContext context, int bot) {
    final isEliminated = eliminatedPlayers[bot];
    final isQualified = qualifiedPlayers.contains(bot);
    final isTurn = currentPlayer == bot;
    final cardCount = hands[bot].length;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.black.withOpacity(0.85),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with avatar and name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.blueGrey.shade700,
                      child: Text(
                        "P$bot",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEliminated
                          ? "Eliminated"
                          : isQualified
                          ? "Qualified"
                          : isTurn
                          ? "Current Turn"
                          : "In Game",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isEliminated
                            ? Colors.redAccent
                            : isQualified
                            ? Colors.blueAccent
                            : isTurn
                            ? Colors.greenAccent
                            : Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Card count
                Text(
                  "Cards: $cardCount",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),

                const SizedBox(height: 12),

                // Show hand preview (up to 6)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < cardCount && i < 6; i++)
                      Image.asset(
                        hands[bot][i].backAsset(context),
                        width: 55,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                  ],
                ),

                const SizedBox(height: 20),

                // Close button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}