import 'package:flutter/material.dart';

class LandlordAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LandlordAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/logo.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 10),
          const Text('DormBuddy'),
        ],
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: const Color(0xFF800000),
      elevation: 0.0,
      centerTitle: true,
      leading: null,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            // Handle notification
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}