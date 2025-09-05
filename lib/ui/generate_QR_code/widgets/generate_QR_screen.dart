import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/toast_utils.dart';  // Add this import
import '../../qr_pairing/view_model/qr_pairing_view_model.dart';
import 'generate_QR_code.dart';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  bool _navigationHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<QrPairingViewModel>(context, listen: false);
      viewModel.resetSession();
      viewModel.generateSessionWithToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QrPairingViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.hasOtherUsers &&
              viewModel.sessionId != null &&
              mounted &&
              !_navigationHandled) {

            _navigationHandled = true;

            // Show success toast for QR holder
            ToastUtils.showSuccessToast("Someone connected to your QR code! 🎉");

            ScaffoldMessenger.of(context).clearSnackBars();
            // viewModel.setActiveSession(viewModel.sessionId!);

            Navigator.pushReplacementNamed(
              context,
              '/chat',
              arguments: {
                'sessionId': viewModel.sessionId!,
                'currentUserId': viewModel.currentUserId,
              },
            );
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('My QR Code'),
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _navigationHandled = false;
                  });
                  viewModel.resetSession();
                  viewModel.generateSessionWithToken();
                  ToastUtils.showInfoToast("QR code refreshed");
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          // ... rest of the build method remains the same
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
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

                    if (viewModel.sessionId != null) ...[
                      const Text(
                        'Share Your QR Code',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1D1D),
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
                          child: GenerateQRCode(sessionId: viewModel.sessionId!),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.qr_code, color: Colors.white),
                          label: const Text(
                            'Generate New QR Code',
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
                          onPressed: () {
                            setState(() {
                              _navigationHandled = false;
                            });
                            viewModel.resetSession();
                            viewModel.generateSessionWithToken();
                            ToastUtils.showInfoToast("New QR code generated");
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: viewModel.hasOtherUsers
                              ? const Color(0xFF2ECC71).withOpacity(0.1)
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: viewModel.hasOtherUsers
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFF6E7C8C).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: viewModel.hasOtherUsers
                                    ? const Color(0xFF2ECC71)
                                    : const Color(0xFF6E7C8C),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              viewModel.hasOtherUsers
                                  ? 'Someone connected!'
                                  : 'Waiting for connection...',
                              style: TextStyle(
                                color: viewModel.hasOtherUsers
                                    ? const Color(0xFF2ECC71)
                                    : const Color(0xFF6E7C8C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const CircularProgressIndicator(
                        color: Color(0xFF2ECC71),
                      ),
                      const SizedBox(height: 20),
                      const Text('Creating your QR code...'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}