import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat_message_bubble.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final String currentUserId;

  const ChatPage({
    required this.chatRoomId,
    required this.currentUserId,
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
        message: text,
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
        title: Text('Chat'), // Correct: Text widget, not just 'Chat'
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.getMessages(widget.chatRoomId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final messages = snapshot.data!;
                  return ListView.builder(
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == widget.currentUserId;
                      return ChatMessageBubble(message: msg, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Type a message...'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
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