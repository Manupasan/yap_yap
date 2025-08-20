import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/qr_pairing_view_model.dart';
import 'qr_generator_widget.dart';
import 'qr_scanner_widget.dart';

class QrPairingScreen extends StatelessWidget {
  const QrPairingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QrPairingViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('QR Pairing')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (viewModel.sessionId == null)
            ElevatedButton(
              onPressed: viewModel.generateSession,
              child: const Text('Generate QR Code'),
            )
          else
            QrGeneratorWidget(sessionId: viewModel.sessionId!),
          const SizedBox(height: 32),
          QrScannerWidget(onScanned: viewModel.connectToSession),
          if (viewModel.isConnected)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Connected!'),
            ),
        ],
      ),
    );
  }
}
