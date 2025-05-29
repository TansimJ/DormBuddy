import 'package:flutter/material.dart';
import 'landlord/landlord_appbar.dart';
import 'landlord/landlord_bottombar.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allProperties = [
    {
      'image': 'lib/assets/images/property_outside.jpg',
      'name': 'Property Name 1',
      'address': 'Jalan Semarak, Kuala Lumpur',
      'description': 'Modern single room with KL city view',
    },
    {
      'image': 'lib/assets/images/property_outside.jpg',
      'name': 'Property Name 2',
      'address': 'Jalan Tun Razak, Kuala Lumpur',
      'description': 'Modern twin bed room with KL city view',
    },
  ];

  List<Map<String, dynamic>> _filteredProperties = [];

  @override
  void initState() {
    super.initState();
    _filteredProperties = List.from(_allProperties);
    _searchController.addListener(_filterProperties);
  }

  void _filterProperties() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProperties =
          _allProperties.where((property) {
            final name = property['name'].toLowerCase();
            final address = property['address'].toLowerCase();
            final description = property['description'].toLowerCase();
            return name.contains(query) ||
                address.contains(query) ||
                description.contains(query);
          }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/landlord_dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/add_dorm');
        break;
      case 2:
        Navigator.pushNamed(context, '/landlord_chat');
        break;
      case 3:
        Navigator.pushNamed(context, '/landlord_profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LandlordAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildPropertiesList(_filteredProperties),
          ],
        ),
      ),
      bottomNavigationBar: LandlordBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF800000).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Welcome User!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF800000),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Looking to list your property? Start here!',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name, address, or description...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildPropertiesList(List<Map<String, dynamic>> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Properties',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF800000),
          ),
        ),
        const SizedBox(height: 16),
        ...properties.map((property) => _buildPropertyCard(property)).toList(),
      ],
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
           ClipRRect(
                                //adding an image
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'lib/assets/images/property_outside.jpg', 
                                  fit: BoxFit.cover,
                                ),
                              ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      property['address'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  property['description'],
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/delete_property',
                          arguments: property,
                        ).then((result) {
                          if (result == true) {
                            setState(() {
                              _allProperties.remove(property);
                              _filterProperties();
                            });
                          }
                        });
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
