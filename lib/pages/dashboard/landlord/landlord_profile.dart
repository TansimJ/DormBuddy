import 'package:flutter/material.dart';
import 'landlord_appbar.dart';
import 'landlord_bottombar.dart';

class LandlordProfilePage extends StatefulWidget {
  const LandlordProfilePage({super.key});

  @override
  State<LandlordProfilePage> createState() => _LandlordProfilePageState();
}

class _LandlordProfilePageState extends State<LandlordProfilePage> {
  int _currentIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Navigation logic same as dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LandlordAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF800000),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Landlord Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('landlord@example.com'),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFF800000)),
              title: const Text('+1 (123) 456-7890'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF800000)),
              title: const Text('123 Main St, Cityville'),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {},
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: LandlordBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
