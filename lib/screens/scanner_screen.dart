import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barkod Okuyucu')),
      body: MobileScanner(
        onDetect: (capture) async {
          final List<Barcode> barcodes = capture.barcodes;

          if (_isProcessing || barcodes.isEmpty) return;

          final barcode = barcodes.first;
          if (barcode.rawValue == null) return;

          setState(() {
            _isProcessing = true;
          });

          final String scannedValue = barcode.rawValue!;

          final product = await context.read<ProductProvider>().checkBarcode(
            scannedValue,
          );

          if (!context.mounted) return;

          if (product != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            ).then((_) {
              if (context.mounted) {
                setState(() {
                  _isProcessing = false;
                });
              }
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(scannedBarcode: scannedValue),
              ),
            ).then((_) {
              if (context.mounted) {
                setState(() {
                  _isProcessing = false;
                });
              }
            });
          }
        },
      ),
    );
  }
}
