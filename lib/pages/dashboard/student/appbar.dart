import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;

class StudentNavBar extends StatelessWidget implements PreferredSizeWidget {
  const StudentNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
        // Notification Icon with Badge
        if (user != null)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('notifications')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }
              return IconButton(
                icon: badges.Badge(
                  showBadge: unreadCount > 0,
                  badgeContent: unreadCount > 0
                      ? Text(
                          unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        )
                      : null,
                  child: const Icon(Icons.notifications, color: Colors.white),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.blue,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/notification');
                },
              );
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notification');
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