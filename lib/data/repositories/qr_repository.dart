// lib/data/repositories/qr_repository.dart
import '../services/qr_service.dart';
import '../services/firebase_chat_service.dart';

class QrRepository {
  final QrService qrService;
  final FirebaseChatService chatService;

  QrRepository({required this.qrService, required this.chatService});

  Future<String> createSession() async {
    final sessionId = qrService.generateSessionId();
    await chatService.createSession(sessionId);
    return sessionId;
  }

  Future<String> createToken() async {
  final sessionId = qrService.generateSessionId();
  final expiresAt = DateTime.now().add(const Duration(minutes: 1)).millisecondsSinceEpoch;
  final sessionToken = '$sessionId|$expiresAt';
  await chatService.createSession(sessionToken);
  return sessionToken;
  }


  Future<bool> connectToSession(String sessionId, String userId) async {
    final exists = await chatService.sessionExists(sessionId);
    if (!exists) {
      return false;
    }

    await chatService.joinSession(sessionId, userId);
    return true;
  }

  Future<void> sendMessage(String sessionId, String userId, String message) async {
    await chatService.sendMessage(sessionId, userId, message);
  }

  Stream<List<ChatMessage>> getMessagesStream(String sessionId) {
    return chatService.getMessagesStream(sessionId);
  }

  Stream<Set<String>> getUsersStream(String sessionId) {
    return chatService.getUsersStream(sessionId);
  }

  Future<void> leaveSession(String sessionId, String userId) async {
    await chatService.leaveSession(sessionId, userId);
  }

  int getUserCount(String sessionId) {
    return chatService.getUserCount(sessionId);
  }
}