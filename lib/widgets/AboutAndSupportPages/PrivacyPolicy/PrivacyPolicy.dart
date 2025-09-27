import 'package:flutter/material.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  Widget _buildSection(String title, String content, IconData icon, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: const Text(
        "© 2025 Hezz2Star. All rights reserved.",
        style: TextStyle(color: Colors.grey, fontSize: 11),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dialog title bar
          Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: const Text(
              "Privacy Policy",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    "Data Collection",
                    "We only collect information necessary to improve your app experience. This may include your app usage patterns, preferences, and settings.",
                    Icons.storage,
                    [Colors.blue, Colors.lightBlueAccent],
                  ),
                  _buildSection(
                    "Data Usage",
                    "Your data is used to enhance app functionality, personalize content, and ensure the best performance. We do not sell your data to third parties.",
                    Icons.verified_user,
                    [Colors.green, Colors.lightGreen],
                  ),
                  _buildSection(
                    "Third-Party Services",
                    "Some features may use trusted third-party services (like analytics or ads). These services follow their own privacy policies.",
                    Icons.handshake,
                    [Colors.orange, Colors.deepOrangeAccent],
                  ),
                  _buildSection(
                    "Your Rights",
                    "You have the right to request data deletion, access stored data, and opt out of optional tracking features.",
                    Icons.security,
                    [Colors.purple, Colors.deepPurpleAccent],
                  ),
                  const SizedBox(height: 20),
                  _buildFooter(),
                ],
              ),
            ),
          ),

          // Close button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.deepOrange)),
          ),
        ],
      ),
    );
  }
}
