import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/qr_repository.dart';
import 'data/services/qr_service.dart';
import 'ui/qr_pairing/view_model/qr_pairing_view_model.dart';
import 'ui/qr_pairing/widgets/qr_pairing_screen.dart';

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
      home: const HomePage(),
      routes: {
         '/qr-pairing': (_) => const QrPairingScreen(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YapYap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.pushNamed(context,'/qr-pairing');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to YapYap!'),
      ),
    );
  }
}
