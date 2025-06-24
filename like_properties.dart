import 'package:flutter/material.dart';
import './viewproperty.dart';

class LikedPropertiesPage extends StatelessWidget {
  final List<Map<String, dynamic>> properties;
  final Set<int> likedPropertyIds;

  const LikedPropertiesPage({
    super.key,
    required this.properties,
    required this.likedPropertyIds,
  });

  @override
  Widget build(BuildContext context) {
    final likedProperties = properties.where((property) => likedPropertyIds.contains(property['id'])).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Properties'),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
      ),
      body: likedProperties.isEmpty
          ? const Center(
              child: Text('No liked properties.'),
            )
          : ListView.builder(
              itemCount: likedProperties.length,
              itemBuilder: (context, index) {
                final property = likedProperties[index];
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
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Image.asset(
                        'lib/assets/images/property_outside.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(property['name']),
                      subtitle: Text("Price: \$${property['price']}/month"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
