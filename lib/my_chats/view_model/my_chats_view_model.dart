import 'package:flutter/material.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/models/chat_session_local.dart';
import '../../data/services/qr_service.dart';
import '../../utils/toast_utils.dart';  // Add this import

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
      ToastUtils.showErrorToast('Failed to load chats');
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    try {
      // Find the chat session name before deleting for the toast message
      final sessionToDelete = _chatSessions.firstWhere(
            (session) => session.sessionId == sessionId,
        orElse: () => ChatSessionLocal(
          sessionId: sessionId,
          otherUserName: 'Chat',
          lastActivity: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      await _localStorage.deleteChatSession(sessionId);
      _chatSessions.removeWhere((session) => session.sessionId == sessionId);
      notifyListeners();

      // Show success toast
      ToastUtils.showSuccessToast('Chat with ${sessionToDelete.otherUserName} deleted successfully ✅');
    } catch (e) {
      print('Error deleting chat session: $e');
      ToastUtils.showErrorToast('Failed to delete chat');
    }
  }

  Future<void> refreshChatSessions() async {
    await _loadChatSessions();
    ToastUtils.showInfoToast('Chats refreshed');
  }
}