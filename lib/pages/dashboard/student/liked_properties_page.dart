import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'propertycard.dart';
import 'viewproperty.dart';

class LikedPropertiesPage extends StatelessWidget {
  const LikedPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('You must be logged in.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liked Properties',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800000),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('liked_properties')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final likedDocs = snapshot.data!.docs;
          if (likedDocs.isEmpty) {
            return const Center(child: Text('No liked properties.'));
          }

          // Now fetch all property data in parallel
          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(
              likedDocs.map((doc) {
                return FirebaseFirestore.instance
                    .collection('dorms')
                    .doc(doc.id)
                    .get();
              }).toList(),
            ),
            builder: (context, propertySnap) {
              if (!propertySnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final propertyDocs = propertySnap.data!
                  .where((doc) => doc.exists && doc.data() != null)
                  .toList();
              if (propertyDocs.isEmpty) {
                return const Center(child: Text('No liked properties found.'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: propertyDocs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.66,
                ),
                itemBuilder: (context, index) {
                  final data = propertyDocs[index].data() as Map<String, dynamic>;
                  data['id'] = propertyDocs[index].id;
                  return PropertyCard(
                    property: data,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPage(property: data),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}