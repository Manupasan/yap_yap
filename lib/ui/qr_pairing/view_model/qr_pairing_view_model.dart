import 'package:flutter/material.dart';
import '../../../data/repositories/qr_repository.dart';

class QrPairingViewModel extends ChangeNotifier {
  final QrRepository qrRepository;
  String? sessionId;
  bool isConnected = false;

  QrPairingViewModel({required this.qrRepository});

  Future<void> generateSession() async {
    sessionId = await qrRepository.createSession();
    notifyListeners();
  }

  Future<void> connectToSession(String scannedSessionId) async {
    isConnected = await qrRepository.connectToSession(scannedSessionId);
    notifyListeners();
  }
}
