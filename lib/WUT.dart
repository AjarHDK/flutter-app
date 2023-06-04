import 'package:flutter/material.dart';
import 'auth.dart';

class upPage extends StatefulWidget {
  @override
  _upPageState createState() => _upPageState();
}

class _upPageState extends State<upPage> {
  final orpc = Auth.orpc;
  List<dynamic> productList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await orpc?.callKw({
        'model': 'product.template',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['id', 'name', 'qty_available'],
        },
      });
      if (response is List && response.isNotEmpty) {
        setState(() {
          productList = response;
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch products.'),
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

  Future<void> updateProductQuantity(int index, double newQuantity) async {
    final product = productList[index];

    try {
      final response = await orpc?.callKw({
        'model': 'stock.change.product.qty',
        'method': 'write',
        'args': [
          [product['id']],
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
          [product['id']],
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
          Expanded(
            child: ListView.builder(
              itemCount: productList.length,
              itemBuilder: (BuildContext context, int index) {
                final product = productList[index];
                final productID = product['id'].toString();
                final currentQuantity = product['qty_available'];
                print('productID');

                return ListTile(
                  title: Text(productID),
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
                            // Update the quantity locally
                            productList[index]['new_quantity'] =
                                double.parse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      // Save the updated quantity
                      final newQuantity = productList[index]['new_quantity'];

                      updateProductQuantity(index, newQuantity);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
