import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';
import 'package:provider/provider.dart';

import '../../Hezz2FinalGame/Screen/CardGameLauncher.dart';
import '../../widgets/userStatut/userStatus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xpManager = Provider.of<ExperienceManager>(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return  Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/UI/modes/fdf.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), // dark overlay to keep UI readable
                  BlendMode.darken,
                ),
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20,),
              UserStatusBar(),

              const SizedBox(height: 20),

              // Glowing Game Title
              Container(
                height: 170,
                width: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/UI/modes/logo4-removebg-preview.png'),
                    fit: BoxFit.cover, // Keeps the image size as-is
                    alignment: Alignment.center, // Centers the image
                  ),
                ),
              ),

              const SizedBox(height: 80,),
              // Scrollable Game Modes
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _modes.length,
                  itemBuilder: (context, index) {
                    final mode = _modes[index];
                    return _modeCard(mode['title']!, mode['botCount']!, index);
                  },
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 10,
                  shadowColor: Colors.yellowAccent,
                ),
                onPressed: () {
                  xpManager.addGold(30000);
                  xpManager.addGems(40000);
                },
                icon: const Icon(Icons.add, color: Colors.yellowAccent),
                label: const Text(
                  "Add 300 Gold",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _modes = [
    {'title': '1 vs 1', 'botCount': 1},
    {'title': '3 Players', 'botCount': 2},
    {'title': '4 Players', 'botCount': 3},
    {'title': '5 Players', 'botCount': 4},
    {'title': 'Offline Mode', 'botCount': 1},
  ];

  Widget _modeCard(String title, int botCount, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CardGameLauncher(botCount: botCount),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 25),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/UI/modes/mode_${index +1}.png'), // <- Image for background
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.yellowAccent.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.yellowAccent,
                  blurRadius: 12,
                ),
                Shadow(
                  color: Colors.purpleAccent,
                  blurRadius: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
