import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDialogHezz2Star extends StatefulWidget {
  const AboutDialogHezz2Star({super.key});

  @override
  State<AboutDialogHezz2Star> createState() => _AboutDialogHezz2StarState();
}

class _AboutDialogHezz2StarState extends State<AboutDialogHezz2Star> {
  String appVersion = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "${info.version} (Build ${info.buildNumber})";
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.facebookF, color: Colors.blue),
          onPressed: () => _launchURL("https://facebook.com/hezz2star"),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.purple),
          onPressed: () => _launchURL("https://instagram.com/hezz2star"),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.tiktok, color: Colors.black),
          onPressed: () => _launchURL("https://tiktok.com/hezz2star"),
        ),
      ],
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
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: const Text(
              "About Hezz2Star",
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: const AssetImage("assets/ImpoImages/Hezz2Star_Logo.png"),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Hezz2Star",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Version $appVersion",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    "Our Mission",
                    "To bring the excitement of traditional Moroccan card games to mobile platforms with engaging visuals and gamified experiences.",
                    Icons.flag,
                    Colors.deepPurple,
                  ),
                  _buildSection(
                    "Future Plans",
                    "We plan to add multiplayer tournaments, new cards and themes, and interactive leaderboards to enhance the gaming experience.",
                    Icons.upcoming,
                    Colors.deepPurpleAccent,
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    "Follow us on Social Media",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildSocialRow(),

                  const SizedBox(height: 16),
                  const Text(
                    "Contact: support@hezz2star.com",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "© ${DateTime.now().year} Hezz2Star. All rights reserved.",
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }
}
