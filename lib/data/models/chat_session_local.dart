// lib/data/models/chat_session_local.dart
class ChatSessionLocal {
  final String sessionId;
  final String otherUserName;
  final String? lastMessage;
  final DateTime lastActivity;
  final DateTime createdAt;

  ChatSessionLocal({
    required this.sessionId,
    required this.otherUserName,
    this.lastMessage,
    required this.lastActivity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'other_user_name': otherUserName,
      'last_message': lastMessage,
      'last_activity': lastActivity.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ChatSessionLocal.fromMap(Map<String, dynamic> map) {
    return ChatSessionLocal(
      sessionId: map['session_id'],
      otherUserName: map['other_user_name'],
      lastMessage: map['last_message'],
      lastActivity: DateTime.fromMillisecondsSinceEpoch(map['last_activity']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}