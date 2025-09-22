import 'package:flutter/material.dart';
import 'package:hezzstar/ExperieneManager.dart';

class ProfileAvatar extends StatelessWidget {
  final ExperienceManager xpManager;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.xpManager,
    this.radius = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: radius * 5,
        width: radius * 4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background photo icon
            Image.asset(
              "assets/UI/Icons/AvatarProfile_Icon.png",
              height: radius * 5,
              width: radius * 4,
              fit: BoxFit.contain,
            ),

            // Username BEHIND avatar
            Positioned(
              bottom: 0,
              child: Text(
                xpManager.userProfile.username ?? "Player Name",
                style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.85),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // Avatar in FRONT
            CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey.withValues(alpha: 0.8),
              backgroundImage: xpManager.selectedAvatar != null
                  ? AssetImage(xpManager.selectedAvatar!)
                  : const AssetImage("assets/images/Skins/AvatarSkins/DefaultUser.png"),
            ),
          ],
        ),
      ),
    );
  }
}
