import 'package:flutter/material.dart';

import '../screens/profile_screen.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText; // Optional: jika ingin ganti title selain logo
  final bool showProfileIcon; // Untuk hide/show ikon profile di screen tertentu
  final VoidCallback? onProfileTap; // Callback untuk navigasi ke profile

  const CustomHeader({
    super.key,
    this.titleText,
    this.showProfileIcon = true,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleText != null
          ? Text(
        titleText!,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      )
          : Image.asset(
        'assets/logo_wag_white.png',
        width: 48,
        height: 48,
      ),
      backgroundColor: const Color(0xFFB3282D),
      foregroundColor: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      actions: showProfileIcon
          ? [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: onProfileTap ??
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
        ),
      ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}