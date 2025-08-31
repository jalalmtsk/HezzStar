import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../tools/AudioManager/AudioManager.dart';
import 'Tools/CardGridWidget.dart';


class MainCardShopPage extends StatefulWidget {
  const MainCardShopPage({super.key});

  @override
  State<MainCardShopPage> createState() => _MainCardShopPageState();
}

class _MainCardShopPageState extends State<MainCardShopPage> {
  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme.copyWith(
      primary: const Color(0xFFFF6F3C),
      primaryContainer: const Color(0xFFFFA65C),
      surface: Colors.white,
    );

    // Example cards data
    final List<Map<String, dynamic>> cardData = [
      {"image": "assets/images/Skins/BackCard_Skins/MythCard1.jpg", "cost": 10},
      {"image": "assets/images/Skins/BackCard_Skins/MythCard2.jpg", "cost": 20},
      {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal1.jpg", "cost": 50},
      {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal2.jpg", "cost": 100},
      {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Crystal3.jpg", "cost": 150},
      {"image": "assets/images/Skins/BackCard_Skins/Fantasy/Drag1.jpg", "cost": 200},
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                children: [
                  _circularButton(
                    icon: Icons.arrow_back,
                    onTap: () {
                      audioManager.playEventSound("cancelButton");
                      Navigator.pop(context);
                    },
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: Text("Cards Shop",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20))),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Card grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CardGridWidget(imageCards: cardData),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularButton(
      {required IconData icon,
        required VoidCallback onTap,
        required Color color}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 24, color: color),
        ),
      ),
    );
  }
}
