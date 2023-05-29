import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'auth.dart';

class ModifyProductPage extends StatefulWidget {
  final dynamic product;

  ModifyProductPage({required this.product});

  @override
  _ModifyProductPageState createState() => _ModifyProductPageState();
}

class _ModifyProductPageState extends State<ModifyProductPage> {
  final orpc = Auth.orpc;
  late TextEditingController nameController;
  late TextEditingController listPriceController;
  late TextEditingController standardPriceController;
  late TextEditingController qtyAvailableController;
  late TextEditingController virtualAvailableController;
  late TextEditingController defaultCodeController;
  late TextEditingController weightController;
  late TextEditingController volumeController;
  late TextEditingController barcodeController;
  late TextEditingController saleDelayController;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product['name'] ?? '');
    listPriceController = TextEditingController(
        text: widget.product['list_price']?.toString() ?? '');
    standardPriceController = TextEditingController(
        text: widget.product['standard_price']?.toString() ?? '');
    qtyAvailableController = TextEditingController(
        text: widget.product['qty_available']?.toString() ?? '');
    virtualAvailableController = TextEditingController(
        text: widget.product['virtual_available']?.toString() ?? '');

    weightController =
        TextEditingController(text: widget.product['weight']?.toString() ?? '');
    volumeController =
        TextEditingController(text: widget.product['volume']?.toString() ?? '');
    saleDelayController = TextEditingController(
        text: widget.product['sale_delay']?.toString() ?? '');
    defaultCodeController = TextEditingController(
      text: widget.product['default_code'] == false
          ? ''
          : widget.product['default_code'].toString(),
    );
    barcodeController = TextEditingController(
      text: widget.product['barcode'] == false
          ? ''
          : widget.product['barcode'].toString(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    listPriceController.dispose();
    standardPriceController.dispose();
    qtyAvailableController.dispose();
    virtualAvailableController.dispose();
    defaultCodeController.dispose();
    weightController.dispose();
    volumeController.dispose();
    barcodeController.dispose();
    saleDelayController.dispose();
    super.dispose();
  }

  Future<void> updateProduct() async {
    final updatedData = {
      'name': nameController.text,
      'list_price': double.parse(listPriceController.text),
      'standard_price': double.parse(standardPriceController.text),
      'qty_available': double.parse(qtyAvailableController.text),
      'virtual_available': double.parse(virtualAvailableController.text),
      'default_code': defaultCodeController.text,
      'weight': double.parse(weightController.text),
      'volume': double.parse(volumeController.text),
      'barcode': barcodeController.text,
      'sale_delay': double.parse(saleDelayController.text),
      'image_1920': imageFile != null
          ? base64Encode(await imageFile!.readAsBytes())
          : widget.product['image_1920'],
    };

    try {
      final response = await orpc?.callKw({
        'model': 'product.template',
        'method': 'write',
        'args': [
          [widget.product['id']],
          updatedData,
        ],
        'kwargs': {}
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
            content: Text('Failed to update product.'),
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

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _importPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageFile != null)
              Image.file(
                imageFile!,
                height: 200.0,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: Icon(Icons.camera),
                  label: Text('Take Photo'),
                ),
                ElevatedButton.icon(
                  onPressed: _importPhoto,
                  icon: Icon(Icons.photo_library),
                  label: Text('Import Photo'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: listPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'List Price',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: standardPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Standard Price',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: qtyAvailableController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity Available',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: virtualAvailableController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Virtual Available',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: volumeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Volume',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: saleDelayController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sale Delay',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: barcodeController,
              decoration: InputDecoration(
                labelText: 'Barcode',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: defaultCodeController,
              decoration: InputDecoration(
                labelText: 'Default Code',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: updateProduct,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
