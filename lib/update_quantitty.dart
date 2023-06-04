import 'package:flutter/material.dart';
import 'auth.dart';

class UpdateQuantityPage extends StatefulWidget {
  final dynamic product;

  UpdateQuantityPage({required this.product});

  @override
  _UpdateQuantityPageState createState() => _UpdateQuantityPageState();
}

class _UpdateQuantityPageState extends State<UpdateQuantityPage> {
  final orpc = Auth.orpc;
  double currentQuantity = 0.0;
  double newQuantity = 0.0;

  @override
  void initState() {
    super.initState();
    fetchProductQuantity();
  }

  Future<void> fetchProductQuantity() async {
    try {
      setState(() {
        currentQuantity = widget.product['qty_available'];
        newQuantity = currentQuantity;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch product quantity.'),
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

  Future<void> updateProductQuantity() async {
    try {
      final response = await orpc?.callKw({
        'model': 'stock.change.product.qty',
        'method': 'write',
        'args': [
          [widget.product['id']],
          {'new_quantity': newQuantity},
        ],
        'kwargs': {},
      });

      print('Product quantity updated successfully: $response');

      // Call the apply method to apply the changes
      final applyResponse = await orpc?.callKw({
        'model': 'stock.change.product.qty',
        'method': 'change_product_qty',
        'args': [
          [
            widget.product['id'],
          ],
        ],
        'kwargs': {},
      });

      print('Changes applied successfully: $applyResponse');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Product quantity updated successfully.'),
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
    } catch (e) {
      print(e.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update product quantity.'),
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
        title: Text('Modify Product'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(widget.product['name'].toString()),
            subtitle: Row(
              children: [
                Text('Current Quantity: $currentQuantity'),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    initialValue: currentQuantity.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'New Quantity',
                    ),
                    onChanged: (value) {
                      setState(() {
                        newQuantity = double.parse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // Save the updated quantity
                updateProductQuantity();
              },
            ),
          ),
        ],
      ),
    );
  }
}
