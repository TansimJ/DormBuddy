import 'package:flutter/material.dart';

class PropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyCard({super.key, required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final List images = (property['images'] is List) ? property['images'] : [];
    final String? imageUrl = (images.isNotEmpty && images[0] != null && images[0].toString().isNotEmpty)
        ? images[0]
        : null;

    print('imageUrl: $imageUrl');

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 200, // Set your desired max height here
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: (imageUrl != null)
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Image.asset('lib/assets/images/property_outside.jpg', fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Name
                  Text(
                    property['dormitory_name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Address
                  Text(
                    property['address_line'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    property['description'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // Room Type & Gender Preference
                  Row(
                    children: [
                      Icon(Icons.home_work_outlined, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(
                        property['dormitory_type'] ?? '',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.person_outline, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(
                        property['gender_preference'] ?? '',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Posted By and Like Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Posted By ${property['posted_by'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
