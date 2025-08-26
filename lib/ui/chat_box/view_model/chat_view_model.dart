// lib/ui/chat_box/view_model/chat_view_model.dart
import 'package:flutter/material.dart';
import '../../../data/repositories/qr_repository.dart';
import '../../../data/services/firebase_chat_service.dart';
import 'dart:async';

class ChatViewModel extends ChangeNotifier {
  final QrRepository qrRepository;
  final String sessionId;
  final String currentUserId;

  List<ChatMessage> _messages = [];
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatViewModel({
    required this.qrRepository,
    required this.sessionId,
    required this.currentUserId,
  }) {
    _initializeChat();
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

  Future<void> sendMessage(String message) async {
    if (message.trim().isNotEmpty) {
      try {
        await qrRepository.sendMessage(sessionId, currentUserId, message);
      } catch (error) {
        print('Error sending message: $error');
      }
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    // Leave session when disposing
    qrRepository.leaveSession(sessionId, currentUserId);
    super.dispose();
  }
}