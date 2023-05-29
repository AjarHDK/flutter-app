import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductDetailsPage extends StatelessWidget {
  final dynamic product;

  const ProductDetailsPage({required this.product});

  @override
  Widget build(BuildContext context) {
    List<int> imageBytes = [];

    if (product['image_1920'] is String && product['image_1920'].isNotEmpty) {
      imageBytes = base64.decode(product['image_1920']);
    }

    Uint8List imageUint8List = Uint8List.fromList(imageBytes);

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: ${product['list_price']}'),
                      Text('Standard Price: ${product['standard_price']}'),
                      Text('Quantity Available: ${product['qty_available']}'),
                      Text('Virtual Quantity: ${product['virtual_available']}'),
                      Text('Responsible: ${product['responsible_id']}'),
                      Text('ID: ${product['id']}'),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                imageBytes.isNotEmpty
                    ? Image.memory(
                        imageUint8List,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
