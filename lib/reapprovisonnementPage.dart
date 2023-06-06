import 'package:flutter/material.dart';
import 'auth.dart';

class ReapprovisonnementPage extends StatefulWidget {
  final dynamic product;

  ReapprovisonnementPage({required this.product});

  @override
  _ReapprovisonnementPageState createState() => _ReapprovisonnementPageState();
}

class _ReapprovisonnementPageState extends State<ReapprovisonnementPage> {
  final orpc = Auth.orpc;
  TextEditingController QtyMinController = TextEditingController();
  TextEditingController QtyMaxController = TextEditingController();
  TextEditingController QtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the initial values for the text fields
    QtyMinController.text = widget.product['product_min_qty'].toString();
    QtyMaxController.text = widget.product['product_max_qty'].toString();
    QtyController.text = widget.product['qty_to_order'].toString();
  }

  @override
  void dispose() {
    // Dispose of the text editing controllers
    QtyMinController.dispose();
    QtyMaxController.dispose();
    QtyController.dispose();
    super.dispose();
  }

  Future<void> updateMoveLine() async {
    final double QtyMax = double.parse(QtyMaxController.text);
    final double QtyMin = double.parse(QtyMinController.text);
    final double QtyOnHand = double.parse(QtyController.text);
    final recordId = widget.product['id'];

    try {
      await orpc?.callKw({
        'model': 'stock.warehouse.orderpoint',
        'method': 'write',
        'args': [
          [recordId],
          {
            'product_max_qty': QtyMax,
            'product_min_qty': QtyMin,
            'qty_to_order': QtyOnHand,
          },
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product: ${widget.product['product_id'][1]}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: widget.product['qty_on_hand'].toString(),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Quantity Dispo:',
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: widget.product['qty_forecast'].toString(),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Quantity Prevu:',
                ),
              ),
              SizedBox(height: 16),
              Text('Quantity max:'),
              TextField(
                controller: QtyMaxController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Text('Quantity min:'),
              TextField(
                controller: QtyMinController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Text('Quantity dispo:'),
              TextField(
                controller: QtyController,
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
      ),
    );
  }
}
