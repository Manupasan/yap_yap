// lib/data/services/firebase_chat_service.dart
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirebaseChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Stream<List<ChatMessage>> getMessagesStream(String sessionId) {
    return _database
        .child('sessions')
        .child(sessionId)
        .child('messages')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <ChatMessage>[];

      return data.entries
          .map((entry) {
        final messageData = entry.value as Map<dynamic, dynamic>;
        return ChatMessage(
          text: messageData['text'] as String,
          isMe: false, // Will be set by the view model
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            messageData['timestamp'] as int,
          ),
          senderId: messageData['senderId'] as String,
        );
      })
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  Stream<Set<String>> getUsersStream(String sessionId) {
    return _database
        .child('sessions')
        .child(sessionId)
        .child('users')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <String>{};

      return data.keys.cast<String>().toSet();
    });
  }

  Future<void> sendMessage(String sessionId, String userId, String message) async {
    final messageRef = _database
        .child('sessions')
        .child(sessionId)
        .child('messages')
        .push();

    await messageRef.set({
      'text': message,
      'senderId': userId,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> joinSession(String sessionId, String userId) async {
    await _database
        .child('sessions')
        .child(sessionId)
        .child('users')
        .child(userId)
        .set({
      'joinedAt': ServerValue.timestamp,
      'isOnline': true,
    });

    // Set user offline when they disconnect
    await _database
        .child('sessions')
        .child(sessionId)
        .child('users')
        .child(userId)
        .child('isOnline')
        .onDisconnect()
        .set(false);
  }

  Future<void> leaveSession(String sessionId, String userId) async {
    await _database
        .child('sessions')
        .child(sessionId)
        .child('users')
        .child(userId)
        .child('isOnline')
        .set(false);
  }

  Future<bool> sessionExists(String sessionId) async {
    final snapshot = await _database
        .child('sessions')
        .child(sessionId)
        .get();
    return snapshot.exists;
  }

  Future<void> createSession(String sessionId) async {
    await _database
        .child('sessions')
        .child(sessionId)
        .set({
      'createdAt': ServerValue.timestamp,
      'isActive': true,
    });
  }

  int getUserCount(String sessionId) {
    // This will be handled by the stream
    return 0;
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String senderId;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.senderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isMe: false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      senderId: json['senderId'] as String,
    );
  }
}