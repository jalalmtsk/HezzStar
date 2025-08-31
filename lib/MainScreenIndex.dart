import 'package:flutter/material.dart';
import 'package:hezzstar/Shop/MainShopIndex.dart';
import 'IndexPages/HomePage/HomePage.dart';
import 'main.dart';
import 'dart:math';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2;

  final List<Widget> _pages = const [
    FriendsPage(),
    MainCardShopPage(),
    HomePage(),
    EventsPage(),
    CollectionsPage(),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade800, Colors.purpleAccent.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30,
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
                  selectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, color: Colors.yellowAccent),
                  items: List.generate(5, (index) {
                    IconData icon;
                    String label;
                    switch (index) {
                      case 0:
                        icon = Icons.people;
                        label = "Friends";
                        break;
                      case 1:
                        icon = Icons.storefront_outlined;
                        label = "Shop";
                        break;
                      case 2:
                        icon = Icons.home_mini;
                        label = "Home";
                        break;
                      case 3:
                        icon = Icons.event_outlined;
                        label = "Events";
                        break;
                      default:
                        icon = Icons.image_aspect_ratio;
                        label = "Collections";
                    }

                    bool isSelected = _selectedIndex == index;

                    return BottomNavigationBarItem(
                      icon: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Neon glow bubble
                          if (isSelected)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseController.value,
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Colors.yellowAccent, Colors.orangeAccent],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.yellowAccent.withOpacity(0.8),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.orangeAccent.withOpacity(0.6),
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
                          // Particle sparks
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
                            child: Icon(
                              icon,
                              size: isSelected ? 32 : 26,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      label: label,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
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
      ..color = Colors.yellowAccent.withOpacity(0.6)
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
