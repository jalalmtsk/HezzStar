import 'package:flutter/material.dart';
import 'package:hezzstar/Hezz2FinalGame/Screen/GameLauncher/CardGameLauncher.dart';
import 'package:hezzstar/tools/AudioManager/AudioManager.dart';
import 'package:hezzstar/widgets/userStatut/userStatus.dart';
import 'package:provider/provider.dart';

import 'ExperieneManager.dart';
import 'MainScreenIndex.dart';

void main() {

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExperienceManager()),
          ChangeNotifierProvider(create: (_) => AudioManager()),
        ],
          child : ParchiStarNextLevel())
      );
}

class ParchiStarNextLevel extends StatelessWidget {
  const ParchiStarNextLevel({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}


class MyApp extends StatelessWidget{
  Widget build(BuildContext context){
    return Placeholder();
  }
}

// Placeholder Pages
class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Friends Page', style: TextStyle(fontSize: 24)));
  }
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Events Page', style: TextStyle(fontSize: 24)));
  }
}

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Collections Page', style: TextStyle(fontSize: 24)));
  }
}
