import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Hezz2FinalGame/Bot/BotStack.dart';
import '../../tools/AudioManager/AudioManager.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});
  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with TickerProviderStateMixin {
  bool _bgOpen = true;
  bool _sfxOpen = false;
  bool _btnOpen = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  Color primaryAccent = Colors.orangeAccent;
  Color secondaryAccent = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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

  void _togglePanel(String key) {
    final audioManager = Provider.of<AudioManager>(context, listen: false);
    audioManager.playEventSound('sandClick');
    setState(() {
      if (key == 'bg') _bgOpen = !_bgOpen;
      if (key == 'sfx') _sfxOpen = !_sfxOpen;
      if (key == 'btn') _btnOpen = !_btnOpen;
    });
  }

  Widget _luxHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      child: Row(
        children: [
          const Text("⚙️ Settings",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: const Text("Hezz2Star v1",
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
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
    required VoidCallback onToggle,
    required bool enabled,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _togglePanel(id),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                Icon(
                  enabled ? Icons.volume_up : Icons.volume_off,
                  size: 18,
                  color: enabled ? accent : Colors.grey,
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: enabled
                          ? accent.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: enabled
                              ? accent.withOpacity(0.6)
                              : Colors.white12),
                    ),
                    child: Text(
                      enabled ? "On" : "Off",
                      style: TextStyle(
                          color: enabled ? Colors.white : Colors.white70,
                          fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: open ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: Colors.white60, size: 20),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: child,
            ),
            crossFadeState:
            open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
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
    required VoidCallback? onTest,
  }) {
    return Row(
      children: [
        Icon(Icons.volume_down, color: enabled ? accent : Colors.grey, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              inactiveTrackColor: Colors.white10,
              thumbColor: accent,
              overlayColor: accent.withOpacity(0.15),
              trackHeight: 4,
              thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 1,
              divisions: 10,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text("${(value * 100).round()}%",
            style: TextStyle(
                color: enabled ? accent : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        const SizedBox(width: 6),
        ScaleTransition(
          scale: _pulseAnim,
          child: InkWell(
            onTap: enabled && onTest != null ? onTest : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: enabled
                    ? accent.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.play_arrow,
                  size: 16, color: enabled ? Colors.white : Colors.white60),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);
    final appVersion = "1.0.0";

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 4),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _luxHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    children: [
                      _buildPanel(
                        id: 'bg',
                        icon: Icons.music_note,
                        title: "Background Music",
                        accent: Colors.deepOrange,
                        open: _bgOpen,
                        enabled: !audioManager.isBgMuted,
                        onToggle: () => setState(() => audioManager.toggleBgMute()),
                        child: _sliderRow(
                          value: audioManager.bgVolume,
                          onChanged: (v) => audioManager.setBgVolume(v),
                          accent: Colors.deepOrange,
                          enabled: !audioManager.isBgMuted,
                          onTest: () => audioManager
                              .playSfx('assets/audios/UI_Audio/BG_Test.mp3'),
                        ),
                      ),
                      _buildPanel(
                        id: 'sfx',
                        icon: Icons.speaker,
                        title: "Sound Effects",
                        accent: Colors.cyanAccent.shade700,
                        open: _sfxOpen,
                        enabled: !audioManager.isSfxMuted,
                        onToggle: () => setState(() => audioManager.toggleSfxMute()),
                        child: _sliderRow(
                          value: audioManager.sfxVolume,
                          onChanged: (v) => audioManager.setSfxVolume(v),
                          accent: Colors.cyanAccent.shade700,
                          enabled: !audioManager.isSfxMuted,
                          onTest: () => audioManager.playSfx(
                              'assets/audios/UI_Audio/SFX_Audio/MarimbaWin_SFX.mp3'),
                        ),
                      ),
                      _buildPanel(
                        id: 'btn',
                        icon: Icons.touch_app,
                        title: "Button Sounds",
                        accent: Colors.lightGreen,
                        open: _btnOpen,
                        enabled: !audioManager.isButtonMuted,
                        onToggle: () => setState(() => audioManager.toggleButtonMute()),
                        child: _sliderRow(
                          value: audioManager.buttonVolume,
                          onChanged: (v) => audioManager.setButtonVolume(v),
                          accent: Colors.lightGreen,
                          enabled: !audioManager.isButtonMuted,
                          onTest: () => audioManager.playSfx(
                              'assets/audios/UI_Audio/SFX_Audio/ClickButton_SFX.mp3'),
                        ),
                      ),

                      _buildPanel(
                        id: 'emoji',
                        icon: Icons.emoji_emotions,
                        title: "Emoji Animations",
                        accent: Colors.purpleAccent,
                        open: false, // no need for expansion since it's just a toggle
                        enabled: isLottieActivated,
                        onToggle: () {
                          setState(() {
                            isLottieActivated = !isLottieActivated;
                          });
                        },
                        child: const SizedBox.shrink(), // no sliders inside
                      ),

                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  audioManager.playEventSound('sandClick');
                                  audioManager.resetAudioSettings();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.refresh,
                                    color: Colors.white70, size: 18),
                                label: const Text("Reset",
                                    style: TextStyle(color: Colors.white70)),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.06),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  audioManager.playEventSound('sandClick');
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                                label: const Text("Close",
                                    style: TextStyle(color: Colors.white)),
                                style: TextButton.styleFrom(
                                  backgroundColor: primaryAccent.withOpacity(0.8),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Center(
                          child: Text(
                            "Version $appVersion",
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )

          ),
        ),
      ),
    );
  }
}
