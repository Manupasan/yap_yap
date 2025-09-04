// lib/domain/models/chat_session.dart
class ChatSession {
  final String sessionId;
  final List<String> participants;
  final String? lastMessage;
  final DateTime lastActivity;

  ChatSession({
    required this.sessionId,
    required this.participants,
    this.lastMessage,
    required this.lastActivity,
  });
}