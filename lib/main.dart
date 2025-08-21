import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yap_yap/ui/generate_QR_code/widgets/generate_QR_screen.dart';
import 'package:yap_yap/ui/scan_QR_code/widgets/scan_QR_screen.dart';

import 'data/repositories/qr_repository.dart';
import 'data/services/qr_service.dart';
import 'ui/qr_pairing/view_model/qr_pairing_view_model.dart';
import 'ui/qr_pairing/widgets/qr_pairing_screen.dart';
import 'ui/home_page/widgets/homepage.dart';  // Add this import
import 'ui/generate_QR_code/widgets/generate_QR_code.dart';
import 'ui/scan_QR_code/widgets/scan_QR_code.dart';




void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => QrPairingViewModel(
            qrRepository: QrRepository(qrService: QrService()),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YapYap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/qr-pairing': (_) => const QrPairingScreen(),
        '/generate-qr': (_) => const GenerateQRScreen(),
        '/scan-qr': (_) => const ScanQRScreen(),      },
    );
  }
}


