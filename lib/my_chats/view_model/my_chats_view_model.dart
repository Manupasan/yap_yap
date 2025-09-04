// lib/my_chats/view_model/my_chats_view_model.dart
import 'package:flutter/material.dart';
import '../../domain/models/chat_session.dart';
import '../../data/services/qr_service.dart';

class MyChatsViewModel extends ChangeNotifier {
  final QrService qrService;
  List<ChatSession> _chatSessions = [];
  late final String currentUserId;

  List<ChatSession> get chatSessions => _chatSessions;

  MyChatsViewModel({required this.qrService}) {
    currentUserId = qrService.generateSessionId();
    _loadChatSessions();
  }

  void _loadChatSessions() {
    // Mock data for demonstration - replace with actual data loading
    _chatSessions = [
      ChatSession(
        sessionId: 'session1',
        participants: ['user1', 'user2'],
        lastMessage: 'Hello there!',
        lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatSession(
        sessionId: 'session2',
        participants: ['user1', 'user3'],
        lastMessage: 'How are you?',
        lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
    notifyListeners();
  }

  void deleteChatSession(String sessionId) {
    _chatSessions.removeWhere((session) => session.sessionId == sessionId);
    notifyListeners();
  }

  void addChatSession(ChatSession session) {
    _chatSessions.insert(0, session);
    notifyListeners();
  }
}