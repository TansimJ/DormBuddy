import 'package:flutter/material.dart';
import '../../models/chat_room.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import 'chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../notification/chat_notification.dart';

class ChatListPage extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole; // 'landlord' or 'student'

  const ChatListPage({
    required this.currentUserId,
    required this.currentUserRole,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  final Map<String, String?> _lastNotifiedMessageId = {};

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
            stream: _chatService.getUserChatRooms(widget.currentUserId, widget.currentUserRole),
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
                  final otherPartyId = widget.currentUserRole == 'landlord' ? room.studentId : room.landlordId;
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

                          // Listen for the latest messages in this chat room
                          return StreamBuilder<List<ChatMessage>>(
                            stream: _chatService.getMessages(room.id),
                            builder: (context, messageSnapshot) {
                              int unreadCount = 0;
                              if (messageSnapshot.hasData && messageSnapshot.data!.isNotEmpty) {
                                final messages = messageSnapshot.data!;
                                // Count unread messages not sent by the current user
                                unreadCount = messages
                                    .where((msg) =>
                                        msg.senderId != widget.currentUserId &&
                                        (msg.read == false || msg.read == null))
                                    .length;

                                final latestMessage = messages.last;
                                // Only show notification if there are unread messages
                                if (unreadCount > 0 &&
                                    latestMessage.senderId != widget.currentUserId &&
                                    (latestMessage.read == false || latestMessage.read == null)) {
                                  if (_lastNotifiedMessageId[room.id] != latestMessage.id) {
                                    _lastNotifiedMessageId[room.id] = latestMessage.id;
                                    ChatNotificationService.showChatNotification(
                                      title: 'New message from $displayName',
                                      body: latestMessage.text,
                                    );
                                  }
                                }
                              }
                              return ListTile(
                                title: Text('Chat with $displayName'),
                                subtitle: Text('Property: $propertyName'),
                                trailing: unreadCount > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(
                                        chatRoomId: room.id,
                                        currentUserId: widget.currentUserId,
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
              );
            },
          ),
        ),
      ],
    );
  }
}