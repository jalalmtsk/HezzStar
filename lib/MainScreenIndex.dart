import 'package:flutter/material.dart';
import 'package:hezzstar/Shop/MainShopIndex.dart';
import 'IndexPages/HomePage/HomePage.dart';
import 'IndexPages/SettingsPage/SettingsPage.dart';
import 'main.dart';
import 'dart:math';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CollectionsPage(),
    const MainCardShopPage(),
    const HomePage(),
    const EventsPage(),
    SettingsPage(),
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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0x9B59B6), Color(0xF1C40F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              alignment: Alignment.center,
              children: [
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
                    color: Color(0xF1C40F),
                  ),
                  items: [
                    _buildNavItem(
                      index: 0,
                      label: "Collections",
                      selectedIcon: 'assets/UI/Icons/Collection_Icon.png',
                      unselectedIcon: 'assets/UI/Icons/Collection_Icon.png',
                    ),
                    _buildNavItem(
                      index: 1,
                      label: "Shop",
                      selectedIcon: 'assets/UI/Icons/Shop_Icon.png',
                      unselectedIcon: 'assets/UI/Icons/Shop_Icon.png',
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
        children: [
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
                        colors: [Color(0xF1C40F), Color(0x9B59B6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xF1C40F).withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Color(0x9B59B6).withOpacity(0.6),
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

// 🔹 Spark effect painter
class _SparkPainter extends CustomPainter {
  final double progress;
  final Random _random = Random();

  _SparkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xF1C40F).withOpacity(0.6)
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
