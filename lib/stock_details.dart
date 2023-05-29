import 'package:flutter/material.dart';
import 'auth.dart';

class StockDetailsPage extends StatefulWidget {
  final dynamic stock;

  const StockDetailsPage({required this.stock});

  @override
  _StockDetailsPageState createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController qtyAvailableController = TextEditingController();
  TextEditingController freeQtyController = TextEditingController();
  TextEditingController incomingQtyController = TextEditingController();
  TextEditingController outgoingQtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeFields();
  }

  void initializeFields() {
    displayNameController.text = widget.stock['display_name'];
    qtyAvailableController.text = widget.stock['qty_available'].toString();
    freeQtyController.text = widget.stock['free_qty'].toString();
    incomingQtyController.text = widget.stock['incoming_qty'].toString();
    outgoingQtyController.text = widget.stock['outgoing_qty'].toString();
  }

  @override
  void dispose() {
    displayNameController.dispose();
    qtyAvailableController.dispose();
    freeQtyController.dispose();
    incomingQtyController.dispose();
    outgoingQtyController.dispose();
    super.dispose();
  }

  Future<void> updateStock() async {
    final orpc = Auth.orpc;
    // Assuming 'id' is the field representing the stock ID in the response

    final updatedData = {
      'display_name': displayNameController.text,
      'qty_available': double.parse(qtyAvailableController.text),
      'free_qty': double.parse(freeQtyController.text),
      'incoming_qty': double.parse(incomingQtyController.text),
      'outgoing_qty': double.parse(outgoingQtyController.text),
    };

    try {
      final response = await orpc?.callKw({
        'model': 'product.product',
        'method': 'write',
        'args': [
          [widget.stock['id']],
          updatedData,
        ],
        'kwargs': {},
      });
      print('Product updated successfully: $response');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Product updated successfully.'),
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
            content: Text('Failed to update stock.'),
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
        title: Text('Stock Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: qtyAvailableController,
              decoration: InputDecoration(labelText: 'Quantity Available'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: freeQtyController,
              decoration: InputDecoration(labelText: 'Free Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: incomingQtyController,
              decoration: InputDecoration(labelText: 'Incoming Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: outgoingQtyController,
              decoration: InputDecoration(labelText: 'Outgoing Quantity'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: updateStock,
              child: Text('Update Stock'),
            ),
          ],
        ),
      ),
    );
  }
}
