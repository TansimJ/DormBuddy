import 'package:flutter/material.dart';
import 'appbar.dart';
import 'bottombar.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  int _currentIndex = 3;

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 1:
      case 2:
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This page is not available yet.'),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF800000),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Student Name',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'student@example.com',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Card with info
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.phone, color: Color(0xFF800000)),
                      SizedBox(width: 16),
                      Text('+1 (123) 456-7890'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Color(0xFF800000)),
                      SizedBox(width: 16),
                      Expanded(child: Text('123 Main St, Cityville')),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: const [
                      Icon(Icons.comment, color: Color(0xFF800000)),
                      SizedBox(width: 16),
                      Expanded(child: Text('Looking for a room near campus. I am from the MJIIT faculty')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Edit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, 'edit_student'); // Navigate to edit profile page
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


}