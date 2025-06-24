import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './appbar.dart';
import './viewproperty.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> allProperties = [];
  List<Map<String, dynamic>> filteredProperties = [];
  String selectedGender = 'Any';
  String selectedDormType = 'Any';
  String selectedSort = 'None';
  String searchKeyword = '';
  bool _loading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('dorms').get();
      final List<Map<String, dynamic>> loaded = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['name'] = data['dormitory_name'] ?? 'No Name';
        data['address'] = data['address_line'] ?? '';
        data['postedBy'] = data['posted_by'] ?? '';
        data['description'] = data['description'] ?? '';
        data['dormType'] = data['dormitory_type'] ?? '';
        data['gender'] = data['gender_preference'] ?? '';
        data['price'] = data['monthly_rate_(rm)'] ?? 0;
        data['images'] = (data['images'] is List) ? data['images'] : [];
        return data;
      }).toList();
      setState(() {
        allProperties = loaded;
        filteredProperties = List.from(loaded);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Failed to load properties';
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> results = allProperties.where((property) {
      final matchesKeyword = property['name'].toString().toLowerCase().contains(searchKeyword.toLowerCase()) ||
          property['address'].toString().toLowerCase().contains(searchKeyword.toLowerCase());
      final matchesGender = selectedGender == 'Any' || property['gender'] == selectedGender;
      final matchesDorm = selectedDormType == 'Any' || property['dormType'] == selectedDormType;
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : errorMsg != null
                ? Center(child: Text(errorMsg!))
                : Column(
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
                                if (value != null) {
                                  selectedGender = value;
                                  _applyFilters();
                                }
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
                                if (value != null) {
                                  selectedDormType = value;
                                  _applyFilters();
                                }
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
                          if (value != null) {
                            selectedSort = value;
                            _applyFilters();
                          }
                        },
                        decoration: const InputDecoration(labelText: 'Sort by Price'),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filteredProperties.isEmpty
                            ? const Center(child: Text('No properties found.'))
                            : ListView.builder(
                                itemCount: filteredProperties.length,
                                itemBuilder: (context, index) {
                                  final property = filteredProperties[index];
                                  final List images = property['images'] ?? [];
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
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 160,
                                              width: double.infinity,
                                              color: Colors.grey[300],
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: imageUrl != null
                                                    ? (imageUrl.startsWith('http')
                                                        ? Image.network(imageUrl, fit: BoxFit.cover)
                                                        : Image.asset(imageUrl, fit: BoxFit.cover))
                                                    : Image.asset('lib/assets/images/property_outside.jpg', fit: BoxFit.cover),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              property['name'] ?? '',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(property['address'] ?? ''),
                                            const SizedBox(height: 4),
                                            Text(property['description'] ?? ''),
                                            const SizedBox(height: 4),
                                            Text("Gender Preference: ${property['gender'] ?? ''}"),
                                            const SizedBox(height: 4),
                                            Text("Dorm Type: ${property['dormType'] ?? ''}"),
                                            const SizedBox(height: 4),
                                            Text("Posted by: ${property['postedBy'] ?? ''}"),
                                            const SizedBox(height: 4),
                                            Text("Price: RM${property['price'] ?? ''}"),
                                          ],
                                        ),
                                      ),
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