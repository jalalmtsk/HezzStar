import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:hezzstar/Hezz2FinalGame/Tools/Banner/CenterdLottieAnimation.dart';
import 'package:hezzstar/Hezz2FinalGame/Tools/Banner/CenteredImageEffect.dart';

import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:provider/provider.dart';

import '../../widgets/userStatut/userStatus.dart';
import '../Models/Cards.dart';
import '../Models/Deck.dart';
import '../Bot/BotStack.dart';
import '../Tools/Banner/CenterBanner.dart';
import '../Tools/Dialog/BotPlayerInfoDialog.dart';
import '../Tools/Dialog/MenuOverlayButton.dart';
import '../Tools/Dialog/PlayerSelectorAnimation.dart';
import '../Tools/Dialog/SuitSelectionDialog.dart';


import 'GameScreen/GameScreen__Tools/DeckCenteredPanel.dart';
import 'GameScreen/GameScreen__Tools/PlayerActionPanel.dart';
import 'GameScreen/GameScreen__Tools/RoundCompleteOverlay_Elimination.dart';
import 'GameScreen/GameScreen__Tools/TableBackground.dart';
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
  final GlobalKey goldKey = GlobalKey();
  final GlobalKey gemsKey = GlobalKey();
  final GlobalKey xpKey = GlobalKey();

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
  bool playerSelected = false;

  int pendingDraw = 0;
  bool skipNext = false;
  bool gameOver = false;
  bool _isPageActive = true;
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

  Future<void> _start() async {
    isAnimating = true;

    // Reset game state
    deck = Deck();
    deck.shuffle();
    BotDetailsPopup.resetBotInfos();
    for (var h in hands) h.clear();
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

    // pick a random starting player (must be within 0..botCount)
    currentPlayer = Random().nextInt(widget.botCount + 1);

    final selector = PlayerSelector(
      context: context,
      botCount: widget.botCount,
      eliminatedPlayers: eliminatedPlayers,
      onPlayerSelected: (selectedPlayer) {
        setState(() {
          currentPlayer = selectedPlayer; // update your current player
        });
      },
    );

    await selector.animateSelection();
    await _precacheAssets(context);

    final toDeal = widget.startHandSize;

    // Deal starting from currentPlayer and rotate around (so starter isn't always player 0)
    for (int round = 0; round < toDeal; round++) {
      for (int i = 0; i <= widget.botCount; i++) {
        final p = (currentPlayer + i) % (widget.botCount + 1);

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
          end ??= Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height - 90,
          );

          if (start != null && end != null) {
            await _animateMoveFaceDown(c, start, end);
          }
        } else {
          final botPos = _cardStartForPlayer(p, hands[p].length - 1);
          if (start != null && botPos != null) {
            await _animateMoveFaceDown(c, start, botPos);
          }
        }

        setState(() {});
        await Future.delayed(const Duration(milliseconds: 90));
      }
    }

    if (deck.isEmpty) _recycle();

    topCard = deck.draw();
    discard.add(topCard!);

    setState(() {});
    await Future.delayed(const Duration(milliseconds: 600));

    isAnimating = false;
    handDealt = true;

    // ✅ Turn timer can start now
    playerSelected = true;

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

    if (!mounted) {
      ctrl.dispose();
      moving?.remove();
      moving = null;
      return;
    }

    await ctrl.forward();
    moving?.remove();
    moving = null;
    ctrl.dispose(); // dispose immediately
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
      CenterBanner(context: context,centerKey:centerKey).show("+2", Colors.orangeAccent);
      final myImage = AssetImage('assets/UI/Containers/Hezz2_Effect.png'); // or NetworkImage
      CenterImageEffect(context: context).show(myImage,size: 200);
    } else if (card.rank == 1) {
      skipNext = true;
      CenterBanner(context: context,centerKey:centerKey).show("Skip", Colors.orangeAccent);
      CenterLottieEffect(context: context).show("assets/animations/AnimationSFX/StopPlaying.json",size: 300, duration: const Duration(milliseconds:900 ));
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

          CenterBanner(context: context,centerKey:centerKey).show('Suit: $choice', Colors.orangeAccent);
        }
      } else {
        final suit = _botPickSuit(player);
        CenterBanner(context: context,centerKey:centerKey).show('Suit: $suit', Colors.orangeAccent);
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
    for (final c in hands[bot]) {
      counts[c.suit] = counts[c.suit]! + 1;
    }
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
    if (!mounted) return;

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
          if (start != null && botPos != null) {
            await _animateMoveFaceDown(
              d, start, botPos);
          }
          await Future.delayed(const Duration(milliseconds: 90));
        }
        CenterBanner(context: context,centerKey:centerKey).show('Drew $pendingDraw cards', Colors.purpleAccent);
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
      if (start != null && botPos != null) {
        await _animateMoveFaceDown(
          d, start, botPos);
      }

      CenterBanner(context: context,centerKey:centerKey).show('Drew & skipped', Colors.purpleAccent);
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

    int minDelay = 300; // minimum milliseconds
    int maxDelay = 2000; // maximum milliseconds
    await Future.delayed(Duration(milliseconds: minDelay + Random().nextInt(maxDelay - minDelay)));
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

    if (!mounted) {
      ctrl.dispose();
      movingEntry.remove();
      return;
    }

    await ctrl.forward();
    movingEntry.remove();
    ctrl.dispose(); // dispose right after animation completes
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

    if (!mounted) {
      ctrl.dispose();
      entry.remove();
      return;
    }

    await ctrl.forward();
    entry.remove();
    ctrl.dispose(); // dispose immediately
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

          CenterBanner(context: context,centerKey:centerKey).show('Player ${lastActivePlayer == 0
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

        // Pick a random non-eliminated starter for the round
        int candidate = Random().nextInt(widget.botCount + 1);
        int attempts = 0;
        while (eliminatedPlayers[candidate] && attempts < widget.botCount + 1) {
          candidate = (candidate + 1) % (widget.botCount + 1);
          attempts++;
        }
        // If somehow all are eliminated (shouldn't happen), fallback to 0
        currentPlayer = (attempts <= widget.botCount) ? candidate : 0;
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
              betAmount: widget.selectedBet,
              winnerName: BotDetailsPopup.getBotInfo(winnerIndex).name,
              winnerAvatar: BotDetailsPopup.getBotInfo(winnerIndex).avatarPath,
            ),
      ),
    );
  }

  @override
  void dispose() {
     _isPageActive = false;
    handScrollController.dispose(); // your scroll controller
    super.dispose();
  }


  String? _shownEmoji;
  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context,listen: false);

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background
          Positioned.fill(child: TableBackground()),

          // Optional overlay between rounds
          if (isBetweenRounds)
            Positioned.fill(
              child: RoundCompleteOverlay(
                currentRound: currentRound,
                qualifiedPlayers: qualifiedPlayers,
              ),
            ),

          // Main game UI
          if (!isBetweenRounds)
            SafeArea(
              child: Stack(
                children: [
                  // Top row of horizontal bots
                  if (widget.botCount >= 2 || widget.botCount >= 3)
                    Positioned(
                      top: 110,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (widget.botCount >= 2)
                            GestureDetector(
                              onTap: () => BotDetailsPopup.show(
                                context, 2, hands, eliminatedPlayers, qualifiedPlayers, currentPlayer,
                              ),
                              child: PlayerCard(
                                bot: 2,
                                vertical: false,
                                isEliminated: eliminatedPlayers[2],
                                isQualified: qualifiedPlayers.contains(2),
                                isTurn: currentPlayer == 2,
                                cardCount: hands[2].length,
                                hand: hands[2],
                                playerKey: botKeys[2],
                                handDealt: handDealt,
                              ),
                            ),
                          if (widget.botCount >= 3)
                            GestureDetector(
                              onTap: () => BotDetailsPopup.show(
                                context, 3, hands, eliminatedPlayers, qualifiedPlayers, currentPlayer,
                              ),
                              child: PlayerCard(
                                bot: 3,
                                vertical: false,
                                isEliminated: eliminatedPlayers[3],
                                isQualified: qualifiedPlayers.contains(3),
                                isTurn: currentPlayer == 3,
                                cardCount: hands[3].length,
                                hand: hands[3],
                                playerKey: botKeys[3],
                                handDealt: handDealt,
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Side bots
                  if (widget.botCount >= 1)
                    Positioned(
                      left: 2,
                      top: MediaQuery.of(context).size.height * 0.42,
                      child: GestureDetector(
                        onTap: () => BotDetailsPopup.show(
                          context, 1, hands, eliminatedPlayers, qualifiedPlayers, currentPlayer,
                        ),
                        child: PlayerCard(
                          bot: 1,
                          vertical: true,
                          isEliminated: eliminatedPlayers[1],
                          isQualified: qualifiedPlayers.contains(1),
                          isTurn: currentPlayer == 1,
                          cardCount: hands[1].length,
                          hand: hands[1],
                          playerKey: botKeys[1],
                          handDealt: handDealt,
                        ),
                      ),
                    ),
                  if (widget.botCount >= 4)
                    Positioned(
                      right: 2,
                      top: MediaQuery.of(context).size.height * 0.42,
                      child: GestureDetector(
                        onTap: () => BotDetailsPopup.show(
                          context, 4, hands, eliminatedPlayers, qualifiedPlayers, currentPlayer,
                        ),
                        child: PlayerCard(
                          bot: 4,
                          vertical: true,
                          isEliminated: eliminatedPlayers[4],
                          isQualified: qualifiedPlayers.contains(4),
                          isTurn: currentPlayer == 4,
                          cardCount: hands[4].length,
                          hand: hands[4],
                          playerKey: botKeys[4],
                          handDealt: handDealt,
                        ),
                      ),
                    ),

                  // Center deck
                  DeckCenterPanel(
                    top: MediaQuery.of(context).size.height * 0.36,
                    left: MediaQuery.of(context).size.width * 0.18,
                    right: MediaQuery.of(context).size.width * 0.18,
                    onDraw: _playerDraw,
                    deck: deck,
                    topCard: topCard,
                    discard: discard,
                    deckKey: deckKey,
                    centerKey: centerKey,
                  ),

                  // Player action panel
                  PlayerActionPanel(
                    eliminated: eliminatedPlayers[0],
                    isSpectating: isSpectating,
                    isAnimating: isAnimating,
                    handDealt: handDealt,
                    currentPlayer: currentPlayer,
                    hand: hands[0],
                    selectedAvatar: xpManager.selectedAvatar,
                    username: xpManager.username,
                    onDraw: _playerDraw,
                    handKey: handKey,
                    handScrollController: handScrollController,
                    playerCardKeys: playerCardKeys,
                    onPlayCard: _playCardByHuman,
                    gameModeType: widget.gameModeType,
                    onLeaveGame: () => Navigator.of(context).pop(),
                    onEmojiSelected: (filePath) {
                      setState(() => _shownEmoji = filePath);
                      Future.delayed(const Duration(seconds: 2), () {
                        setState(() => _shownEmoji = null);
                      });
                    },
                  ),

                  // Top AppBar
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: MenuOverlayButton(
                            gameModeName: widget.gameModeType.name,
                            botCount: widget.botCount,
                            selectedBet: widget.selectedBet,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: UserStatusBar(
                              goldKey: goldKey,
                              gemsKey: gemsKey,
                              xpKey: xpKey,
                              showXP: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}