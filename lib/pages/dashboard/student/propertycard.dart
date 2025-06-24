import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;
  final VoidCallback? onTap;

  const PropertyCard({super.key, required this.property, this.onTap});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool isLiked = false;
  bool likeLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final propertyId = widget.property['id'] ?? '';
    if (propertyId == '') return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('liked_properties')
        .doc(propertyId)
        .get();
    setState(() {
      isLiked = doc.exists;
    });
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final propertyId = widget.property['id'] ?? '';
    if (propertyId == '') return;

    setState(() {
      likeLoading = true;
    });

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('liked_properties')
        .doc(propertyId);

    if (isLiked) {
      await ref.delete();
    } else {
      await ref.set({'likedAt': FieldValue.serverTimestamp()});
    }
    setState(() {
      isLiked = !isLiked;
      likeLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final List images = (property['images'] is List) ? property['images'] : [];
    final String? imageUrl = (images.isNotEmpty && images[0] != null && images[0].toString().isNotEmpty)
        ? images[0]
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Like button overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: imageUrl != null
                        ? (imageUrl.startsWith('http')
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Image.asset(imageUrl, fit: BoxFit.cover))
                        : Image.asset('lib/assets/images/property_outside.jpg', fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: likeLoading
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.white,
                              size: 26,
                            ),
                            onPressed: _toggleLike,
                            splashRadius: 20,
                          ),
                        ),
                ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['dormitory_name'] ?? property['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property['address_line'] ?? property['address'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property['description'] ?? '',
                    style: const TextStyle(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.home_work_outlined, size: 13, color: Colors.grey[700]),
                      const SizedBox(width: 3),
                      Text(
                        property['dormitory_type'] ?? property['dormType'] ?? '',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.person_outline, size: 13, color: Colors.grey[700]),
                      const SizedBox(width: 3),
                      Text(
                        property['gender_preference'] ?? property['gender'] ?? '',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "RM${property['monthly_rate_(rm)'] ?? property['price'] ?? '-'} /month",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
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