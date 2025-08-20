import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerWidget extends StatefulWidget {
  final Function(String) onScanned;
  const QrScannerWidget({super.key, required this.onScanned});

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final barcode = capture.barcodes.first;
          if (!scanned && barcode.rawValue != null) {
            scanned = true;
            widget.onScanned(barcode.rawValue!);
          }
        },
      ),
    );
  }
}
