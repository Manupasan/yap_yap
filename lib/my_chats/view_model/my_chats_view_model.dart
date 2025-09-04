// lib/my_chats/view_model/my_chats_view_model.dart
import 'package:flutter/material.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/models/chat_session_local.dart';
import '../../data/services/qr_service.dart';

class MyChatsViewModel extends ChangeNotifier {
  final QrService qrService;
  final LocalStorageService _localStorage = LocalStorageService();

  List<ChatSessionLocal> _chatSessions = [];
  late final String currentUserId;

  List<ChatSessionLocal> get chatSessions => _chatSessions;

  MyChatsViewModel({required this.qrService}) {
    currentUserId = qrService.generateSessionId();
    _loadChatSessions();
  }

  Future<void> _loadChatSessions() async {
    try {
      _chatSessions = await _localStorage.getAllChatSessions();
      notifyListeners();
    } catch (e) {
      print('Error loading chat sessions: $e');
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _localStorage.deleteChatSession(sessionId);
      _chatSessions.removeWhere((session) => session.sessionId == sessionId);
      notifyListeners();
    } catch (e) {
      print('Error deleting chat session: $e');
    }
  }

  Future<void> refreshChatSessions() async {
    await _loadChatSessions();
  }
}