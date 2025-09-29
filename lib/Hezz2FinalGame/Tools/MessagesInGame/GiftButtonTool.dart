import 'package:flutter/material.dart';

class EmojiDialogButton extends StatelessWidget {
  final Function(String) onEmojiSelected;

  const EmojiDialogButton({super.key, required this.onEmojiSelected});

  void _showEmojiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black87,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose an Emoji",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['😀', '😍', '🎉', '😢', '😡'].map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        onEmojiSelected(emoji); // pass the selected emoji
                        Navigator.of(context).pop(); // close dialog
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showEmojiDialog(context),
      child: const Text("Open Emoji Dialog"),
    );
  }
}
