import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../tools/AudioManager/AudioManager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  bool darkMode = false;
  bool notificationsOn = true;
  String username = "Player";
  String appVersion = "Loading...";
  bool parentalLockEnabled = false;
  String parentalPin = '';
  int screenTimeLimitMinutes = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
      notificationsOn = prefs.getBool('notificationsOn') ?? true;
      username = prefs.getString('username') ?? 'Player';
      parentalLockEnabled = prefs.getBool('parentalLockEnabled') ?? false;
      parentalPin = prefs.getString('parentalPin') ?? '';
      screenTimeLimitMinutes = prefs.getInt('screenTimeLimitMinutes') ?? 0;
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "${info.version} (build ${info.buildNumber})";
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open link.")),
      );
    }
  }

  Future<void> _setParentalPin() async {
    final pin = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: parentalPin);
        return AlertDialog(
          title: const Text("Set Parental PIN"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter PIN"),
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () => Navigator.pop(context, controller.text),
            ),
          ],
        );
      },
    );
    if (pin != null && pin.isNotEmpty) {
      setState(() {
        parentalPin = pin;
        parentalLockEnabled = true;
      });
      await _savePref('parentalPin', pin);
      await _savePref('parentalLockEnabled', true);
    }
  }

  Future<void> _setScreenTimeLimit() async {
    final input = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(
          text: screenTimeLimitMinutes == 0 ? '' : screenTimeLimitMinutes.toString(),
        );
        return AlertDialog(
          title: const Text("Set Screen Limit"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter Minutes"),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () => Navigator.pop(context, controller.text),
            ),
          ],
        );
      },
    );

    if (input != null) {
      final minutes = int.tryParse(input) ?? 0;
      setState(() => screenTimeLimitMinutes = minutes);
      await _savePref('screenTimeLimitMinutes', minutes);
    }
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _glassTile({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Moroccan bg
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
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionHeader("General", Icons.settings, Colors.amber),
                _glassTile(
                  child: SwitchListTile(
                    title: const Text("Dark Mode", style: TextStyle(color: Colors.white)),
                    value: darkMode,
                    onChanged: (val) {
                      setState(() => darkMode = val);
                      _savePref('darkMode', val);
                    },
                    activeColor: Colors.amber,
                  ),
                ),
                _glassTile(
                  child: SwitchListTile(
                    title: const Text("Notifications", style: TextStyle(color: Colors.white)),
                    value: notificationsOn,
                    onChanged: (val) {
                      setState(() => notificationsOn = val);
                      _savePref('notificationsOn', val);
                    },
                    activeColor: Colors.amber,
                  ),
                ),
                _glassTile(
                  child: ListTile(
                    title: Text("Username: $username", style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () async {
                        final name = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final controller = TextEditingController(text: username);
                            return AlertDialog(
                              title: const Text("Change Name"),
                              content: TextField(controller: controller),
                              actions: [
                                TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
                                TextButton(child: const Text("Save"), onPressed: () => Navigator.pop(context, controller.text)),
                              ],
                            );
                          },
                        );
                        if (name != null) {
                          setState(() => username = name);
                          _savePref('username', name);
                        }
                      },
                    ),
                  ),
                ),

                _sectionHeader("Audio", Icons.music_note, Colors.deepOrange),
                _glassTile(
                  child: ListTile(
                    leading: const Icon(Icons.music_note, color: Colors.amber),
                    title: const Text("Background Music", style: TextStyle(color: Colors.white)),
                    subtitle: Slider(
                      value: audioManager.bgVolume,
                      onChanged: (v) {
                        audioManager.setBgVolume(v);
                        _savePref('musicVolume', v);
                      },
                      min: 0,
                      max: 1,
                    ),
                    trailing: IconButton(
                      icon: Icon(audioManager.isBgMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                      onPressed: audioManager.toggleBgMute,
                    ),
                  ),
                ),
                _glassTile(
                  child: ListTile(
                    leading: const Icon(Icons.speaker, color: Colors.cyan),
                    title: const Text("SFX", style: TextStyle(color: Colors.white)),
                    subtitle: Slider(
                      value: audioManager.sfxVolume,
                      onChanged: (v) => audioManager.setSfxVolume(v),
                      min: 0,
                      max: 1,
                    ),
                    trailing: ScaleTransition(
                      scale: _pulseAnim,
                      child: IconButton(
                        icon: Icon(audioManager.isSfxMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                        onPressed: audioManager.toggleSfxMute,
                      ),
                    ),
                  ),
                ),

                _sectionHeader("Security", Icons.lock, Colors.redAccent),
                _glassTile(
                  child: SwitchListTile(
                    title: const Text("Parental Lock", style: TextStyle(color: Colors.white)),
                    value: parentalLockEnabled,
                    onChanged: (val) async {
                      if (val) {
                        await _setParentalPin();
                      } else {
                        setState(() {
                          parentalLockEnabled = false;
                          parentalPin = '';
                        });
                        _savePref('parentalLockEnabled', false);
                        _savePref('parentalPin', '');
                      }
                    },
                    activeColor: Colors.redAccent,
                  ),
                ),
                _glassTile(
                  child: ListTile(
                    title: const Text("Screen Time Limit", style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      screenTimeLimitMinutes == 0 ? "No limit" : "$screenTimeLimitMinutes minutes",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: TextButton(
                      child: const Text("Set", style: TextStyle(color: Colors.amber)),
                      onPressed: _setScreenTimeLimit,
                    ),
                  ),
                ),

                _sectionHeader("About & Support", Icons.info, Colors.blue),
                _glassTile(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.blueGrey),
                    title: const Text("About App", style: TextStyle(color: Colors.white)),
                    subtitle: Text(appVersion, style: const TextStyle(color: Colors.white70)),
                  ),
                ),
                _glassTile(
                  child: ListTile(
                    leading: const Icon(Icons.email, color: Colors.deepPurple),
                    title: const Text("Contact Support", style: TextStyle(color: Colors.white)),
                    onTap: () => _launchURL("mailto:support@example.com"),
                  ),
                ),
                _glassTile(
                  child: ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: Colors.amber),
                    title: const Text("Privacy Policy", style: TextStyle(color: Colors.white)),
                    onTap: () => _launchURL("https://example.com/privacy"),
                  ),
                ),
                _glassTile(
                  child: ListTile(
                    leading: const Icon(Icons.gavel, color: Colors.amber),
                    title: const Text("Terms of Use", style: TextStyle(color: Colors.white)),
                    onTap: () => _launchURL("https://example.com/terms"),
                  ),
                ),
                _glassTile(
                  child: ListTile(
                    leading: const Icon(Icons.star_rate, color: Colors.amber),
                    title: const Text("Rate App", style: TextStyle(color: Colors.white)),
                    onTap: () => _launchURL("https://play.google.com/store/apps/details?id=com.example.mortaalim"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
