// lib/data/models/message_local.dart
class MessageLocal {
  final int? id;
  final String sessionId;
  final String text;
  final String senderId;
  final bool isMe;
  final DateTime timestamp;

  MessageLocal({
    this.id,
    required this.sessionId,
    required this.text,
    required this.senderId,
    required this.isMe,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'text': text,
      'sender_id': senderId,
      'is_me': isMe ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory MessageLocal.fromMap(Map<String, dynamic> map) {
    return MessageLocal(
      id: map['id'],
      sessionId: map['session_id'],
      text: map['text'],
      senderId: map['sender_id'],
      isMe: map['is_me'] == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}