import 'package:flutter/material.dart';
import 'auth.dart';
import 'new_product.dart';
import 'modify_product.dart';
import 'product_details.dart';
import 'delete_product_page.dart';
import 'searchByScan.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final orpc = Auth.orpc;
  List<dynamic> products = [];

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
          'fields': [
            'id',
            'name',
            'list_price',
            'standard_price',
            'qty_available',
            'virtual_available',
            'responsible_id',
            'categ_id',
            'default_code',
            'weight',
            'volume',
            'barcode',
            'sale_delay',
            'detailed_type',
            'image_1920',
          ],
        },
      });
      setState(() {
        products = response;
      });
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

  void navigateToProductDetails(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(product: product),
      ),
    );
  }

  void navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewProductPage(
          onProductCreated: () {
            fetchProducts(); // Refresh the product list when a new product is created
          },
        ),
      ),
    );
  }

  void navigateToScannedProductDetails(String barcode) {
    // Find the product with the matching barcode
    dynamic scannedProduct = products.firstWhere(
      (product) => product['barcode'] == barcode,
      orElse: () => null,
    );

    if (scannedProduct != null) {
      navigateToProductDetails(scannedProduct);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Product Not Found'),
            content: Text('The scanned barcode does not match any product.'),
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

  void navigateToModifyProduct(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyProductPage(
          product: product,
        ),
      ),
    ).then((result) {
      if (result == true) {
        fetchProducts(); // Refresh the product list after modifications
      }
    });
  }

  void navigateToDeleteProduct(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchiveProductPage(product: product),
      ),
    ).then((result) {
      if (result == true) {
        fetchProducts(); // Refresh the product list after modifications
      }
    });
  }

  void deleteProduct(dynamic product) {
    // Implement logic to delete the product
  }

  Widget buildProductItem(dynamic product) {
    List<int> imageBytes = [];

    if (product['image_1920'] is String && product['image_1920'].isNotEmpty) {
      imageBytes = base64.decode(product['image_1920']);
    }

    Uint8List imageUint8List = Uint8List.fromList(imageBytes);

    return ListTile(
      leading: imageBytes.isNotEmpty
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
      title: Text(
        product['name'],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.orange,
            ),
            onPressed: () => navigateToModifyProduct(product),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () => navigateToDeleteProduct(product),
          ),
          IconButton(
            icon: Icon(
              Icons.details,
              color: Colors.green,
            ),
            onPressed: () => navigateToProductDetails(product),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: navigateToAddProduct,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductSearchPage(products: products),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodeScannerPage(
                    products: products,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return buildProductItem(product);
        },
      ),
    );
  }
}

class ProductSearchPage extends StatefulWidget {
  final List<dynamic> products;

  ProductSearchPage({required this.products});

  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];

  void performSearch() {
    String searchText = searchController.text.trim();
    setState(() {
      searchResults = widget.products
          .where((product) => product['name']
              .toString()
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void navigateToProductDetails(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(product: product),
      ),
    );
  }

  void navigateToModifyProduct(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyProductPage(
          product: product,
        ),
      ),
    ).then((result) {
      if (result == true) {
        performSearch(); // Refresh the search results after modifications
      }
    });
  }

  void navigateToDeleteProduct(dynamic product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchiveProductPage(product: product),
      ),
    ).then((result) {
      if (result == true) {
        performSearch(); // Refresh the search results after modifications
      }
    });
  }

  Widget buildProductItem(dynamic product) {
    List<int> imageBytes = [];

    if (product['image_1920'] is String && product['image_1920'].isNotEmpty) {
      imageBytes = base64.decode(product['image_1920']);
    }

    Uint8List imageUint8List = Uint8List.fromList(imageBytes);

    return ListTile(
      leading: imageBytes.isNotEmpty
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
      title: Text(
        product['name'],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => navigateToModifyProduct(product),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => navigateToDeleteProduct(product),
          ),
          IconButton(
            icon: Icon(Icons.details),
            onPressed: () => navigateToProductDetails(product),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: performSearch,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final product = searchResults[index];
                return buildProductItem(product);
              },
            ),
          ),
        ],
      ),
    );
  }
}
