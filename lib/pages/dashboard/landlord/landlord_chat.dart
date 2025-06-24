import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../chat/chat_list_page.dart';

class LandlordChatPage extends StatelessWidget {
  const LandlordChatPage({super.key});

  Future<String> _getLandlordName(String landlordId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(landlordId).get();
    return doc.data()?['name'] ?? 'Landlord';
  }

  @override
  Widget build(BuildContext context) {
    final landlordId = FirebaseAuth.instance.currentUser?.uid ?? "";
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: FutureBuilder<String>(
        future: _getLandlordName(landlordId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final landlordName = snapshot.data!;
          return ChatListPage(
            currentUserId: landlordId,
            currentUserRole: 'landlord',
            currentUserName: landlordName,
          );
        },
      ),
    );
  }
}