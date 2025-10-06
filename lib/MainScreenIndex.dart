import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/IndexPages/Settings/SettingPage.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:provider/provider.dart';
import 'IndexPages/Collection/MainCollectionPage.dart';
import 'IndexPages/EventsPage/EventPage.dart';
import 'IndexPages/HomePage/HomePage.dart';
import 'IndexPages/ShopPage/ShopPage.dart';


final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2;


  void goToShop() {
    setState(() {
      _selectedIndex = 0; // switch to Shop tab
    });
  }


  final List<Widget> _pages = [
    const ShopPage(),
    const MainCollectionPage(),
    const HomePage(),
    const EventsPage(),
    const SettingsPage(),
  ];

  late final AnimationController _pulseController;
  late final AnimationController _sparkController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.95,
      upperBound: 1.15,
    )..repeat(reverse: true);

    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playEventSound("sandClick");
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabCount = _pages.length;
    final padding = 50.0;
    final tabWidth = (screenWidth - padding) / tabCount;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/UI/BackgroundImage/bg9.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5), // dark overlay on main background
            BlendMode.darken,
          ),
        ),
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: _pages[_selectedIndex],
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Positioned.fill(
                    child: Image.asset(
                      "assets/UI/BackgroundImage/bg7.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Black shadow overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.85),
                            Colors.black.withOpacity(0.8),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  // Blur effect
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // BottomNavigationBar
                  BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.white70,
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    type: BottomNavigationBarType.fixed,
                    showUnselectedLabels: true,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1C40F),
                    ),
                    items: [

                      _buildNavItem(
                        index: 0,
                        label: "Shop",
                        selectedIcon: 'assets/UI/Icons/Shop_Icon.png',
                        unselectedIcon: 'assets/UI/Icons/Shop_Icon.png',
                      ),
                      _buildNavItem(
                        index: 1,
                        label: "Collections",
                        selectedIcon: 'assets/UI/Icons/Collection_Icon.png',
                        unselectedIcon: 'assets/UI/Icons/Collection_Icon.png',
                      ),
                      _buildNavItem(
                        index: 2,
                        label: "Home",
                        selectedIcon: 'assets/UI/Icons/Home_Icon.png',
                        unselectedIcon: 'assets/UI/Icons/Home_Icon.png',
                      ),
                      _buildNavItem(
                        index: 3,
                        label: "Events",
                        selectedIcon: 'assets/UI/Icons/Events_Icon.png',
                        unselectedIcon: 'assets/UI/Icons/Events_Icon.png',
                      ),
                      _buildNavItem(
                        index: 4,
                        label: "Settings",
                        selectedIcon: 'assets/UI/Icons/Settings_Icon.png',
                        unselectedIcon: 'assets/UI/Icons/Settings_Icon.png',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required int index,
    required String label,
    required String selectedIcon,
    required String unselectedIcon,
  }) {
    bool isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Pulse effect behind icon
          if (isSelected)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseController.value,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF1C40F), Color(0xFF9B59B6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFF1C40F).withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Color(0xFF9B59B6).withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 3,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Spark animation
          if (isSelected)
            AnimatedBuilder(
              animation: _sparkController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(64, 64),
                  painter: _SparkPainter(_sparkController.value),
                );
              },
            ),

          // Icon
          ScaleTransition(
            scale: isSelected
                ? Tween(begin: 1.0, end: 1.2).animate(_pulseController)
                : const AlwaysStoppedAnimation(1.0),
            child: Image.asset(
              isSelected ? selectedIcon : unselectedIcon,
              height: isSelected ? 65 : 58,
            ),
          ),
        ],
      ),
      label: label,
    );
  }
}

// Spark effect painter
class _SparkPainter extends CustomPainter {
  final double progress;
  final Random _random = Random();

  _SparkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFF1C40F).withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final angle = 2 * pi * i / 6 + progress * 2 * pi;
      final distance = 28 + _random.nextDouble() * 4;
      final pos = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );
      canvas.drawCircle(pos, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => true;
}
