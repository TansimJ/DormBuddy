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
    final themeColor = const Color(0xFF800000);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: const LandlordAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    margin: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: themeColor.withOpacity(0.13),
                            child: const Icon(Icons.person, size: 56, color: Color(0xFF800000)),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            name ?? 'Landlord Name',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email ?? 'landlord@example.com',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          Divider(color: themeColor.withOpacity(0.13), thickness: 1.1),
                          const SizedBox(height: 12),
                          _profileDetail(
                            icon: Icons.phone,
                            label: (phone == null || phone!.isEmpty) ? 'Insert phone number' : phone!,
                            themeColor: themeColor,
                          ),
                          const SizedBox(height: 8),
                          _profileDetail(
                            icon: Icons.location_on,
                            label: (address == null || address!.isEmpty) ? 'Insert address' : address!,
                            themeColor: themeColor,
                          ),
                          const SizedBox(height: 34),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, 'edit_landlord');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: LandlordBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _profileDetail({required IconData icon, required String label, required Color themeColor}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.12)),
      ),
      child: ListTile(
        leading: Icon(icon, color: themeColor, size: 28),
        title: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}