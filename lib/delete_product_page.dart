import 'package:flutter/material.dart';
import 'auth.dart';

class ArchiveProductPage extends StatefulWidget {
  final dynamic product;

  ArchiveProductPage({required this.product});

  @override
  _ArchiveProductPageState createState() => _ArchiveProductPageState();
}

class _ArchiveProductPageState extends State<ArchiveProductPage> {
  final orpc = Auth.orpc;

  Future<void> archiveProduct() async {
    try {
      final response = await orpc?.callKw({
        'model': 'product.template',
        'method': 'write',
        'args': [
          [widget.product['id']],
          {
            'active': false
          }, // Champ 'active' mis à false pour archiver l'article
        ],
        'kwargs': {},
      });

      print('Product archived successfully: $response');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Product archived successfully.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to archive product.'),
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
        title: Text('Archive Product'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to archive this product?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: archiveProduct,
              child: Text('Archive'),
            ),
          ],
        ),
      ),
    );
  }
}
