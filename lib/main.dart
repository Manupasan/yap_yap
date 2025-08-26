// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yap_yap/ui/chat_box/widgets/chat_box.dart';
import 'package:yap_yap/ui/chat_box/view_model/chat_view_model.dart';
import 'package:yap_yap/ui/generate_QR_code/widgets/generate_QR_screen.dart';
import 'package:yap_yap/ui/scan_QR_code/widgets/scan_QR_screen.dart';

import 'data/repositories/qr_repository.dart';
import 'data/services/qr_service.dart';
import 'data/services/firebase_chat_service.dart'; // Only Firebase service
import 'ui/qr_pairing/view_model/qr_pairing_view_model.dart';
import 'ui/qr_pairing/widgets/qr_pairing_screen.dart';
import 'ui/home_page/widgets/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully!");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<QrService>(create: (context) => QrService()),
        Provider<FirebaseChatService>(create: (context) => FirebaseChatService()),
        ProxyProvider2<QrService, FirebaseChatService, QrRepository>(
          update: (context, qrService, chatService, previous) => QrRepository(
            qrService: qrService,
            chatService: chatService,
          ),
        ),
        ChangeNotifierProxyProvider<QrRepository, QrPairingViewModel>(
          create: (context) => QrPairingViewModel(
            qrRepository: context.read<QrRepository>(),
            qrService: context.read<QrService>(),
          ),
          update: (context, qrRepository, previous) => QrPairingViewModel(
            qrRepository: qrRepository,
            qrService: context.read<QrService>(),
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/chat':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) => ChatViewModel(
                  qrRepository: context.read<QrRepository>(),
                  sessionId: args['sessionId'],
                  currentUserId: args['currentUserId'],
                ),
                child: ChatBox(
                  sessionId: args['sessionId'],
                  currentUserId: args['currentUserId'],
                ),
              ),
            );
          default:
            return null;
        }
      },
      routes: {
        '/qr-pairing': (context) => const QrPairingScreen(),
        '/generate-qr': (context) => const GenerateQRScreen(),
        '/scan-qr': (context) => const ScanQRScreen(),
        '/start-chat': (context) => const ChatBox(sessionId: 'demo', currentUserId: 'demo'),
      },
    );
  }
}