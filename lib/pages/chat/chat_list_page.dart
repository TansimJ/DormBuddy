import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Map<String, String?> _lastNotifiedMessageId = {};

  @override
  void initState() {
    super.initState();
    _loadLastNotifiedMessageIds();
  }

  /// Loads last notified message IDs from persistent storage
  Future<void> _loadLastNotifiedMessageIds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, String?> loaded = {};
    for (final key in keys) {
      if (key.startsWith('notified_')) {
        loaded[key.replaceFirst('notified_', '')] = prefs.getString(key);
      }
    }
    setState(() {
      _lastNotifiedMessageId = loaded;
    });
  }

  /// Saves the last notified message ID for a chat room
  Future<void> _saveLastNotifiedMessageId(String roomId, String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notified_$roomId', messageId);
  }

  /// Removes the last notified message ID for a chat room
  Future<void> _removeLastNotifiedMessageId(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notified_$roomId');
  }

  /// Fetches the display name of a user by userId
  Future<String> _getUserName(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data()?['name'] ?? '';
  }

  /// Fetches the property name by propertyId
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
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final chatRooms = snapshot.data!;
              if (chatRooms.isEmpty) {
                return const Center(child: Text('No chats yet.'));
              }
              return ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final room = chatRooms[index];
                  final otherPartyId = widget.currentUserRole == 'landlord'
                      ? room.studentId
                      : room.landlordId;
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

                          // Listen for messages in this chat room
                          return StreamBuilder<List<ChatMessage>>(
                            stream: _chatService.getMessages(room.id),
                            builder: (context, messageSnapshot) {
                              int unreadCount = 0;
                              String? latestUnreadMessageId;
                              ChatMessage? latestUnreadMessage;

                              if (messageSnapshot.hasData && messageSnapshot.data!.isNotEmpty) {
                                final messages = messageSnapshot.data!;
                                // Filter unread messages not sent by the current user
                                final unreadMessages = messages
                                    .where((msg) =>
                                        msg.senderId != widget.currentUserId &&
                                        (msg.read == false || msg.read == null))
                                    .toList();

                                unreadCount = unreadMessages.length;

                                // Only notify for the latest unread message, and only if it is still unread
                                if (unreadMessages.isNotEmpty) {
                                  latestUnreadMessage = unreadMessages.last;
                                  latestUnreadMessageId = latestUnreadMessage.id;

                                  // Only show notification if this unread message hasn't been notified yet in this session
                                  if (_lastNotifiedMessageId[room.id] != latestUnreadMessageId) {
                                    _lastNotifiedMessageId[room.id] = latestUnreadMessageId;
                                    _saveLastNotifiedMessageId(room.id, latestUnreadMessageId!);
                                    ChatNotificationService.showChatNotification(
                                      title: 'New message from $displayName',
                                      body: latestUnreadMessage.text,
                                    );
                                  }
                                } else {
                                  // All messages are read, reset the last notified message id for this room
                                  _lastNotifiedMessageId.remove(room.id);
                                  _removeLastNotifiedMessageId(room.id);
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