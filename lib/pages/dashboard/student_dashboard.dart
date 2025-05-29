import 'package:flutter/material.dart';
import './student/appbar.dart';
import './student/bottombar.dart';
import 'student/communityforum.dart';
import './student/searchpage.dart';
import './student/profile.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  // Dashboard Home Page (Search tab)
  Widget _buildHomePage() {
    final recentProperties = [
      {
        "name": "Sunny Apartment",
        "address": "123 College St, Apt 1",
        "price": 400,
        "gender": "Any",
        "dormType": "Studio",
        "description": "A sunny and quiet place perfect for students.",
        "postedBy": "Alice",
        "ownerDescription": "Helpful and responsive landlord."
      },
      {
        "name": "Cassie Complex",
        "address": "456 College St, Apt 4",
        "price": 450,
        "gender": "Women",
        "dormType": "Shared",
        "description": "Close to college and local stores.",
        "postedBy": "Cassie",
        "ownerDescription": "Available to assist tenants anytime."
      },
      {
        "name": "Ling Gan Studio",
        "address": "Linggangguli 1, Apt 3",
        "price": 500,
        "gender": "Men",
        "dormType": "Studio",
        "description": "Modern amenities with peaceful environment.",
        "postedBy": "Mr. Gan",
        "ownerDescription": "Long-time property owner with good reviews."
      },
      {
        "name": "Windy Apartment",
        "address": "123 Ogga booga St, Apt 1",
        "price": 350,
        "gender": "Any",
        "dormType": "Studio",
        "description": "Cool and breezy spot near campus.",
        "postedBy": "Jane",
        "ownerDescription": "Friendly host with fast response rate."
      },
    ];

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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentProperties.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final property = recentProperties[index];
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
                                //adding an image
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'lib/assets/images/property_outside.jpg', 
                                  fit: BoxFit.cover,
                                ),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          property['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          property['address'] as String,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          "RM${property['price']}/month",
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
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<Widget> get _pages => [
        _buildHomePage(),
        const CommunityForum(),
        const Placeholder(),
        const Placeholder(),
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
