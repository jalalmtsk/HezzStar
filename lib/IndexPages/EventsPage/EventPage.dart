import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  bool _isLoading = false;

  void _showLoading() {
    setState(() {
      _isLoading = true;
    });

    // Hide after 1.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Lottie.asset(
                      "assets/animations/AnimationSFX/LoadingMotion.json",
                      width: 200,
                      height: 200,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "No Available Events",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.yellow.withOpacity(0.8),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Check back later for upcoming \ntournaments and exclusive challenges!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _showLoading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      "Refresh",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54, // dim background
              child: Center(
                child: Lottie.asset(
                  "assets/animations/AnimationSFX/HezzFinal.json",
                  width: 200,
                  height: 200,
                  repeat: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
