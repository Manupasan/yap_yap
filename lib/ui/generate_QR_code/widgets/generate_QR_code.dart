import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRCode extends StatelessWidget {
  final String sessionId;
  const GenerateQRCode({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        QrImageView(
          data: sessionId,
          version: QrVersions.auto,
          size: 200.0,
        ),
        const SizedBox(height: 10),
        Text('Session ID: $sessionId'),
      ],
    );
  }
}