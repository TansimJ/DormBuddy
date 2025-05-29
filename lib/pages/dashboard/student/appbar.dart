import 'package:flutter/material.dart';

class StudentNavBar extends StatelessWidget implements PreferredSizeWidget {
  const StudentNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white), // makes back button white
      backgroundColor: const Color(0xFF800000),
      elevation: 0.0,
      centerTitle: false, // Align title to the left

      title: Row(
        mainAxisAlignment: MainAxisAlignment.start, // align left
        children: [
          Image.asset(
            'lib/assets/logo.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 10),
          const Text(
            'DormBuddy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            // Handle notification button press here later
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
