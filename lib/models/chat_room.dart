class ChatRoom {
  final String id;
  final String landlordId;
  final String studentId;
  final String propertyId;

  ChatRoom({
    required this.id,
    required this.landlordId,
    required this.studentId,
    required this.propertyId,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      landlordId: map['landlordId'],
      studentId: map['studentId'],
      propertyId: map['propertyId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'landlordId': landlordId,
      'studentId': studentId,
      'propertyId': propertyId,
    };
  }
}
