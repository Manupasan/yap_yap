import 'package:uuid/uuid.dart';

class QrService {
  final Uuid _uuid = Uuid();

  String generateSessionId() {
    return _uuid.v4();
  }

  // Add more QR-related logic if needed
}
