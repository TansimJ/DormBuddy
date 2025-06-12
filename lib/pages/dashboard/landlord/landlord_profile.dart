import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String? name;
  String? email;
  String? phone;
  String? address;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    setState(() {
      name = data?['name'] ?? '';
      email = data?['email'] ?? '';
      phone = data?['phone'] ?? '';
      address = data?['address'] ?? '';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LandlordAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF800000),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name ?? 'Landlord Name',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(email ?? 'landlord@example.com'),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Color(0xFF800000)),
                    title: Text(
                      (phone == null || phone!.isEmpty) ? 'Insert phone number' : phone!,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Color(0xFF800000)),
                    title: Text(
                      (address == null || address!.isEmpty) ? 'Insert address' : address!,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'edit_landlord');
                    },
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
