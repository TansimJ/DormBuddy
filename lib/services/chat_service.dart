import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrGetChatRoom({
    required String landlordId,
    required String studentId,
    required String propertyId,
  }) async {
    // Query for existing chat room
    var result = await _firestore
        .collection('chat_rooms')
        .where('landlordId', isEqualTo: landlordId)
        .where('studentId', isEqualTo: studentId)
        .where('propertyId', isEqualTo: propertyId)
        .get();

    if (result.docs.isNotEmpty) {
      return result.docs.first.id;
    } else {
      // Create new chat room
      var docRef = await _firestore.collection('chat_rooms').add({
        'landlordId': landlordId,
        'studentId': studentId,
        'propertyId': propertyId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    }
  }

  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String recipientId,   // <-- Pass this when calling
    required String senderName,     // <-- Pass this when calling
    required String message,
    String? propertyId,             // <-- optional
  }) async {
    // Send the chat message
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Also create a notification for the recipient
    await _firestore
        .collection('users')
        .doc(recipientId)
        .collection('notifications')
        .add({
      'type': 'message',
      'title': 'New message from $senderName',
      'body': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'chatRoomId': chatRoomId,
      if (propertyId != null) 'propertyId': propertyId,
    });
  }

  Stream<List<ChatRoom>> getUserChatRooms(String userId, String role) {
    // role can be 'landlord' or 'student'
    String field = role == 'landlord' ? 'landlordId' : 'studentId';
    return _firestore
        .collection('chat_rooms')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String> getOrCreateChatRoom({
    required String studentId,
    required String landlordId,
    required String propertyId,
  }) async {
    final chatRooms = await _firestore
        .collection('chat_rooms')
        .where('studentId', isEqualTo: studentId)
        .where('landlordId', isEqualTo: landlordId)
        .where('propertyId', isEqualTo: propertyId)
        .get();

    if (chatRooms.docs.isNotEmpty) {
      return chatRooms.docs.first.id;
    }

    // Create new chat room
    final docRef = await _firestore.collection('chat_rooms').add({
      'studentId': studentId,
      'landlordId': landlordId,
      'propertyId': propertyId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<List<ChatMessage>> getMessagesOnce(String chatRoomId) async {
    final snapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .get();
    return snapshot.docs
        .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> markMessageAsRead(String chatRoomId, String messageId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'read': true});
  }
}