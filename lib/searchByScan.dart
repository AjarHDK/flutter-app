import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'product_details.dart';

class BarcodeScannerPage extends StatefulWidget {
  final List<dynamic> products;

  BarcodeScannerPage({required this.products});

  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String scannedBarcode = '';

  Future<void> scanBarcode() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#FF0000', // Custom color for the scanner overlay
        'Cancel', // Cancel button text
        false, // Show flash icon
        ScanMode.DEFAULT, // Scan mode
      );

      if (barcode != '-1') {
        setState(() {
          scannedBarcode = barcode;
        });
        navigateToProductDetailsByBarcode(scannedBarcode);
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to scan barcode.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void navigateToProductDetailsByBarcode(String barcode) {
    // Find the product with the matching barcode
    dynamic scannedProduct = widget.products.firstWhere(
      (product) => product['barcode'] == barcode,
      orElse: () => null,
    );

    if (scannedProduct != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsPage(product: scannedProduct),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Product Not Found'),
            content: Text('The scanned barcode does not match any product.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () {
              // Implement flash functionality
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scanned Barcode:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              scannedBarcode,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Scan Barcode'),
              onPressed: scanBarcode,
            ),
          ],
        ),
      ),
    );
  }
}
