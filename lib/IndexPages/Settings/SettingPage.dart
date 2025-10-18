// file: settings_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hezzstar/Hezz2FinalGame/Tools/Dialog/InstructionDialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../ExperieneManager.dart';
import '../../main.dart';
import '../../tools/AudioManager/AudioManager.dart';
import '../../widgets/AboutAndSupportPages/AboutApp/AboutApp.dart';
import '../../widgets/AboutAndSupportPages/Credits/CreditPage.dart';
import '../../widgets/AboutAndSupportPages/PrivacyPolicy/PrivacyPolicy.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {

  String selectedLanguage = "Francais"; // Default language

  bool darkMode = false;
  bool notificationsOn = true;
  String username = "Player";
  String appVersion = "Loading...";

  bool _generalOpen = true;
  bool _bgOpen = false;
  bool _sfxOpen = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  Color primaryAccent = Colors.orangeAccent;
  Color secondaryAccent = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _loadSavedLanguage(); // 👈 add this

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  void _loadSavedLanguage() {
    final exp = Provider.of<ExperienceManager>(context, listen: false);
    final savedCode = exp.preferredLanguage; // your saved lang code
    setState(() {
      selectedLanguage = _mapCodeToLang(savedCode);
    });
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "${info.version} (build ${info.buildNumber})";
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePanel(String key) {
    setState(() {
      switch (key) {
        case 'general':
          _generalOpen = !_generalOpen;
          break;
        case 'bg':
          _bgOpen = !_bgOpen;
          break;
        case 'sfx':
          _sfxOpen = !_sfxOpen;
          break;
      }
    });
  }

  Widget _luxHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
          boxShadow: [
            BoxShadow(
              color: primaryAccent.withOpacity(0.32),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
             Text(
              "⚙️ ${tr(context).settings}",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                appVersion,
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel({
    required String id,
    required IconData icon,
    required String title,
    required Color accent,
    required bool open,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: open ? accent.withOpacity(0.75) : Colors.white12,
          width: open ? 2.2 : 1.0,
        ),
        boxShadow: open
            ? [
          BoxShadow(
            color: accent.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: accent.withAlpha(40),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              GestureDetector(
                onTap: () => _togglePanel(id),
                child: AnimatedRotation(
                  turns: open ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white70),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: child,
            ),
            crossFadeState:
            open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 350),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow({
    required double value,
    required ValueChanged<double> onChanged,
    required Color accent,
    required bool enabled,
    required VoidCallback onToggleMute,
    required bool isMuted,
  }) {
    return Row(
      children: [
        Icon(Icons.volume_down, color: enabled ? accent : Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 10,
            onChanged: enabled ? onChanged : null,
            activeColor: accent,
            inactiveColor: Colors.white12,
          ),
        ),
        const SizedBox(width: 8),
        Text("${(value * 100).round()}%",
            style: TextStyle(
                color: enabled ? accent : Colors.grey,
                fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        ScaleTransition(
          scale: _pulseAnim,
          child: InkWell(
            onTap: onToggleMute,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/UI/BackgroundImage/bg2.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.6))),
          SafeArea(
            child: Column(
              children: [
                _luxHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      // General Panel
                      _buildPanel(
                        id: "general",
                        icon: Icons.settings,
                        title: tr(context).general,
                        accent: Colors.amber,
                        open: _generalOpen,
                        child: Column(
                          children: [

                            ListTile(
                              leading:
                              const Icon(Icons.language, color: Colors.white),
                              title:  Text(tr(context).language, style: TextStyle(color: Colors.white)),
                              trailing: Text(
                                selectedLanguage,
                                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                              onTap: () async {
                                final chosenLang = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title:  Text(tr(context).selectLanguage),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _langOption(context, "English", "en", "🇺🇸"),
                                          _langOption(context, "العربية", "ar", "🇸🇦"),
                                          _langOption(context, "ⵜⴰⵎⴰⵣⵉⵖⵜ", "zgh", "🇲🇦"),
                                          _langOption(context, "Français", "fr", "🇫🇷"),
                                          _langOption(context, "Español", "es", "🇪🇸"),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                if (chosenLang != null) {
                                  setState(() => selectedLanguage = chosenLang);

                                  // Save language to ExperienceManager
                                  Provider.of<ExperienceManager>(context, listen: false)
                                      .setPreferredLanguage(_mapLangToCode(chosenLang));
                                }
                              },
                            ),

                            ListTile(
                              leading:
                              const Icon(Icons.insights, color: Colors.white),
                              title:  Text(tr(context).instructions,
                                  style: TextStyle(color: Colors.white)),
                              subtitle: Text(tr(context).gameInstructions,
                                  style:
                                  const TextStyle(color: Colors.white70)),
                              onTap: () {
                                // TODO: Show about dialog
                                showDialog(
                                  context: context,
                                  builder: (_) => const InstructionsDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Background Music
                      _buildPanel(
                        id: "bg",
                        icon: Icons.music_note,
                        title: tr(context).backgroundMusic,
                        accent: Colors.deepOrange,
                        open: _bgOpen,
                        child: _sliderRow(
                          value: audioManager.bgVolume,
                          onChanged: (v) => audioManager.setBgVolume(v),
                          accent: Colors.deepOrange,
                          enabled: true,
                          onToggleMute: () async {
                            await audioManager.toggleBgMute();
                            setState(() {}); // refresh UI
                          },
                          isMuted: audioManager.isBgMuted,
                        ),
                      ),

                      // SFX
                      _buildPanel(
                        id: "sfx",
                        icon: Icons.speaker,
                        title: tr(context).soundEffects,
                        accent: Colors.cyan,
                        open: _sfxOpen,
                        child: _sliderRow(
                          value: audioManager.sfxVolume,
                          onChanged: (v) => audioManager.setSfxVolume(v),
                          accent: Colors.cyan,
                          enabled: true,
                          onToggleMute: () async {
                            await audioManager.toggleSfxMute();
                            setState(() {}); // refresh UI
                          },

                          isMuted: audioManager.isSfxMuted,
                        ),
                      ),

                      // About Section
                      _buildPanel(
                        id: "about",
                        icon: Icons.info_outline,
                        title: tr(context).aboutAndSupport,
                        accent: Colors.blue,
                        open: true,
                        child: Column(
                          children: [
                            ListTile(
                              leading:
                              const Icon(Icons.info, color: Colors.blue),
                              title:  Text(tr(context).aboutApp,
                                  style: TextStyle(color: Colors.white)),
                              subtitle: Text(appVersion,
                                  style:
                                  const TextStyle(color: Colors.white70)),
                              onTap: () {
                                // TODO: Show about dialog
                                showDialog(
                                  context: context,
                                  builder: (_) => const AboutDialogHezz2Star(),
                                );
                              },
                            ),


                            ListTile(
                              leading: const Icon(Icons.email,
                                  color: Colors.deepPurple),
                              title:  Text(tr(context).contactSupport,
                                  style: TextStyle(color: Colors.white)),
                              onTap: () {
                                // TODO: Open email launcher
                                debugPrint("Contact Support tapped");
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.privacy_tip_outlined,
                                  color: Colors.amber),
                              title:  Text(tr(context).privacyPolicy,
                                  style: TextStyle(color: Colors.white)),
                              onTap: () {
                                // TODO: Navigate to Privacy Policy
                                showDialog(
                                  context: context,
                                  builder: (_) => const PrivacyPolicyDialog(),
                                );
                              },
                            ),
                            ListTile(
                              leading:
                              const Icon(Icons.gavel, color: Colors.amber),
                              title:  Text(tr(context).credits,
                                  style: TextStyle(color: Colors.white)),
                              onTap: () {
                                // TODO: Navigate to Terms of Use
                                showDialog(
                                  context: context,
                                  builder: (_) => const CreditsDialog(),
                                );
                              },
                            ),
                            ListTile(
                              leading:
                              const Icon(Icons.star_rate, color: Colors.amber),
                              title:  Text(tr(context).rateApp,
                                  style: TextStyle(color: Colors.white)),
                              onTap: () {
                                // TODO: Open app store rating
                                debugPrint("Rate App tapped");
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langOption(BuildContext context, String label, String code, String flag) {
    final isSelected = selectedLanguage == label;

    return InkWell(
      onTap: () => Navigator.pop(context, label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.amber.shade700 : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 22),
          ],
        ),
      ),
    );
  }




  String _mapCodeToLang(String code) {
    switch (code) {
      case "en":
        return "English";
      case "ar":
        return "العربية";
      case "zgh":
        return "ⵜⴰⵎⴰⵣⵉⵖⵜ";
      case "fr":
        return "Français";
      case "es":
        return "Español";
      default:
        return "English";
    }
  }


  String _mapLangToCode(String lang) {
    switch (lang) {
      case "English":
        return "en";
      case "العربية":
        return "ar";
      case "ⵜⴰⵎⴰⵣⵉⵖⵜ":
        return "zgh";
      case "Français":
        return "fr";
      case "Español":
        return "es";
      default:
        return "en";
    }
  }

}
