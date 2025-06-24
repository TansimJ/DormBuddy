import 'package:flutter/material.dart';
import './appbar.dart';
import './viewproperty.dart';
import './propertycard.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<Map<String, dynamic>> properties = [
    {
      "id": 1,
      "name": "Sunny Apartment",
      "images": [
        "lib/assets/images/property_outside.jpg",
        "lib/assets/images/bedroom.jpg",
        "lib/assets/images/room.jpg",
      ],
      "address": "123 College St, Apt 1",
      "postedBy": "Liam K.",
      "description": "Cozy apartment near campus with great amenities",
      "dormType": "Shared",
      "gender": "Women",
      "price": 400,
    },
    {
      "id": 2,
      "name": "Cassie Complex",
      "images": [
        "lib/assets/images/property_outside.jpg",
        "lib/assets/images/bedroom.jpg",
        "lib/assets/images/room.jpg",
      ],
      "address": "456 College St, Apt 4",
      "postedBy": "Brain Steel",
      "description": "Cozy apartment complex near campus safe from Diddy",
      "dormType": "Shared",
      "gender": "Women",
      "price": 450
    },
    {
      "id": 3,
      "name": "Ling Gan Studio",
      "images": [
        "lib/assets/images/property_outside.jpg",
        "lib/assets/images/bedroom.jpg",
        "lib/assets/images/room.jpg",
      ],
      "address": "Linggangguli 1, Apt 3",
      "postedBy": "Don Pollo",
      "description": "Waza apartment near campus with great guli",
      "dormType": "Studio",
      "gender": "Any",
      "price": 500
    },
    {
      "id": 4,
      "name": "Windy Apartment",
      "images": [
        "lib/assets/images/property_outside.jpg",
        "lib/assets/images/bedroom.jpg",
        "lib/assets/images/room.jpg",
      ],
      "address": "123 Ogga booga St, Apt 1",
      "postedBy": "Liam K.",
      "description": "Cozy apartment near campus with great amenities",
      "dormType": "Shared",
      "gender": "Men",
      "price": 350
    },
    {
      "id": 5,
      "name": "Knee Surgery Apartment",
      "images": [
        "lib/assets/images/property_outside.jpg",
        "lib/assets/images/bedroom.jpg",
        "lib/assets/images/room.jpg",
      ],
      "address": "234 Knee Surgery St, Apt 2",
      "postedBy": "Kevin the orthopedic surgeon",
      "description": "Cozy apartment near campus with great knee surgery",
      "dormType": "Studio",
      "gender": "Any",
      "price": 550
    },
  ];

  List<Map<String, dynamic>> filteredProperties = [];
  String selectedGender = 'Any';
  String selectedDormType = 'Any';
  String selectedSort = 'None';
  String searchKeyword = '';

  Set<int> likedProperties = {};

  @override
  void initState() {
    super.initState();
    filteredProperties = List.from(properties);
  }

  void toggleLike(int propertyId) {
    setState(() {
      if (likedProperties.contains(propertyId)) {
        likedProperties.remove(propertyId);
      } else {
        likedProperties.add(propertyId);
      }
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> results = properties.where((property) {
      final matchesKeyword = property['name']
              .toLowerCase()
              .contains(searchKeyword.toLowerCase()) ||
          property['address']
              .toLowerCase()
              .contains(searchKeyword.toLowerCase());
      final matchesGender =
          selectedGender == 'Any' || property['gender'] == selectedGender;
      final matchesDorm =
          selectedDormType == 'Any' || property['dormType'] == selectedDormType;
      return matchesKeyword && matchesGender && matchesDorm;
    }).toList();

    if (selectedSort == 'Low to High') {
      results.sort((a, b) => a['price'].compareTo(b['price']));
    } else if (selectedSort == 'High to Low') {
      results.sort((a, b) => b['price'].compareTo(a['price']));
    }

    setState(() {
      filteredProperties = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                searchKeyword = value;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Search by address or name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedGender,
                    items: ['Any', 'Women', 'Men']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      selectedGender = value!;
                      _applyFilters();
                    },
                    decoration: const InputDecoration(labelText: 'Gender'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDormType,
                    items: ['Any', 'Shared', 'Studio']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      selectedDormType = value!;
                      _applyFilters();
                    },
                    decoration: const InputDecoration(labelText: 'Dorm Type'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSort,
              items: ['None', 'Low to High', 'High to Low']
                  .map((sort) => DropdownMenuItem(
                        value: sort,
                        child: Text('Sort by Price: $sort'),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedSort = value!;
                _applyFilters();
              },
              decoration: const InputDecoration(labelText: 'Sort by Price'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProperties.length,
                itemBuilder: (context, index) {
                  final property = filteredProperties[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPage(property: property),
                        ),
                      );
                    },
                    child: PropertyCard(
                      property: {
                        'dormitory_name': property['name'],
                        'address_line': property['address'],
                        'description': property['description'],
                        'dormitory_type': property['dormType'],
                        'gender_preference': property['gender'],
                        'posted_by': property['postedBy'],
                        'price': property['price'],
                        'images': property['images'],
                      },
                      isLiked: likedProperties.contains(property['id']),
                      onLikeToggle: () => toggleLike(property['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
