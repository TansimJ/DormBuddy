import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './appbar.dart';
import './photogallery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dorm_buddy/pages/chat/chat_page.dart';
import 'package:dorm_buddy/services/chat_service.dart';
import 'package:share_plus/share_plus.dart';

class ViewPage extends StatefulWidget {
  final Map<String, dynamic> property;

  const ViewPage({super.key, required this.property});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
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
    final String? mainImage = images.isNotEmpty ? images[0] : null;
    final String landlordId = property['landlordId'] ?? '';

    String formatPrice(dynamic price) {
      if (price == null) return 'RM -/month';
      if (price is int) return 'RM $price/month';
      if (price is double) return 'RM ${price.toStringAsFixed(2)}/month';
      return 'RM $price/month';
    }

    return Scaffold(
      appBar: const StudentNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: mainImage != null
                          ? Image.network(mainImage, fit: BoxFit.cover)
                          : Image.asset('lib/assets/images/property_outside.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  // Share Icon
                  Positioned(
                    top: 12,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      tooltip: 'Share Property',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF800000).withOpacity(0.9),
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        final propertyId = property['id'] ?? '';
                        final shareLink = 'https://dormbuddy.com/property/$propertyId';
                        final shareText = 'Check out this property on DormBuddy!\n$shareLink';
                        Share.share(shareText);
                      },
                    ),
                  ),
                  // See All Photos
                  Positioned(
                    top: 12,
                    right: 12,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF800000).withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoGalleryPage(
                              photos: images.cast<String>(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "See all Photos",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Property Title + Like Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      property['dormitory_name']?.toString() ?? 'PROPERTY NAME',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (likeLoading)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey[600],
                        size: 28,
                      ),
                      onPressed: _toggleLike,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Gender & Dorm Type
              Row(
                children: [
                  Chip(
                    label: Text("${property['gender_preference'] ?? 'Any'}"),
                    backgroundColor: Colors.red.shade50,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text("${property['dormitory_type'] ?? 'Studio'}"),
                    backgroundColor: Colors.red.shade50,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Address
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF800000)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      property['address_line']?.toString() ?? 'Property Location',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Landlord Info
              FutureBuilder<DocumentSnapshot>(
                future: landlordId.isNotEmpty
                    ? FirebaseFirestore.instance.collection('users').doc(landlordId).get()
                    : Future.value(null),
                builder: (context, snapshot) {
                  String landlordName = 'Unknown';
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    landlordName = data?['name'] ?? 'Unknown';
                  }
                  return RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(text: 'Posted by '),
                        TextSpan(
                          text: landlordName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(height: 40, thickness: 1),

              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                property['description']?.toString() ?? 'No description provided.',
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),

              const Divider(height: 40, thickness: 1),

              // Price
              const Text(
                'Price',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                formatPrice(property['monthly_rate_(rm)']),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              // Chat Owner Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final studentId = FirebaseAuth.instance.currentUser?.uid;
                    final propertyId = property['id'] ?? '';
                    if (studentId == null || landlordId.isEmpty || propertyId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not start chat. Missing user or property info.')),
                      );
                      return;
                    }

                    final studentDoc = await FirebaseFirestore.instance.collection('users').doc(studentId).get();
                    final senderName = studentDoc.data()?['name'] ?? 'Student';

                    final chatService = ChatService();
                    final String chatRoomId = await chatService.getOrCreateChatRoom(
                      studentId: studentId,
                      landlordId: landlordId,
                      propertyId: propertyId,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          chatRoomId: chatRoomId,
                          currentUserId: studentId,
                          recipientId: landlordId,
                          senderName: senderName,
                          propertyId: propertyId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text(
                    'Chat Owner',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
