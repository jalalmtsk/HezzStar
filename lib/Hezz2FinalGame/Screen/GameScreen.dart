import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:hezzstar/Hezz2FinalGame/Models/GameCardEnums.dart';
import 'package:hezzstar/Hezz2FinalGame/Tools/Banner/CenterdLottieAnimation.dart';
import 'package:hezzstar/Hezz2FinalGame/Tools/Banner/CenteredImageEffect.dart';
import 'package:hezzstar/MainScreenIndex.dart';

import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:hezzstar/widgets/userStatut/SimpleUserStatusBar.dart';
import 'package:provider/provider.dart';

import '../../widgets/LoadingScreen/LoadinScreenDim.dart';
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

  CenterLottieEffect? _CenteredActiveLottie;
  CenterImageEffect? _CenteredActiveImage;
  CenterBanner? _CenteredActiveBanner;


  late Deck deck;
  final ScrollController handScrollController = ScrollController();
  final botKeys = List.generate(5, (_) => GlobalKey());
  late List<List<PlayingCard>> hands;

  List<Widget> _animatedCardsWidgets = []; // All active animated cards
  List<AnimationController> _activeControllers = []; // Track controllers for disposal

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
  final GlobalKey _animStackKey = GlobalKey();


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
    deck = Deck()..shuffle();
    BotDetailsPopup.resetBotInfos();
    for (var h in hands) {
      h.clear();
    }
    discard.clear();
    currentPlayer = Random().nextInt(widget.botCount + 1);
    pendingDraw = 0;
    skipNext = false;
    gameOver = false;
    winner = '';
    qualifiedPlayers.clear();

    if (widget.gameModeType == GameModeType.elimination) {
      eliminatedPlayers = List.generate(widget.botCount + 1, (_) => false);
      isBetweenRounds = false;
    }

    await PlayerSelector(
      context: context,
      botCount: widget.botCount,
      eliminatedPlayers: eliminatedPlayers,
      onPlayerSelected: (selectedPlayer) => currentPlayer = selectedPlayer,
    ).animateSelection();

    await _precacheAssets(context);

    // Deal starting hands
    for (int round = 0; round < widget.startHandSize; round++) {
      for (int i = 0; i <= widget.botCount; i++) {
        final p = (currentPlayer + i) % (widget.botCount + 1);
        if (eliminatedPlayers[p]) continue;
        await _dealCardToPlayer(p);
      }
    }

    if (deck.isEmpty) _recycle();

    topCard = deck.draw();
    discard.add(topCard!);

    setState(() {
      isAnimating = false;
      handDealt = true;
      playerSelected = true;
    });

    _maybeAutoPlay();
  }



  Future<void> _dealCardToPlayer(int playerIndex, {bool animate = true}) async {
    if (deck.isEmpty) _recycle();
    if (deck.isEmpty) return;

    final card = deck.draw();
    hands[playerIndex].add(card);

    // 🔊 Play card-deal sound
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playSfx("assets/audios/UI/SFX/CardSwapVolumeUp.mp3"); // Add your card deal
    if (!animate) return;

    final start = _rectFor(deckKey)?.center;
    Offset? end;

    if (playerIndex == 0) {
      final idx = hands[0].length - 1;
      if (idx < playerCardKeys.length) {
        end = _rectFor(playerCardKeys[idx])?.center;
      }
      end ??= Offset(MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height - 90);
    } else {
      end = _cardStartForPlayer(playerIndex, hands[playerIndex].length - 1);
    }

    if (start != null && end != null) {
      await _animateMoveFaceDown(card, start, end);
    }

    setState(() {});
    await Future.delayed(const Duration(milliseconds: 90));
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

  void playSfxVoice(String Asset){
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playSfx(Asset);
  }

  Future<void> _waitForAllAnimations() async {
    // Wait until all active animation controllers are done
    while (_activeControllers.any((ctrl) => ctrl.isAnimating)) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    // Just in case some overlays are still on screen
    while (_activeOverlays.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }


  // Internal generic method
  Future<void> _animateCardInternal(
      PlayingCard card,
      Offset fromGlobal,
      Offset toGlobal, {
        required bool faceUp,
        bool flip = false,
        bool cinematic = false,
        Duration? duration,
      }) async {
    if (!_isPageActive) return;

    final dur = duration ??
        (flip
            ? const Duration(milliseconds: 600)
            : (cinematic ? playDur : drawDur));

    final ctrl = AnimationController(vsync: this, duration: dur);
    final curve = CurvedAnimation(parent: ctrl, curve: Curves.easeInOutCubic);

    // card dimensions (single source of truth)
    const double cardW = 70.0;
    const double cardH = 110.0;
    final halfW = cardW / 2;
    final halfH = cardH / 2;

    // Convert the global screen coordinates (fromGlobal,toGlobal)
    // to local coordinates of the animation Stack so Positioned left/top align correctly.
    Offset? start = fromGlobal;
    Offset? end = toGlobal;
    try {
      final stackContext = _animStackKey.currentContext;
      if (stackContext != null) {
        final RenderBox stackBox = stackContext.findRenderObject() as RenderBox;
        start = stackBox.globalToLocal(fromGlobal);
        end = stackBox.globalToLocal(toGlobal);
      }
    } catch (_) {
      // fallback - keep globals if conversion fails
    }

    // Create the animated widget
    late Widget animatedCard;
    animatedCard = AnimatedBuilder(
      animation: curve,
      builder: (_, __) {
        final pos = Offset.lerp(start!, end!, curve.value)!;

        double scale = 1.0;
        double rotationY = 0.0;
        double opacity = 1.0;
        Widget child;

        if (flip) {
          final flipProgress = curve.value;
          rotationY = flipProgress * pi;
          // Use small uniform scaling so center remains stable
          scale = 1.0 + 0.05 * sin(rotationY);
          final showFront = flipProgress > 0.5;

          child = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(scale, scale) // uniform scale to keep center
              ..rotateY(rotationY),
            child: SizedBox(
              width: cardW,
              height: cardH,
              child: Image.asset(
                  showFront ? card.assetName : card.backAsset(context),
                  fit: BoxFit.cover),
            ),
          );
        } else {
          scale = cinematic ? 1.0 + 0.06 * sin(curve.value * pi) : 1.0;
          opacity = cinematic ? 0.5 + curve.value * 0.5 : 1.0;
          child = Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: SizedBox(
              width: cardW,
              height: cardH,
              child: Image.asset(
                  faceUp ? card.assetName : card.backAsset(context),
                  fit: BoxFit.cover),
            ),
          );
        }

        // Position so the center of the card is at pos
        return Positioned(
          left: pos.dx - halfW,
          top: pos.dy - halfH,
          child: Opacity(opacity: opacity,
          child: child),
        );
      },
    );

    if (!_isPageActive) return;
    setState(() {
      _animatedCardsWidgets.add(animatedCard);
      _activeControllers.add(ctrl);
    });

    try {
      await ctrl.forward();
    } catch (_) {}

    if (!_isPageActive) return;
    setState(() {
      _animatedCardsWidgets.remove(animatedCard);
      _activeControllers.remove(ctrl);
    });
    ctrl.dispose();
  }




// Public methods
  Future<void> _animateMove(PlayingCard card, Offset from, Offset to, {bool cinematic = false}) async {
    return _animateCardInternal(card, from, to, faceUp: true, flip: false, cinematic: cinematic);
  }

  Future<void> _animateMoveFaceDown(PlayingCard card, Offset from, Offset to) async {
    return _animateCardInternal(card, from, to, faceUp: false, flip: false);
  }

  Future<void> _animateMoveFaceDownToFaceUp(PlayingCard card, Offset from, Offset to) async {
    return _animateCardInternal(card, from, to, faceUp: true, flip: true);
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
      // Add to pending draw
      pendingDraw += 2;

      // Decide which sound to play based on the total
      switch (pendingDraw) {
        case 2:
          playSfxVoice("assets/audios/UI/SFX/Voices/Hezz2.mp3");
          break;
        case 4:
          playSfxVoice("assets/audios/UI/SFX/Voices/Hezz4.mp3");
          break;
        case 6:
          playSfxVoice("assets/audios/UI/SFX/Voices/Hezz6.mp3");
          break;
        case 8:
          playSfxVoice("assets/audios/UI/SFX/Voices/Hezz8.mp3");
          break;
        default:
          playSfxVoice("assets/audios/UI/SFX/Voices/Hezz2.mp3");
          break;
      }

      // Show visual effect
      setState(() {
        _CenteredActiveBanner = CenterBanner(
          text: "+$pendingDraw",
          color: Colors.orangeAccent,
          onEnd: () => setState(() => _CenteredActiveBanner = null),
        );
      });

      setState(() {
        _CenteredActiveImage = CenterImageEffect(
          imagePath: "assets/UI/Containers/Hezz2_Effect.png",
          onEnd: () {
            setState(() {
              _CenteredActiveImage = null; // remove it when done
            });
          },
        );
      });
    }

    else if (card.rank == 1) {
      skipNext = true;
      playSfxVoice("assets/audios/UI/SFX/Voices/Roppo_Voice.mp3");
      playSfxVoice("assets/audios/UI/SFX/Gamification_SFX/SpecialCard1WhooshEffect.mp3");
      setState(() {
        _CenteredActiveBanner = CenterBanner(
          text: "Skip",
          color: Colors.orangeAccent,
          onEnd: () => setState(() => _CenteredActiveBanner = null),
        );
      });

      // Show Lottie animation
      setState(() {
        _CenteredActiveLottie = CenterLottieEffect(
          lottieAsset: 'assets/animations/AnimationSFX/StopPlaying.json',
          size: 300,
          onEnd: () {
            setState(() {
              _CenteredActiveLottie = null; // remove it when done
            });
          },
        );
      });
    }

    else if (card.rank == 7) {
      if (player == 0) {
        final previousSuit = topCard?.suit ?? "Coins";
        final choice = await _askSuit(previousSuit);

        if (choice != null) {
          final audioManager = Provider.of<AudioManager>(context, listen: false);
          audioManager.playSfx("assets/audios/UI/SFX/CardSound.mp3");

          setState(() {
            topCard = PlayingCard(suit: choice, rank: 7);
            discard.removeLast();
            discard.add(topCard!);
          });

          setState(() {
            _CenteredActiveBanner = CenterBanner(
              text: 'Suit: $choice',
              color: Colors.orangeAccent,
              onEnd: () => setState(() => _CenteredActiveBanner = null),
            );
          });

        }
      } else {
        final suit = _botPickSuit(player);
        setState(() {
          _CenteredActiveBanner = CenterBanner(
            text: 'Suit: $suit',
            color: Colors.orangeAccent,
            onEnd: () => setState(() => _CenteredActiveBanner = null),
          );
        });

        await Future.delayed(const Duration(milliseconds: 1200));

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
      barrierColor: Colors.black.withOpacity(0.5),
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
        setState(() {
          _CenteredActiveBanner = CenterBanner(
            text: 'Drew $pendingDraw cards',
            color: Colors.purpleAccent,
            onEnd: () => setState(() => _CenteredActiveBanner = null),
          );
        });
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

      setState(() {
        _CenteredActiveBanner = CenterBanner(
          text: 'Drew & skipped',
          color: Colors.purpleAccent,
          onEnd: () => setState(() => _CenteredActiveBanner = null),
        );
      });

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
            if (!eliminationOrder.contains(lastActivePlayer)) {
              eliminationOrder.add(lastActivePlayer);
            }
            eliminatedPlayers[lastActivePlayer] = true;

            setState(() {
              _CenteredActiveBanner = CenterBanner(
                text: 'Player ${lastActivePlayer == 0
                    ? "You"
                    : "Bot $lastActivePlayer"} eliminated!',
                color: Colors.red,
                onEnd: () => setState(() => _CenteredActiveBanner = null),
              );
            });

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


  List<int> eliminationOrder = []; // 0 = first eliminated, last = winner

  void _startNextRound() {
    setState(() {
      isBetweenRounds = true;
      isSpectating = false;
      handDealt = false; // Reset hand dealt state
    });

    Future.delayed(const Duration(seconds: 2), () async {
      setState(() {
        currentRound++;
        isBetweenRounds = false;

        // Reset deck
        deck = Deck();
        deck.shuffle();

        // Clear discard and set top card later
        discard.clear();
        topCard = null;

        // Reset round state
        pendingDraw = 0;
        skipNext = false;
        qualifiedPlayers.clear();
      });

      // Deal hands with animation
      for (int i = 0; i <= widget.botCount; i++) {
        if (!eliminatedPlayers[i]) {
          hands[i].clear(); // Clear previous round cards
          for (int j = 0; j < widget.startHandSize; j++) {
            await _dealCardToPlayer(i); // 🔑 Use your deal function for proper animation
          }
        }
      }

      // Draw top card
      if (deck.isEmpty) _recycle();
      topCard = deck.draw();
      discard.add(topCard!);

      // Pick random starting player who is not eliminated
      int candidate = Random().nextInt(widget.botCount + 1);
      int attempts = 0;
      while (eliminatedPlayers[candidate] && attempts < widget.botCount + 1) {
        candidate = (candidate + 1) % (widget.botCount + 1);
        attempts++;
      }
      currentPlayer = (attempts <= widget.botCount) ? candidate : 0;

      setState(() {
        handDealt = true; // Show hands after dealing
      });

      // Start bot/autoplay after UI updated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeAutoPlay();
      });
    });
  }


  List<Map<String, dynamic>> _computePlayerRanks() {
    final List<Map<String, dynamic>> ranks = [];

    for (int i = 0; i <= widget.botCount; i++) {
      String name;
      String? avatar;
      if (i == 0) {
        name = "You";
        avatar = Provider.of<ExperienceManager>(context, listen: false).selectedAvatar;
      } else {
        name = BotDetailsPopup.getBotInfo(i).name;
        avatar = BotDetailsPopup.getBotInfo(i).avatarPath;
      }

      int rank;
      if (widget.gameModeType == GameModeType.elimination) {
        // Assign rank based on elimination order
        if (eliminationOrder.contains(i)) {
          rank = eliminationOrder.indexOf(i) + 1;
        } else {
          // Winner is last one remaining
          rank = eliminationOrder.length + 1;
        }
      } else {
        // PlayToWin mode - fewer cards = better rank
        rank = hands[i].length;
      }

      ranks.add({
        'playerIndex': i,
        'name': name,
        'avatar': avatar,
        'rank': rank,
        'eliminated': eliminatedPlayers[i],
      });
    }

    // Sort by rank (ascending)
    ranks.sort((a, b) => a['rank'].compareTo(b['rank']));
    return ranks;
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
      for (int i = 0; i < eliminatedPlayers.length; i++) {
        if (!eliminatedPlayers[i]) {
          winnerIndex = i;
          break;
        }
      }
    }

    final playerRanks = _computePlayerRanks().map((e) => e['score'] as int).toList();

    LoadingScreenDim.show(
      context,
      seconds: 3,
      lottieAsset: 'assets/animations/AnimationSFX/HezzFinal.json',
      onComplete: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EndGameScreen(
              hands: hands,
              winnerIndex: winnerIndex,
              gameModeType: widget.gameModeType,
              currentRound: currentRound,
              betAmount: widget.selectedBet,
              winnerName: BotDetailsPopup.getBotInfo(winnerIndex).name,
              winnerAvatar: BotDetailsPopup.getBotInfo(winnerIndex).avatarPath,
              playerRanks: playerRanks, // pass full ranks
            ),
          ),
        );
      },
    );
  }

  final List<OverlayEntry> _activeOverlays = [];
  @override
  void dispose() {
    _isPageActive = false;

    // Stop all active animations
    for (final ctrl in _activeControllers) {
      ctrl.stop();
      ctrl.dispose();
    }
    _activeControllers.clear();

    // Remove all overlay entries
    for (final entry in _activeOverlays) {
      entry.remove();
    }
    _activeOverlays.clear();

    handScrollController.dispose();
    super.dispose();
  }


  String? _shownEmoji;
  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context,listen: false);

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final quit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Quit Game?"),
              content: const Text("Are you sure you want to leave the match?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx, true); // close the dialog first

                    // Wait until all animations finish
                    await _waitForAllAnimations();

                    // Then exit the game screen
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> MainScreen())); // pop the GameScreen
                    }
                  },
                  child: const Text("Quit"),
                ),

              ],
            ),
          );

          if (quit == true && context.mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> MainScreen())); // pop the GameScreen
          }
        }
      },
      child: Scaffold(
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
                  key: _animStackKey,
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
                                  context, 2, xpManager, hands, eliminatedPlayers, qualifiedPlayers, currentPlayer,
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
                                  context, 3,xpManager, hands, eliminatedPlayers, qualifiedPlayers, currentPlayer,
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
                            context, 1,xpManager, hands, eliminatedPlayers, qualifiedPlayers, currentPlayer,
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
                            context, 4,xpManager, hands, eliminatedPlayers, qualifiedPlayers, currentPlayer,
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
                      top: MediaQuery.of(context).size.height * 0.42,
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
                      onLeaveGame: () => _showEnd(),
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
                            flex: 1,
                            child: handDealt
                                ? MenuOverlayButton(
                              gameModeName: widget.gameModeType.name,
                              botCount: widget.botCount,
                              selectedBet: widget.selectedBet,
                            )
                                : const SizedBox.shrink(key: ValueKey("empty-menu")),
                          ),
                          const SizedBox(width: 30,),
                          Expanded(
                            flex: 4,
                            child: SimpleUserStatusBar()
                          ),
                        ],
                      ),
                    ),



                    if (_CenteredActiveBanner != null)
                      Center(
                        child: _CenteredActiveBanner!,
                      ),
                    if (_CenteredActiveLottie != null)
                      Center(
                        child: _CenteredActiveLottie!,
                      ),
                    if (_CenteredActiveImage != null)
                      Center(
                        child: _CenteredActiveImage!,
                      ),

                    ..._animatedCardsWidgets,    // Animated cards being played

                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}