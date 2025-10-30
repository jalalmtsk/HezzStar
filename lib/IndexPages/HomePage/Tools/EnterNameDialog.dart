import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:hezzstar/ExperieneManager.dart';

class EnterNameDialog extends StatefulWidget {
  final ExperienceManager xpManager;
  const EnterNameDialog({super.key, required this.xpManager});

  @override
  State<EnterNameDialog> createState() => _EnterNameDialogState();

  /// Helper to show it easily from anywhere
  static Future<void> show(BuildContext context, ExperienceManager xpManager) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EnterNameDialog(xpManager: xpManager),
    );
  }
}

class _EnterNameDialogState extends State<EnterNameDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: [
                Colors.greenAccent.withOpacity(0.15),
                Colors.black.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.lightGreenAccent.withOpacity(0.7), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✨ Lottie Animation
              Lottie.asset(
                "assets/animations/AnimatGamification/NameEntry.json",
                height: 110,
                repeat: true,
              ),
              const SizedBox(height: 12),

              const Text(
                "Welcome, Champion!",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.lightGreenAccent, blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                "Enter your player name to begin your journey",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // 🎮 Name Input
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                maxLength: 15,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.black54,
                  hintText: "Your Name",
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                        color: Colors.lightGreenAccent, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.green, width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 🚀 Confirm Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withOpacity(0.9),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _confirmName,
                child: const Text(
                  "Start Adventure",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.xpManager.userProfile.username = name;
      Navigator.pop(context);
    }
  }
}
