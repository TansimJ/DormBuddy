import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../chat/chat_list_page.dart';

class LandlordChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final landlordId = FirebaseAuth.instance.currentUser?.uid ?? "";
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ChatListPage(
        currentUserId: landlordId,
        currentUserRole: 'landlord',
      ),
    );
  }
}