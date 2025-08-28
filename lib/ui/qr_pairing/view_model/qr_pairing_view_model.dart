// lib/ui/qr_pairing/view_model/qr_pairing_view_model.dart
import 'package:flutter/material.dart';
import '../../../data/repositories/qr_repository.dart';
import '../../../data/services/qr_service.dart';
import 'dart:async';

class QrPairingViewModel extends ChangeNotifier {
  final QrRepository qrRepository;
  final QrService qrService;

  String? sessionId;
  String? connectedSessionId;
  String? activeSessionId; // Track active chat session
  bool isConnected = false;
  bool hasOtherUsers = false;
  late final String currentUserId;
  StreamSubscription<Set<String>>? _usersSubscription;

  QrPairingViewModel({required this.qrRepository, required this.qrService}) {
    currentUserId = qrService.generateSessionId();
  }

  get errorMessage => null;

  // Check if there's an active chat session
  bool get hasActiveSession => activeSessionId != null;

  // Set active session when entering chat
  void setActiveSession(String sessionId) {
    activeSessionId = sessionId;
    notifyListeners();
  }

  // Clear active session when leaving chat
  void clearActiveSession() {
    activeSessionId = null;
    notifyListeners();
  }

  Future<void> generateSession() async {
    sessionId = await qrRepository.createSession();

    _usersSubscription?.cancel();
    _usersSubscription = qrRepository.getUsersStream(sessionId!).listen((users) {
      final userCount = users.length;
      hasOtherUsers = userCount > 0;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> generateSessionWithToken() async {
    sessionId = await qrRepository.createToken();

    _usersSubscription?.cancel();
    _usersSubscription = qrRepository.getUsersStream(sessionId!).listen((users) {
      final userCount = users.length;
      hasOtherUsers = userCount > 0;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> connectToSession(String scannedSessionId) async {
    isConnected = await qrRepository.connectToSession(scannedSessionId, currentUserId);
    if (isConnected) {
      connectedSessionId = scannedSessionId;
      setActiveSession(scannedSessionId); // Set as active session
    }
    notifyListeners();
  }

  void resetConnection() {
    isConnected = false;
    connectedSessionId = null;
    hasOtherUsers = false;
    notifyListeners();
  }

  void resetSession() {
    sessionId = null;
    hasOtherUsers = false;
    _usersSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }
}