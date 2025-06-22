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
  final String currentUserName;

  const ChatListPage({
    required this.currentUserId,
    required this.currentUserRole,
    required this.currentUserName,
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

  Future<void> _saveLastNotifiedMessageId(String roomId, String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notified_$roomId', messageId);
  }

  Future<void> _removeLastNotifiedMessageId(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notified_$roomId');
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EA),
      appBar: AppBar(
        title: const Text(
          'Your Conversations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF800000),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
           
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatRoom>>(
              stream: _chatService.getUserChatRooms(widget.currentUserId, widget.currentUserRole),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF800000).withOpacity(0.8),
                    ),
                   ) );
                }
                final chatRooms = snapshot.data!;
                if (chatRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
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

                            return StreamBuilder<List<ChatMessage>>(
                              stream: _chatService.getMessages(room.id),
                              builder: (context, messageSnapshot) {
                                int unreadCount = 0;
                                String? latestUnreadMessageId;
                                ChatMessage? latestUnreadMessage;

                                if (messageSnapshot.hasData && messageSnapshot.data!.isNotEmpty) {
                                  final messages = messageSnapshot.data!;
                                  final unreadMessages = messages
                                      .where((msg) =>
                                          msg.senderId != widget.currentUserId &&
                                          (msg.read == false || msg.read == null))
                                      .toList();

                                  unreadCount = unreadMessages.length;

                                  if (unreadMessages.isNotEmpty) {
                                    latestUnreadMessage = unreadMessages.last;
                                    latestUnreadMessageId = latestUnreadMessage.id;

                                    if (_lastNotifiedMessageId[room.id] != latestUnreadMessageId) {
                                      _lastNotifiedMessageId[room.id] = latestUnreadMessageId;
                                      _saveLastNotifiedMessageId(room.id, latestUnreadMessageId);
                                      ChatNotificationService.showChatNotification(
                                        title: 'New message from $displayName',
                                        body: latestUnreadMessage.text,
                                      );
                                    }
                                  } else {
                                    _lastNotifiedMessageId.remove(room.id);
                                    _removeLastNotifiedMessageId(room.id);
                                  }
                                }

                                return _ChatListItem(
                                  roomId: room.id,
                                  displayName: displayName,
                                  propertyName: propertyName,
                                  unreadCount: unreadCount,
                                  onTap: () {
                                    final recipientId = otherPartyId;
                                    final senderName = widget.currentUserName;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatPage(
                                          chatRoomId: room.id,
                                          currentUserId: widget.currentUserId,
                                          recipientId: recipientId,
                                          senderName: senderName,
                                          propertyId: room.propertyId,
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
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String roomId;
  final String displayName;
  final String propertyName;
  final int unreadCount;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.roomId,
    required this.displayName,
    required this.propertyName,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF800000).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF800000).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF800000),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      propertyName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF800000),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}