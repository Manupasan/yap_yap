import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGeneratorWidget extends StatelessWidget {
  final String sessionId;
  const QrGeneratorWidget({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Scan this QR to join the chat'),
        QrImageView(
          data: sessionId,
          version: QrVersions.auto,
          size: 200.0,
        ),
        Text('Session ID: $sessionId'),
      ],
    );
  }
}
