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

  // Track sent messages to prevent duplicates
  final Set<String> _sentMessageIds = <String>{};

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

    // Load local messages first
    _loadLocalMessages();

    _messagesSubscription = qrRepository.getMessagesStream(sessionId).listen(
          (firebaseMessages) {
        _mergeWithFirebaseMessages(firebaseMessages);
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

  Future<void> _loadLocalMessages() async {
    try {
      final localMessages = await _localStorage.getMessagesForSession(sessionId);
      if (localMessages.isNotEmpty) {
        _messages = localMessages.map((msg) => ChatMessage(
          text: msg.text,
          isMe: msg.isMe,
          timestamp: msg.timestamp,
          senderId: msg.senderId,
        )).toList();
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
    } catch (e) {
      print('Error loading local messages: $e');
    }
  }

  String _generateMessageId(String text, String senderId) {
    return '${senderId}_${text.hashCode}';
  }

  void _mergeWithFirebaseMessages(List<ChatMessage> firebaseMessages) {
    final messagesToAdd = <ChatMessage>[];

    for (final fbMsg in firebaseMessages) {
      final isMe = fbMsg.senderId == currentUserId;
      final chatMessage = ChatMessage(
        text: fbMsg.text,
        isMe: isMe,
        timestamp: fbMsg.timestamp,
        senderId: fbMsg.senderId,
      );

      final messageId = _generateMessageId(chatMessage.text, chatMessage.senderId);

      // Check if this is a message we already have (either locally or from Firebase)
      final existsByContent = _messages.any((msg) =>
      msg.text == chatMessage.text &&
          msg.senderId == chatMessage.senderId);

      // For messages sent by current user, check if we've already tracked it
      final isOwnMessageAlreadyTracked = isMe && _sentMessageIds.contains(messageId);

      if (!existsByContent && !isOwnMessageAlreadyTracked) {
        messagesToAdd.add(chatMessage);

        // Track the message ID to prevent future duplicates
        if (isMe) {
          _sentMessageIds.add(messageId);
        }
      }
    }

    // Add new messages
    if (messagesToAdd.isNotEmpty) {
      _messages.addAll(messagesToAdd);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Save new Firebase messages locally (only messages from other users)
      final othersMessages = messagesToAdd.where((msg) => !msg.isMe).toList();
      if (othersMessages.isNotEmpty) {
        _saveFirebaseMessagesLocally(othersMessages);
      }
    }
  }

  Future<void> _saveFirebaseMessagesLocally(List<ChatMessage> newMessages) async {
    try {
      for (final message in newMessages) {
        final messageLocal = MessageLocal(
          sessionId: sessionId,
          text: message.text,
          senderId: message.senderId,
          isMe: message.isMe,
          timestamp: message.timestamp,
        );

        await _localStorage.saveMessage(messageLocal);
      }

      // Update chat session with last message
      if (newMessages.isNotEmpty) {
        final lastMessage = newMessages.last;
        await _updateChatSession(lastMessage.text, lastMessage.timestamp);
      }
    } catch (e) {
      print('Error saving Firebase messages locally: $e');
    }
  }

  Future<void> _loadLocalChatSession() async {
    try {
      final sessions = await _localStorage.getAllChatSessions();
      final existingSession = sessions.where((s) => s.sessionId == sessionId).firstOrNull;

      if (existingSession != null) {
        _otherUserName = existingSession.otherUserName;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading local chat session: $e');
    }
  }

  Future<void> _ensureChatSessionExists() async {
    try {
      final sessions = await _localStorage.getAllChatSessions();
      final existingSession = sessions.where((s) => s.sessionId == sessionId).firstOrNull;

      if (existingSession == null) {
        // Create new chat session
        final newSession = ChatSessionLocal(
          sessionId: sessionId,
          otherUserName: _otherUserName,
          lastMessage: null,
          lastActivity: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await _localStorage.saveChatSession(newSession);
        print('Created new chat session for QR holder');
      }
    } catch (e) {
      print('Error ensuring chat session exists: $e');
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
      final trimmedMessage = message.trim();
      final messageId = _generateMessageId(trimmedMessage, currentUserId);

      // Check if we've already sent this exact message recently
      if (_sentMessageIds.contains(messageId)) {
        print('Duplicate message detected, skipping send');
        return;
      }

      final now = DateTime.now();
      final chatMessage = ChatMessage(
        text: trimmedMessage,
        isMe: true,
        timestamp: now,
        senderId: currentUserId,
      );

      // Add to sent messages tracker immediately
      _sentMessageIds.add(messageId);

      // Add to UI immediately
      _messages.add(chatMessage);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      notifyListeners();

      try {
        // Ensure chat session exists before sending message
        await _ensureChatSessionExists();

        // Send message to Firebase
        await qrRepository.sendMessage(sessionId, currentUserId, trimmedMessage);

        // Save message locally
        final messageLocal = MessageLocal(
          sessionId: sessionId,
          text: trimmedMessage,
          senderId: currentUserId,
          isMe: true,
          timestamp: now,
        );
        await _localStorage.saveMessage(messageLocal);

        // Update chat session
        await _updateChatSession(trimmedMessage, now);

        print('Message sent and saved locally');
      } catch (error) {
        print('Error sending message: $error');

        // Remove from UI and tracking if sending failed
        _messages.removeWhere((msg) =>
        msg.text == trimmedMessage &&
            msg.senderId == currentUserId &&
            msg.timestamp == now);
        _sentMessageIds.remove(messageId);
        notifyListeners();
      }
    }
  }

  Future<void> updateOtherUserName(String newName) async {
    _otherUserName = newName;
    notifyListeners();

    try {
      // Ensure chat session exists before updating
      await _ensureChatSessionExists();

      await _localStorage.updateChatSession(
        sessionId,
        otherUserName: newName,
      );
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
    _sentMessageIds.clear();
    super.dispose();
  }
}