import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'CreditData.dart';

class CreditsDialog extends StatelessWidget {
  const CreditsDialog({super.key});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildCreditCard(CreditItem credit, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    credit.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text("🎼 ${credit.artist}", style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _launchURL(credit.licenseUrl),
              child: Text(
                credit.license,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon, List<Color> colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
      insetPadding: const EdgeInsets.symmetric(vertical: 150, horizontal: 20),
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
              "Credits",
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
                children: [
                  _buildHeader("Sfx Music", Icons.music_note, [Colors.orange, Colors.orangeAccent]),
                  const SizedBox(height: 8),
                  ...sfxCredits.map((credit) => _buildCreditCard(credit, Icons.music_note, Colors.deepOrange)),
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
