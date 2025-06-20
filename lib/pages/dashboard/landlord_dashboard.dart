import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'landlord/landlord_appbar.dart';
import 'landlord/landlord_bottombar.dart';
import 'landlord/add_dorm.dart';
import '../chat/chat_list_page.dart';
import 'landlord/landlord_profile.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Widget _buildHomeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHeader(context),
          const SizedBox(height: 24),
          _buildSearchBar(context),
          const SizedBox(height: 18),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('dorms').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text('No properties found.', style: TextStyle(fontSize: 16))),
                );
              }
              final properties = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              }).where((property) {
                if (_searchQuery.isEmpty) return true;
                final name = (property['dormitory_name'] ?? '').toLowerCase();
                final address = (property['address_line'] ?? '').toLowerCase();
                final description = (property['description'] ?? '').toLowerCase();
                return name.contains(_searchQuery) ||
                    address.contains(_searchQuery) ||
                    description.contains(_searchQuery);
              }).toList();

              return _buildPropertiesList(properties);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String landlordId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final List<Widget> _pages = [
      _buildHomeTab(context),
      const AddDormPage(),
      // ChatListPage is just a widget, not a page/route!
      ChatListPage(
        currentUserId: landlordId,
        currentUserRole: 'landlord',
      ),
      const LandlordProfilePage(),
    ];

    return Scaffold(
      appBar: const LandlordAppBar(),
      backgroundColor: const Color(0xFFF9F9F9),
      body: _pages[_currentIndex],
      bottomNavigationBar: LandlordBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex != 0) _searchController.clear();
          });
        },
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF800000),
          child: const Icon(Icons.person, size: 32, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Welcome, User!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Manage your properties easily and efficiently.',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, address, or description...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            style: const TextStyle(fontSize: 15),
            onSubmitted: (_) => _onSearch(),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _onSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF800000),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(48, 48),
          ),
          child: const Icon(Icons.search, size: 22),
        ),
      ],
    );
  }

  Widget _buildPropertiesList(List<Map<String, dynamic>> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Your Properties',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF800000),
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: properties.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final property = properties[index];
            return _buildPropertyCard(context, property);
          },
        ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> property) {
    final String? imageUrl = (property['images'] is List && property['images'] != null && property['images'].isNotEmpty)
        ? property['images'][0]
        : null;

    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
              Navigator.pushNamed(
                context,
                '/property_details',
                arguments: property, // Pass the property map
              );
            },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'lib/assets/images/property_outside.jpg',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'lib/assets/images/property_outside.jpg',
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property['dormitory_name'] ?? 'No Name',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF800000)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (property['status'] != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: property['status'] == 'Available' ? Colors.green[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              property['status'] ?? '',
                              style: TextStyle(
                                color: property['status'] == 'Available' ? Colors.green : Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 15, color: Colors.grey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            property['address_line'] ?? '',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      property['description'] ?? '',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (property['num_beds'] != null)
                          Row(
                            children: [
                              const Icon(Icons.bed, size: 14, color: Colors.black54),
                              Text(' ${property['num_beds']} ', style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                            ],
                          ),
                        if (property['num_baths'] != null)
                          Row(
                            children: [
                              const Icon(Icons.bathtub, size: 14, color: Colors.black54),
                              Text(' ${property['num_baths']} ', style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (property['monthly_rate_(rm)'] != null)
                          Text(
                            "RM${property['monthly_rate_(rm)']} /mo",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.edit, size: 16, color: Color(0xFF800000)),
                              label: const Text('Edit', style: TextStyle(fontSize: 13, color: Color(0xFF800000))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF800000)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                minimumSize: const Size(38, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/property_details',
                                  arguments: property,
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                minimumSize: const Size(38, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              ),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Property'),
                                    content: const Text(
                                        'Are you sure you want to delete this property? This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('dorms')
                                        .doc(property['id'])
                                        .delete();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Property deleted successfully!')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Delete failed: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                              child: const Icon(Icons.delete, color: Colors.red, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}