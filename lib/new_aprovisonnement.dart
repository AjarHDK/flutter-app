import 'package:flutter/material.dart';
import 'auth.dart';

class ProductTemplate {
  final int id;
  final String name;

  ProductTemplate({required this.id, required this.name});
}

class NewAprovisonnementPage extends StatefulWidget {
  final VoidCallback? onProductCreated; // Add the callback

  NewAprovisonnementPage({this.onProductCreated});

  @override
  _NewAprovisonnementPageState createState() => _NewAprovisonnementPageState();
}

class _NewAprovisonnementPageState extends State<NewAprovisonnementPage> {
  final orpc = Auth.orpc;

  TextEditingController _QtyMinController = TextEditingController();
  TextEditingController _QtyMaxController = TextEditingController();
  TextEditingController _QtyToOrderController = TextEditingController();

  String? selectedProduct; // Variable to store the selected product
  List<String> productNames = []; // List of product names
  List<ProductTemplate> _productTemplates = [];
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    fetchProductNames();
  }

  Future<void> fetchProductNames() async {
    String modelProduct = 'product.template';
    String modelApprovisionement = 'stock.warehouse.orderpoint';

    // Fetch existing approvisionements
    List<dynamic> existingApprovisionements = await orpc?.callKw({
      'model': modelApprovisionement,
      'method': 'search_read',
      'args': [
        [],
        ['product_id'],
      ],
      'kwargs': {},
    });

    List<int> existingProductIds = existingApprovisionements
        .map<int>((approvisionement) => approvisionement['product_id'][0])
        .toList();

    // Fetch all product templates
    List<dynamic> results = await orpc?.callKw({
      'model': modelProduct,
      'method': 'search_read',
      'args': [
        [],
        ['id', 'display_name'],
      ],
      'kwargs': {},
    });

    setState(() {
      _productTemplates = results
          .map((record) => ProductTemplate(
                id: record['id'],
                name: record['display_name'],
              ))
          .where((template) => !existingProductIds
              .contains(template.id)) // Filter out existing products
          .toList();
    });
  }

  void createProduct() async {
    double QtyMax = double.tryParse(_QtyMaxController.text) ?? 0.0;
    double QtyMin = double.tryParse(_QtyMinController.text) ?? 0.0;
    int QtyToOrder = int.tryParse(_QtyToOrderController.text) ?? 0;

    try {
      await orpc?.callKw({
        'model': 'stock.warehouse.orderpoint',
        'method': 'create',
        'args': [
          {
            'product_id': _selectedProductId,
            'qty_on_hand': QtyMax,
            'qty_forecast': QtyMin,
            'product_min_qty': QtyToOrder,
          },
        ],
        'kwargs': {}
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Product created successfully.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onProductCreated?.call(); // Call the callback function

                  // Go back to the product list
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
            content: Text('Failed to create the product.'),
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
  void dispose() {
    _QtyMinController.dispose();
    _QtyMaxController.dispose();
    _QtyToOrderController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedProductId,
                onChanged: (value) {
                  setState(() {
                    _selectedProductId = value;
                  });
                },
                items: _productTemplates
                    .map((template) => DropdownMenuItem<int>(
                          value: template.id,
                          child: Text(template.name),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Product',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _QtyMinController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity min',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _QtyMaxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity max',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _QtyToOrderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity to order',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: createProduct,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
