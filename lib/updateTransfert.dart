import 'package:flutter/material.dart';
import 'auth.dart';

class UpdateTransfertPage extends StatefulWidget {
  final dynamic reception;
  final dynamic additionalItem;

  UpdateTransfertPage({required this.reception, required this.additionalItem});

  @override
  _UpdateTransfertPageState createState() => _UpdateTransfertPageState();
}

class _UpdateTransfertPageState extends State<UpdateTransfertPage> {
  final orpc = Auth.orpc;
  TextEditingController quantityDemandeeController = TextEditingController();
  TextEditingController quantityDoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the initial values for the text fields
    quantityDemandeeController.text =
        widget.additionalItem['product_uom_qty'].toString();
    quantityDoneController.text =
        widget.additionalItem['quantity_done'].toString();
  }

  @override
  void dispose() {
    // Dispose of the text editing controllers
    quantityDemandeeController.dispose();
    quantityDoneController.dispose();
    super.dispose();
  }

  Future<void> updateMoveLine() async {
    final int moveLineId = widget.additionalItem['id'];
    final double quantityDemandee =
        double.parse(quantityDemandeeController.text);
    final double quantityDone = double.parse(quantityDoneController.text);

    try {
      await orpc?.callKw({
        'model': 'stock.move',
        'method': 'write',
        'args': [
          [moveLineId],
          {
            'product_uom_qty': quantityDemandee,
            'quantity_done': quantityDone,
          },
        ],
        'kwargs': {},
      });

      await orpc?.callKw({
        'model': 'stock.picking',
        'method': 'action_confirm',
        'args': [
          [widget.additionalItem['picking_id'][0]], // Pass the picking ID
        ],
        'kwargs': {},
      });

      await orpc?.callKw({
        'model': 'stock.picking',
        'method': 'button_validate',
        'args': [
          [widget.additionalItem['picking_id'][0]], // Pass the picking ID
        ],
        'kwargs': {},
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Move Line updated successfully.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to the previous page
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
            content: Text('Failed to update Move Line.'),
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
      appBar: AppBar(title: Text('Update Transfert')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: ${widget.reception['product_id'][1]}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Quantity demandée:'),
            TextField(
              controller: quantityDemandeeController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text('Quantity done:'),
            TextField(
              controller: quantityDoneController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: updateMoveLine,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
