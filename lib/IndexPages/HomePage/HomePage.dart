import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';

import 'package:provider/provider.dart';

import '../../Hezz2FinalGame/Screen/GameLauncher/CardGameLauncher.dart';
import '../../Manager/HelperClass/FlyingRewardManager.dart';
import '../../Manager/HelperClass/RewardDimScreen.dart';
import '../../tools/AdsManager/AdsGameButton.dart';
import '../../tools/AudioManager/AudioManager.dart';
import '../../tools/ConnectivityManager/ConnectivityManager.dart';
import '../../widgets/userStatut/userStatus.dart';
import 'AvatarDetailsPopup.dart';
import 'Widgets/AvatarCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = 'HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _introController;

  final GlobalKey goldKeyHome = GlobalKey();
  final GlobalKey gemsKeyHome = GlobalKey();
  final GlobalKey xpKeyHome = GlobalKey();




  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _introController.forward();

      FlyingRewardManager().init(context);
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/UI/BackgroundImage/HomeScreenBg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🌟 Status Bar
                  FadeTransition(
                    opacity: CurvedAnimation(
                        parent: _introController, curve: const Interval(0.0, 0.3)),
                    child: SlideTransition(
                      position: Tween<Offset>(
                          begin: const Offset(0, -0.3), end: Offset.zero)
                          .animate(CurvedAnimation(
                          parent: _introController, curve: const Interval(0.0, 0.3))),
                      child: UserStatusBar(goldKey: goldKeyHome, gemsKey: gemsKeyHome, xpKey: xpKeyHome),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 🌟 Avatar + Buttons
                  FadeTransition(
                    opacity: CurvedAnimation(
                        parent: _introController, curve: const Interval(0.2, 0.5)),
                    child: SlideTransition(
                      position: Tween<Offset>(
                          begin: const Offset(-0.5, 0), end: Offset.zero)
                          .animate(CurvedAnimation(
                          parent: _introController, curve: const Interval(0.2, 0.5))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => AvatarDetailsPopup.show(context, xpManager),
                            child: SizedBox(
                              child: AvatarCard(
                                playerName: xpManager.userProfile.username ?? "Player Name",
                                avatarPath: xpManager.selectedAvatar ??
                                    "assets/images/Skins/AvatarSkins/DefaultUser.png",
                                onTap: () => AvatarDetailsPopup.show(context, xpManager),
                                size: 60,
                                backgroundImage: 'assets/UI/Containers/ImageCard2.jpg',
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              AdsGameCard(
                                text: "",
                                sparkleAsset: "assets/animations/AnimationSFX/RewawrdLightEffect.json",
                                boxAsset: "assets/animations/AnimatGamification/AdsBox.json",
                                rewardAmount: 5,
                                gemsKey: gemsKeyHome,
                                backgroundImage: 'assets/UI/Containers/ImageCard2.jpg',
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  GestureDetector(
                    child: Icon(Icons.add, color: Colors.white,),
                    onTap: () {
                      final audioManager = Provider.of<AudioManager>(context, listen: false);
                      audioManager.playSfx("assets/audios/UI/SFX/Voices/Hezz.ogg");

                      RewardDimScreen.show(
                        context,
                        start: const Offset(200, 400),
                        endKey: gemsKeyHome,
                        amount: 5000,
                        type: RewardType.gem,
                      );

                      RewardDimScreen.show(
                        context,
                        start: const Offset(200, 400),
                        endKey: goldKeyHome,
                        amount: 10000,
                        type: RewardType.gold,
                      );
                      RewardDimScreen.show(
                        context,
                        start: const Offset(200, 400),
                        endKey: xpKeyHome,
                        amount: 50,
                        type: RewardType.star,
                      );


                    },

                  ),



                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: (){
                        xpManager.addExperience(
                          10,              // XP amount
                          context: context, // needed for dimmed reward screen
                          gemsKey: gemsKeyHome, // where the flying gems fly to
                        );
                      }, icon: Image.asset(
                          height: 60,
                          width: 60,
                          "assets/UI/Icons/Locked_Icon.png")),
                      Row(
                        children: [
                          IconButton(onPressed: (){
                            xpManager.addExperience(
                              10,              // XP amount
                              context: context, // needed for dimmed reward screen
                              gemsKey: gemsKeyHome, // where the flying gems fly to
                            );
                          }, icon: Image.asset(
                              height: 60,
                              width: 60,
                              "assets/UI/Icons/Locked_Icon.png")),

                          IconButton(onPressed: (){
                            xpManager.addExperience(
                              10,              // XP amount
                              context: context, // needed for dimmed reward screen
                              gemsKey: gemsKeyHome, // where the flying gems fly to
                            );
                          }, icon: Image.asset(
                              height: 60,
                              width: 60,
                              "assets/UI/Icons/Locked_Icon.png")),
                        ],
                      ),
                    ],
                  ),
                  // 🌟 Horizontal game modes
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _introController,
                      builder: (context, child) {
                        return Consumer<ConnectivityService>(
                          builder: (context, connectivity, _) {
                            final bool connected = connectivity.isConnected;

                            PageController _pageController = PageController(
                              viewportFraction: 0.75,
                              initialPage: 0,
                            );

                            return PageView.builder(
                              controller: _pageController,
                              itemCount: _modes.length,
                              padEnds: false,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final mode = _modes[index];
                                return AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, child) {
                                    double scale = 1.0;
                                    if (_pageController.position.haveDimensions) {
                                      scale = (_pageController.page! - index).abs();
                                      scale = 1 - (scale * 0.15).clamp(0.0, 0.15);
                                    }
                                    return Transform.scale(
                                      scale: scale,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                        child: _modeCard(mode['title']!, mode['botCount']!, index),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _modes = [
    {'title': '⚡ 1 vs 1', 'botCount': 1},
    {'title': '👥 3 Players', 'botCount': 2},
    {'title': '🎯 4 Players', 'botCount': 3},
    {'title': '🔥 5 Players', 'botCount': 4},
    {'title': '🛰 Offline Mode', 'botCount': 4},
  ];

  Widget _modeCard(String title, int botCount, int index) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        final bool connected = connectivity.isConnected;
        final bool isOfflineMode = title.contains("Offline");

        return GestureDetector(
          onTap: (connected || isOfflineMode)
              ? () {
            final audioManager = Provider.of<AudioManager>(context, listen: false);
            audioManager.playEventSound("sandClick");

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => CardGameLauncher(botCount: botCount),
                transitionsBuilder: (_, anim, __, child) {
                  return ScaleTransition(
                    scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                    child: child,
                  );
                },
              ),
            );
          }
              : () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("⚠️ You are not connected to the internet"),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 2),
              ),
            );
          },

          child: Opacity(
            opacity: (connected || isOfflineMode) ? 1.0 : 0.5,
            child: Container(
              width: 240,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.withOpacity(0.8), Colors.black87],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Image with dim
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/UI/modes/mode_${index + 1}.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),

                  // Title Center
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.lightGreenAccent, blurRadius: 12),
                          Shadow(color: Colors.black, blurRadius: 20),
                        ],
                      ),
                    ),
                  ),

                  // Pulsing Dot
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _StatusDot(connected: connected, isOffline: isOfflineMode),
                  ),

                  // Bottom Info Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                isOfflineMode
                                    ? "Offline"
                                    : "${botCount + 1} Players",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  title: Text(title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  content: Text(
                                    isOfflineMode
                                        ? "Play without internet. Great for practicing!"
                                        : "Challenge ${botCount + 1} players in this mode.",
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Close",
                                          style: TextStyle(color: Colors.green)),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Icon(Icons.info_outline,
                                color: Colors.white70, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
// ✅ Pulsing Status Dot
class _StatusDot extends StatefulWidget {
  final bool connected;
  final bool isOffline;
  const _StatusDot({required this.connected, required this.isOffline});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = (widget.connected || widget.isOffline) ? Colors.green : Colors.red;
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
