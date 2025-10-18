import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../tools/AudioManager/AudioManager.dart';

class InstructionsDialog extends StatefulWidget {
  const InstructionsDialog({super.key});

  @override
  State<InstructionsDialog> createState() => _InstructionsDialogState();
}

class _InstructionsDialogState extends State<InstructionsDialog>
    with TickerProviderStateMixin {
  bool _controlsOpen = true;
  bool _rewardsOpen = false;
  bool _tipsOpen = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  final PageController _controlsController = PageController();
  final PageController _rewardsController = PageController();
  final PageController _tipsController = PageController();

  int _controlsPage = 0;
  int _rewardsPage = 0;
  int _tipsPage = 0;

  Color primaryAccent = Colors.greenAccent;
  Color secondaryAccent = Colors.tealAccent;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controlsController.addListener(() {
      setState(() {
        _controlsPage =
            _controlsController.page?.round() ?? _controlsPage;
      });
    });
    _rewardsController.addListener(() {
      setState(() {
        _rewardsPage = _rewardsController.page?.round() ?? _rewardsPage;
      });
    });
    _tipsController.addListener(() {
      setState(() {
        _tipsPage = _tipsController.page?.round() ?? _tipsPage;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controlsController.dispose();
    _rewardsController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  void _togglePanel(String key) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    if (!mounted) return;
    audioManager.playEventSound('sandClick');

    setState(() {
      switch (key) {
        case 'controls':
          _controlsOpen = !_controlsOpen;
          break;
        case 'rewards':
          _rewardsOpen = !_rewardsOpen;
          break;
        case 'tips':
          _tipsOpen = !_tipsOpen;
          break;
      }
    });
  }

  Widget _luxHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
          boxShadow: [
            BoxShadow(
                color: primaryAccent.withOpacity(0.32),
                blurRadius: 12,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children:  [
            Text(
              "📖 ${tr(context).instructions}",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel({
    required String id,
    required IconData icon,
    required String title,
    required Color accent,
    required bool open,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: open ? accent.withOpacity(0.75) : Colors.white12,
            width: open ? 2.2 : 1.0),
        boxShadow: open
            ? [
          BoxShadow(
              color: accent.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ]
            : [
          BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 4))
        ],
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(open ? 0.04 : 0.02),
            Colors.black.withOpacity(open ? 0.04 : 0.02)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 20,
                  backgroundColor: accent.withAlpha(40),
                  child: Icon(icon, color: accent)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              GestureDetector(
                onTap: () => _togglePanel(id),
                child: AnimatedRotation(
                  turns: open ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child:
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: child,
            ),
            crossFadeState:
            open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 350),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeOutBack,
          ),
        ],
      ),
    );
  }

  Widget _dotsIndicator(int count, int index, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          width: i == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == index ? color : Colors.white24,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.78,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                    color: primaryAccent.withOpacity(0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 12))
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _luxHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 16),
                    child: ListView(
                      children: [
                        // Game Setup & Controls
                        _buildPanel(
                          id: 'controls',
                          icon: Icons.gamepad,
                          title: tr(context).gameSetupAndControls,
                          accent: Colors.tealAccent,
                          open: _controlsOpen,
                          child: SizedBox(
                            height: 250,
                            child: Column(
                              children: [
                                Expanded(
                                  child: PageView(
                                    controller: _controlsController,
                                    children: [
                                      _specialCardPage(
                                          imagePath:
                                          'assets/images/Tutorials/PlayToWinVsElim.png',
                                          title: 'Player Mode',
                                          description:
                                          tr(context).chooseMode),

                                      _specialCardPage(
                                          imagePath:
                                          'assets/images/Tutorials/SameSuitSameRank.png',
                                          title: 'Suits/Ranks',
                                          description:
                                          tr(context).suitsAndRanks),
                                    ],
                                  ),
                                ),
                                _dotsIndicator(
                                    2, _controlsPage, Colors.tealAccent),
                              ],
                            ),
                          ),
                        ),

                        // Special Cards
                        _buildPanel(
                          id: 'rewards',
                          icon: Icons.military_tech,
                          title: tr(context).specialCardsAndEffects,
                          accent: Colors.amberAccent,
                          open: _rewardsOpen,
                          child: SizedBox(
                            height: 250,
                            child: Column(
                              children: [
                                Expanded(
                                  child: PageView(
                                    controller: _rewardsController,
                                    children: [
                                      _specialCardPage(
                                          imagePath:
                                          'assets/images/Tutorials/StackOfOnes_Tuto.png',
                                          title: tr(context).skipCard ,
                                          description:
                                          tr(context).skipsNextPlayerTurn),
                                      _specialCardPage(
                                          imagePath:
                                          'assets/images/Tutorials/StacksOfTwos_Tuto.png',
                                          title: tr(context).drawTwoCard,
                                          description:
                                          tr(context).drawTwoEffect),
                                      _specialCardPage(
                                          imagePath:
                                          'assets/images/Tutorials/StackOfSevens_Tuto.png',
                                          title: tr(context).changeSuitCard,
                                          description:
                                          tr(context).changeSuitEffect),
                                    ],
                                  ),
                                ),
                                _dotsIndicator(
                                    3, _rewardsPage, Colors.amberAccent),
                              ],
                            ),
                          ),
                        ),

                        // Gameplay Tips
                        _buildPanel(
                          id: 'tips',
                          icon: Icons.lightbulb,
                          title: tr(context).gameplayTips,
                          accent: Colors.greenAccent,
                          open: _tipsOpen,
                          child: SizedBox(
                            height: 250,
                            child: Column(
                              children: [
                                Expanded(
                                  child: PageView(
                                    controller: _tipsController,
                                    children: [
                                      _specialCardPage(
                                          imagePath:
                                          'assets/images/Tutorials/Tip1.png',
                                          title: tr(context).tip1,
                                          description:
                                          tr(context).tip1Description),
                                      _specialCardPage(
                                          imagePath:
                                          'assets/images/Tutorials/Tip2.png',
                                          title: tr(context).tip2,
                                          description:
                                          'In Elimination mode, avoid being last to finish.'),
                                      _specialCardPage(
                                          imagePath:
                                          'assets/images/Tutorials/SpecialCards.png',
                                          title: tr(context).tip3,
                                          description:
                                          tr(context).tip3Description),
                                    ],
                                  ),
                                ),
                                _dotsIndicator(
                                    3, _tipsPage, Colors.greenAccent),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              audioManager.playEventSound('sandClick');
                              Navigator.of(context).pop();
                            },
                            child: ScaleTransition(
                              scale: _pulseAnim,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 18),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                      colors: [primaryAccent, secondaryAccent]),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                        primaryAccent.withOpacity(0.28),
                                        blurRadius: 8,
                                        offset: const Offset(0, 6))
                                  ],
                                ),
                                child:  Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.close, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(tr(context).close,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _specialCardPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(description,
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
