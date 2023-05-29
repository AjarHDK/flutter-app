import 'package:flutter/material.dart';
import 'auth.dart';

class DeleteProductPage extends StatefulWidget {
  final dynamic product;

  DeleteProductPage({required this.product});

  @override
  _DeleteProductPageState createState() => _DeleteProductPageState();
}

class _DeleteProductPageState extends State<DeleteProductPage> {
  final orpc = Auth.orpc;

  Future<void> deleteProduct() async {
    try {
      final response = await orpc?.callKw({
        'model': 'product.template',
        'method': 'unlink',
        'args': [
          [widget.product['id']],
        ],
        'kwargs': {}
      });

      print('Product deleted successfully: $response');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Product deleted successfully.'),
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
            content: Text('Failed to delete product.'),
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
        title: Text('Delete Product'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to delete this product?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: deleteProduct,
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
