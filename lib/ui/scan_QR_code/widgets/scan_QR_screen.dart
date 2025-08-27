import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../qr_pairing/view_model/qr_pairing_view_model.dart';
import 'scan_QR_code.dart';


class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  bool _scanHandled = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QrPairingViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                if (!viewModel.isConnected) ...[
                  // Scanning state
                  const Text(
                    'Scan to Connect',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1D1D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Point your camera at a QR code to instantly connect with someone',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6E7C8C),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
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
                      child: ScanQRCode(
                        onScanned: (sessionId) async {
                          if (_scanHandled) return;
                          _scanHandled = true;
                          final parts = sessionId.split('|');
                          if (parts.length != 2) {
                            _showError('Invalid QR code.', context);
                            return;
                          }
                          final expiresAt = int.tryParse(parts[1]);
                          if (expiresAt == null) {
                            _showError('Invalid QR code.', context);
                            return;
                          }
                          final now = DateTime.now().millisecondsSinceEpoch;
                          if (now > expiresAt) {
                            _showError('QR code expired. Please ask your friend to generate a new one.', context);
                            return;
                          }

                          await viewModel.connectToSession(sessionId);
                          if (viewModel.isConnected && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Successfully connected!',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: const Color(0xFF2ECC71),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );

                            // Navigate to chat after successful connection
                            Navigator.pushNamed(
                              context,
                              '/chat',
                              arguments: {
                                'sessionId': sessionId,
                                'currentUserId': viewModel.currentUserId,
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                ] else ...[
                  // Connected state
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2ECC71),
                          Color(0xFF4ECDC4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Connected Successfully!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1D1D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You are now connected and ready to start chatting',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6E7C8C),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _scanHandled = false;
                        });
                        viewModel.isConnected = false;
                        viewModel.notifyListeners();
                      },
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                      label: const Text(
                        'Scan Another QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}