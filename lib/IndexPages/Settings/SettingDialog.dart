// file: settings_dialog_custom.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../tools/AudioManager/AudioManager.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});
  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with TickerProviderStateMixin {
  // panel states
  bool _bgOpen = true;
  bool _sfxOpen = false;
  bool _btnOpen = false;

  // animations
  late AnimationController _pulseController; // used for Play/Test pulse
  late Animation<double> _pulseAnim;

  // palette (you can tweak to match launcher)
  Color primaryAccent = Colors.orangeAccent;
  Color secondaryAccent = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
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
    audioManager.playEventSound('PopClick');

    setState(() {
      switch (key) {
        case 'bg':
          _bgOpen = !_bgOpen;
          break;
        case 'sfx':
          _sfxOpen = !_sfxOpen;
          break;
        case 'btn':
          _btnOpen = !_btnOpen;
          break;
      }
    });
  }

  Widget _luxHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
          boxShadow: [
            BoxShadow(color: primaryAccent.withOpacity(0.32), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            const Text(
              "⚙️ Settings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                "Hezz v1",
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // custom panel builder
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
          BoxShadow(color: accent.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 8)),
        ]
            : [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 4)),
        ],
        // subtle glass effect
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(open ? 0.04 : 0.02),
            Colors.black.withOpacity(open ? 0.04 : 0.02)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // header row
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              // toggle
              Row(
                children: [
                  // enabled indicator
                  Icon(enabled ? Icons.volume_up : Icons.volume_off, color: enabled ? accent : Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // small pre-play
                      final audioManager = Provider.of<AudioManager>(context, listen: false);
                      audioManager.playEventSound('toggleButton');
                      onToggle();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: enabled ? accent.withOpacity(0.18) : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: enabled ? accent.withOpacity(0.9) : Colors.white10),
                      ),
                      child: Text(enabled ? "On" : "Off",
                          style: TextStyle(color: enabled ? Colors.white : Colors.white70, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // expand/collapse chevron
                  GestureDetector(
                    onTap: () => _togglePanel(id),
                    child: AnimatedRotation(
                      turns: open ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // expanded content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: child,
            ),
            crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 350),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeOutBack,
          ),
        ],
      ),
    );
  }

  // styled slider row
  Widget _sliderRow({
    required double value,
    required ValueChanged<double> onChanged,
    required Color accent,
    required bool enabled,
    required VoidCallback? onTest,
  }) {
    return Row(
      children: [
        Icon(Icons.volume_down, color: enabled ? accent : Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              inactiveTrackColor: Colors.white12,
              thumbColor: accent,
              overlayColor: accent.withOpacity(0.18),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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
        const SizedBox(width: 8),
        Text("${(value * 100).round()}%", style: TextStyle(color: enabled ? accent : Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        // test button
        ScaleTransition(
          scale: _pulseAnim,
          child: InkWell(
            onTap: enabled && onTest != null ? onTest : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: enabled ? accent.withOpacity(0.18) : Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: enabled ? accent.withOpacity(0.9) : Colors.white10),
              ),
              child: Icon(Icons.play_arrow, size: 18, color: enabled ? Colors.white : Colors.white70),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);
    final appVersion = "1.0.0"; // change with PackageInfo if desired

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.78,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
              boxShadow: [BoxShadow(color: primaryAccent.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 12))],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _luxHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                    child: ListView(
                      children: [
                        const SizedBox(height: 6),
                        // Background music panel
                        _buildPanel(
                          id: 'bg',
                          icon: Icons.music_note,
                          title: "Background Music",
                          accent: Colors.deepOrange,
                          open: _bgOpen,
                          enabled: !audioManager.isBgMuted,
                          onToggle: () => setState(() => audioManager.toggleBgMute()),
                          child: Column(
                            children: [
                              _sliderRow(
                                value: audioManager.bgVolume,
                                onChanged: (v) => audioManager.setBgVolume(v),
                                accent: Colors.deepOrange,
                                enabled: !audioManager.isBgMuted,
                                onTest: () => audioManager.playSfx('assets/audios/UI_Audio/BG_Test.mp3'),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        audioManager.playEventSound("cancelButton");
                                        audioManager.setBgVolume(0.5);
                                      },
                                      icon: const Icon(Icons.settings_backup_restore),
                                      label: const Text("Reset BG"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white12,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // SFX panel
                        _buildPanel(
                          id: 'sfx',
                          icon: Icons.speaker,
                          title: "Sound Effects",
                          accent: Colors.cyanAccent.shade700,
                          open: _sfxOpen,
                          enabled: !audioManager.isSfxMuted,
                          onToggle: () => setState(() => audioManager.toggleSfxMute()),
                          child: Column(
                            children: [
                              _sliderRow(
                                value: audioManager.sfxVolume,
                                onChanged: (v) => audioManager.setSfxVolume(v),
                                accent: Colors.cyanAccent.shade700,
                                enabled: !audioManager.isSfxMuted,
                                onTest: () => audioManager.playSfx('assets/audios/UI_Audio/SFX_Audio/MarimbaWin_SFX.mp3'),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        audioManager.playEventSound("clickButton2");
                                        audioManager.setSfxVolume(0.8);
                                      },
                                      icon: const Icon(Icons.volume_up),
                                      label: const Text("Boost SFX"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white12,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // quick play sample
                                  GestureDetector(
                                    onTap: () => audioManager.playSfx('assets/audios/UI_Audio/SFX_Audio/MarimbaWin_SFX.mp3'),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: const Icon(Icons.music_note, color: Colors.white70),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Button Sounds panel
                        _buildPanel(
                          id: 'btn',
                          icon: Icons.touch_app,
                          title: "Button Sounds",
                          accent: Colors.lightGreen,
                          open: _btnOpen,
                          enabled: !audioManager.isButtonMuted,
                          onToggle: () => setState(() => audioManager.toggleButtonMute()),
                          child: Column(
                            children: [
                              _sliderRow(
                                value: audioManager.buttonVolume,
                                onChanged: (v) => audioManager.setButtonVolume(v),
                                accent: Colors.lightGreen,
                                enabled: !audioManager.isButtonMuted,
                                onTest: () => audioManager.playSfx('assets/audios/UI_Audio/SFX_Audio/ClickButton_SFX.mp3'),
                              ),
                              const SizedBox(height: 8),
                              const Text("Toggle button sounds for UI interactions.",
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Reset & Close row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    audioManager.playEventSound('cancelButton');
                                    audioManager.resetAudioSettings();
                                    setState(() {}); // refresh UI values
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Reset Audio Settings"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  audioManager.playEventSound('cancelButton');
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(colors: [primaryAccent, secondaryAccent]),
                                    boxShadow: [BoxShadow(color: primaryAccent.withOpacity(0.28), blurRadius: 8, offset: const Offset(0, 6))],
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.close, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(child: Text("Version $appVersion", style: const TextStyle(color: Colors.white54))),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
