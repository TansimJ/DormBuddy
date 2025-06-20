import 'package:flutter/material.dart';
import '../../models/chat_room.dart';
import '../../services/chat_service.dart';
import 'chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListPage extends StatelessWidget {
  final String currentUserId;
  final String currentUserRole; // 'landlord' or 'student'

  const ChatListPage({
    required this.currentUserId,
    required this.currentUserRole,
    Key? key,
  }) : super(key: key);

  Future<String> _getUserName(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data()?['name'] ?? '';
  }

  Future<String> _getPropertyName(String propertyId) async {
    final doc = await FirebaseFirestore.instance.collection('dorms').doc(propertyId).get();
    return doc.data()?['dormitory_name'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final ChatService _chatService = ChatService();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Chats',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ChatRoom>>(
            stream: _chatService.getUserChatRooms(currentUserId, currentUserRole),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final chatRooms = snapshot.data!;
              if (chatRooms.isEmpty)
                return const Center(child: Text('No chats yet.'));
              return ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final room = chatRooms[index];
                  final otherPartyId = currentUserRole == 'landlord' ? room.studentId : room.landlordId;
                  return FutureBuilder<String>(
                    future: _getUserName(otherPartyId),
                    builder: (context, userSnapshot) {
                      return FutureBuilder<String>(
                        future: _getPropertyName(room.propertyId),
                        builder: (context, propSnapshot) {
                          final displayName = userSnapshot.connectionState == ConnectionState.done
                              ? (userSnapshot.data?.isNotEmpty == true ? userSnapshot.data! : 'User')
                              : 'Loading...';

                          final propertyName = propSnapshot.connectionState == ConnectionState.done
                              ? (propSnapshot.data?.isNotEmpty == true ? propSnapshot.data! : 'Property')
                              : 'Loading...';

                          return ListTile(
                            title: Text('Chat with $displayName'),
                            subtitle: Text('Property: $propertyName'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    chatRoomId: room.id,
                                    currentUserId: currentUserId,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}