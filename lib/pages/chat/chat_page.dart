import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat_message_bubble.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final String currentUserId;
  final String recipientId;
  final String senderName;
  final String? propertyId;

  const ChatPage({
    required this.chatRoomId,
    required this.currentUserId,
    required this.recipientId,
    required this.senderName,
    this.propertyId,
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _chatService.sendMessage(
        chatRoomId: widget.chatRoomId,
        senderId: widget.currentUserId,
        recipientId: widget.recipientId,
        senderName: widget.senderName,
        message: text,
        propertyId: widget.propertyId,
      );
      _controller.clear();
    }
  }

  void _markMessagesAsRead() async {
    final messages = await _chatService.getMessagesOnce(widget.chatRoomId);
    for (final msg in messages) {
      if (msg.senderId != widget.currentUserId && (msg.read == false || msg.read == null)) {
        await _chatService.markMessageAsRead(widget.chatRoomId, msg.id);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(widget.recipientId).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text('Loading...');
      }
      if (snapshot.hasData && snapshot.data!.exists) {
        return Text(
          snapshot.data!.get('name') ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }
      return const Text('Unknown');
    },
  ),
        backgroundColor: const Color(0xFF800000),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9F9F9),
              Color(0xFFF0F0F0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _chatService.getMessages(widget.chatRoomId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF800000).withOpacity(0.8),
                          ),
                        ),
                      );
                    }
                    final messages = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ListView.builder(
                        reverse: false,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == widget.currentUserId;
                          return ChatMessageBubble(
                            message: msg,
                            isMe: isMe,
                            key: ValueKey(msg.id),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              // Message input area - now properly centered
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Ensures vertical centering
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4), // Added vertical padding
                        child: TextField(
                          controller: _controller,
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            isDense: true, // Reduces the default height
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12, // Adjusted for better centering
                            ),
                            hintText: 'Message ${widget.senderName}...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.grey.shade500,
                              ),
                              onPressed: () {
                                // Placeholder for emoji picker
                              },
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 48, // Fixed height to match text field
                      width: 48,  // Fixed width for consistency
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA00000), Color(0xFF800000)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF800000).withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _sendMessage,
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}