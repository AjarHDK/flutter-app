import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'auth.dart';

class NewProductPage extends StatefulWidget {
  final VoidCallback? onProductCreated; // Add the callback

  NewProductPage({this.onProductCreated});

  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final orpc = Auth.orpc;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _listPriceController = TextEditingController();
  TextEditingController _standardPriceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _virtualQuantityController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _volumeController = TextEditingController();
  TextEditingController _barcodeController = TextEditingController();
  TextEditingController _saleDelayController = TextEditingController();
  TextEditingController _defaultCodeController = TextEditingController();
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void createProduct() async {
    String name = _nameController.text;
    double listPrice = double.tryParse(_listPriceController.text) ?? 0.0;
    double standardPrice =
        double.tryParse(_standardPriceController.text) ?? 0.0;
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    int virtualQuantity = int.tryParse(_virtualQuantityController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double volume = double.tryParse(_volumeController.text) ?? 0.0;
    String barcode = _barcodeController.text;
    int saleDelay = int.tryParse(_saleDelayController.text) ?? 0;
    String defaultCode = _defaultCodeController.text;

    try {
      List<int>? imageBytes;
      if (_image != null) {
        imageBytes = await _image!.readAsBytes();
      }

      await orpc?.callKw({
        'model': 'product.template',
        'method': 'create',
        'args': [
          {
            'name': name,
            'list_price': listPrice,
            'standard_price': standardPrice,
            'qty_available': quantity,
            'virtual_available': virtualQuantity,
            'weight': weight,
            'volume': volume,
            'barcode': barcode,
            'sale_delay': saleDelay,
            'default_code': defaultCode,
            'image_1920': imageBytes != null ? base64Encode(imageBytes) : null,
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
    _nameController.dispose();
    _priceController.dispose();
    _listPriceController.dispose();
    _standardPriceController.dispose();
    _quantityController.dispose();
    _virtualQuantityController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _barcodeController.dispose();
    _saleDelayController.dispose();
    _defaultCodeController.dispose();

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
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _listPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'List Price',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _standardPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Standard Price',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity Available',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _virtualQuantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Virtual Quantity',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _volumeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Volume',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Code à barre',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _saleDelayController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sale Delay',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _defaultCodeController,
                decoration: InputDecoration(
                  labelText: 'Réference interne',
                ),
              ),
              SizedBox(height: 16.0),
              _image != null
                  ? Image.file(
                      _image!,
                      height: 100,
                    )
                  : Container(),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: Text('Take Photo'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: Text('Choose from Gallery'),
                  ),
                ],
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
