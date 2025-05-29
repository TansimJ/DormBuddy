import 'package:flutter/material.dart';

class PropertyCard extends StatefulWidget {
  final String propertyName;
  final String address;
  final String postedBy;
  final String description;
  final String roomType; // Studio or Shared
  final String genderPreference; // Male, Female, Any

  const PropertyCard({
    super.key,
    required this.propertyName,
    required this.address,
    required this.postedBy,
    required this.description,
    required this.roomType,
    required this.genderPreference,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              image: const DecorationImage(
                image: AssetImage('assets/placeholder_property.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Name
                Text(
                  widget.propertyName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Address
                Text(
                  widget.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                // Room Type & Gender Preference
                Row(
                  children: [
                    Icon(Icons.home_work_outlined, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      widget.roomType,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.person_outline, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      widget.genderPreference,
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
                      'Posted By ${widget.postedBy}',
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
    );
  }
}
