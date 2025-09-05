// lib/ui/home_page/widgets/homepage.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo & Title
                const Column(
                  children: [
                    SizedBox(height: 8),
                    Text(
                      "YapYap",
                      style: TextStyle(
                        color: Color(0xFF2ECC71),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Connect instantly with QR codes",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6E7C8C),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Illustration
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 150,
                    maxHeight: 200,
                  ),
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
                  child: Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.contain,
                        height: 120,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Headline
                const Text(
                  "Start Chatting in Seconds",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1D1D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Generate a QR code or scan one to instantly\nconnect with someone nearby",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6E7C8C),
                  ),
                ),

                const SizedBox(height: 30),

                // Generate QR Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/generate-qr');
                    },
                    icon: const Icon(Icons.qr_code, color: Colors.white),
                    label: const Text(
                      "My QR Code",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Scan QR Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/scan-qr');
                    },
                    icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF2ECC71)),
                    label: const Text(
                      "Scan QR Code",
                      style: TextStyle(color: Color(0xFF2ECC71)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2ECC71), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Go to My Chats Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/my-chats');
                    },
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                    label: const Text(
                      "Go to My Chats",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}