// lib/ui/chat_box/view_model/chat_view_model.dart
import 'package:flutter/material.dart';
import '../../../data/repositories/qr_repository.dart';
import '../../../data/services/firebase_chat_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/models/chat_session_local.dart';
import '../../../data/models/message_local.dart';
import 'dart:async';

class ChatViewModel extends ChangeNotifier {
  final QrRepository qrRepository;
  final String sessionId;
  final String currentUserId;
  final LocalStorageService _localStorage = LocalStorageService();

  List<ChatMessage> _messages = [];
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  bool _isLoading = false;
  String _otherUserName = 'Connected User';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get otherUserName => _otherUserName;

  ChatViewModel({
    required this.qrRepository,
    required this.sessionId,
    required this.currentUserId,
  }) {
    _initializeChat();
    _loadLocalChatSession();
  }

  void _initializeChat() {
    _isLoading = true;
    notifyListeners();

    _messagesSubscription = qrRepository.getMessagesStream(sessionId).listen(
          (messages) {
        _messages = messages.map((msg) => ChatMessage(
          text: msg.text,
          isMe: msg.senderId == currentUserId,
          timestamp: msg.timestamp,
          senderId: msg.senderId,
        )).toList();

        // Save messages locally
        _saveMessagesLocally(messages);

        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error listening to messages: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadLocalChatSession() async {
    try {
      final sessions = await _localStorage.getAllChatSessions();
      final existingSession = sessions.where((s) => s.sessionId == sessionId).firstOrNull;

      if (existingSession != null) {
        _otherUserName = existingSession.otherUserName;
      } else {
        // If no session exists, create one with default name
        final chatSession = ChatSessionLocal(
          sessionId: sessionId,
          otherUserName: _otherUserName,
          lastMessage: null,
          lastActivity: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await _localStorage.saveChatSession(chatSession);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading local chat session: $e');
    }
  }

  Future<void> _saveMessagesLocally(List<ChatMessage> messages) async {
    try {
      for (final message in messages) {
        final localMessage = MessageLocal(
          sessionId: sessionId,
          text: message.text,
          senderId: message.senderId,
          isMe: message.senderId == currentUserId,
          timestamp: message.timestamp,
        );
        await _localStorage.saveMessage(localMessage);
      }

      // Update chat session with last message
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        await _updateChatSession(lastMessage.text, lastMessage.timestamp);
      }
    } catch (e) {
      print('Error saving messages locally: $e');
    }
  }

  Future<void> _updateChatSession(String lastMessage, DateTime lastActivity) async {
    try {
      await _localStorage.updateChatSession(
        sessionId,
        otherUserName: _otherUserName,
        lastMessage: lastMessage,
        lastActivity: lastActivity.millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error updating chat session: $e');
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isNotEmpty) {
      try {
        await qrRepository.sendMessage(sessionId, currentUserId, message);

        // Save to local storage immediately
        final localMessage = MessageLocal(
          sessionId: sessionId,
          text: message,
          senderId: currentUserId,
          isMe: true,
          timestamp: DateTime.now(),
        );
        await _localStorage.saveMessage(localMessage);
        await _updateChatSession(message, DateTime.now());
      } catch (error) {
        print('Error sending message: $error');
      }
    }
  }

  Future<void> updateOtherUserName(String newName) async {
    _otherUserName = newName;
    notifyListeners();

    try {
      // Create or update chat session with new name
      final chatSession = ChatSessionLocal(
        sessionId: sessionId,
        otherUserName: newName,
        lastMessage: _messages.isNotEmpty ? _messages.last.text : null,
        lastActivity: _messages.isNotEmpty ? _messages.last.timestamp : DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _localStorage.saveChatSession(chatSession);
    } catch (e) {
      print('Error updating user name: $e');
    }
  }

  Future<void> endChatSession() async {
    try {
      await qrRepository.leaveSession(sessionId, currentUserId);
    } catch (error) {
      print('Error leaving session: $error');
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}