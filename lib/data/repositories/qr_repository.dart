import '../services/qr_service.dart';

class QrRepository {
  final QrService qrService;

  QrRepository({required this.qrService});

  Future<String> createSession() async {
    // In a real app, you might also create a session on a backend
    return qrService.generateSessionId();
  }

  Future<bool> connectToSession(String sessionId) async {
    // In a real app, you would verify/join the session via backend
    // Here, we just simulate success
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
