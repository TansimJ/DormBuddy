import 'package:flutter/material.dart';

class LandlordBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LandlordBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);
        switch (index) {
          case 0:
            if (ModalRoute.of(context)?.settings.name != '/landlord_dashboard') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/landlord_dashboard',
                (route) => false,
              );
            }
            break;
          case 1:
            if (ModalRoute.of(context)?.settings.name != '/add_dorm') {
              Navigator.pushNamed(
                context,
                '/add_dorm',
              );
            }
            break;
          case 2:
            if (ModalRoute.of(context)?.settings.name != '/landlord_chat') {
              Navigator.pushNamed(
                context,
                '/landlord_chat',
              );
            }
            break;
          case 3:
            if (ModalRoute.of(context)?.settings.name != '/landlord_profile') {
              Navigator.pushNamed(
                context,
                '/landlord_profile',
              );
            }
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF800000), // maroon
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}