import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/models/chat_session_local.dart';
import '../../../utils/toast_utils.dart';  // Add this import
import '../../qr_pairing/view_model/qr_pairing_view_model.dart';
import 'scan_QR_code.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final LocalStorageService _localStorage = LocalStorageService();
  bool _navigationHandled = false;

  Future<void> _handleScannedCode(String code) async {
    if (_navigationHandled) return;

    final viewModel = Provider.of<QrPairingViewModel>(context, listen: false);

    try {
      await viewModel.connectToSession(code);

      if (viewModel.isConnected && viewModel.connectedSessionId != null) {
        _navigationHandled = true;

        // Show success toast for QR scanner
        ToastUtils.showSuccessToast("Successfully connected! 🚀");

        final chatSession = ChatSessionLocal(
          sessionId: viewModel.connectedSessionId!,
          otherUserName: 'Connected User',
          lastMessage: null,
          lastActivity: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await _localStorage.saveChatSession(chatSession);

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/chat',
            arguments: {
              'sessionId': viewModel.connectedSessionId!,
              'currentUserId': viewModel.currentUserId,
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast('Failed to connect: ${e.toString()}');
      }
    }
  }

  // ... rest of the build method remains the same
  @override
  Widget build(BuildContext context) {
    return Consumer<QrPairingViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Scan QR Code'),
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Point your camera at a QR code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1D1D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Position the QR code within the frame to connect',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6E7C8C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (viewModel.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            viewModel.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ScanQRCode(onScanned: _handleScannedCode),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xFF6E7C8C).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF6E7C8C),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Make sure the QR code is well lit and in focus',
                          style: TextStyle(
                            color: Color(0xFF6E7C8C),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}