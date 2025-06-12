import 'package:dorm_buddy/pages/dashboard/student/viewproperty.dart';
import 'package:flutter/material.dart';
import './student/appbar.dart';
import './student/bottombar.dart';
import './student/searchpage.dart';
import './student/profile.dart';
import './student/viewproperty.dart';
import './student/chat.dart';
import '../community_forum/presentation/mainforum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  // Dashboard Home Page (Search tab)
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, User!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Looking for a place? Start here!'),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            child: AbsorbPointer(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Search for an apartment...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Recently Published:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('dorms').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No properties found.');
              }
              final properties = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              }).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: properties.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final property = properties[index];
                  // Use the first image if available, else a placeholder
                  final List images = (property['images'] is List) ? property['images'] : [];
                  final String? imageUrl = (images.isNotEmpty && images[0] != null && images[0].toString().isNotEmpty)
                      ? images[0]
                      : null;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPage(property: property),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset('lib/assets/images/property_outside.jpg', fit: BoxFit.cover);
                                        },
                                      )
                                    : Image.asset('lib/assets/images/property_outside.jpg', fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              property['dormitory_name'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              property['address_line'] ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              "RM${property['monthly_rate_(rm)'] ?? '-'} /month",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<Widget> get _pages => [
        _buildHomePage(),
        ForumPage(),
        const ChatPage(),
        
        const StudentProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentNavBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: Bottombar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
