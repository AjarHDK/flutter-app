import 'package:flutter/material.dart';
import 'auth.dart';

import 'modify_product.dart';
import 'product_details.dart';
import 'delete_product_page.dart';
import 'reapprovisonnementPage.dart';
import 'new_aprovisonnement.dart';

class ApprovisonnementPage extends StatefulWidget {
  @override
  _ApprovisonnementPageState createState() => _ApprovisonnementPageState();
}

class _ApprovisonnementPageState extends State<ApprovisonnementPage> {
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
        'model': 'stock.warehouse.orderpoint',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'product_id',
            'qty_on_hand',
            'qty_forecast',
            'product_min_qty',
            'product_max_qty',
            'qty_to_order',
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
        builder: (context) => NewAprovisonnementPage(
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
    final String ProductName = product['product_id'][1];
    final double QtyMin = product['product_min_qty'];
    final double QtyMax = product['product_max_qty'];
    final double QtyOnHand = product['qty_on_hand'];
    final double QtyPredicted = product['qty_forecast'];
    final double QtyOrdred = product['qty_to_order'];

    return ListTile(
      title: Text(
        ProductName,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product != null)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: ' ',
                    style: TextStyle(color: Color.fromARGB(255, 244, 97, 5)),
                  ),
                  TextSpan(
                    text: '',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: '',
                    style: TextStyle(color: Color.fromARGB(178, 14, 198, 21)),
                  ),
                  TextSpan(
                    text: '',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.inventory,
                        color: Color.fromARGB(223, 8, 118, 11)),
                    SizedBox(
                        width: 5), // Add some spacing between the icon and text
                    Text(QtyOnHand.toString()),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.trending_up,
                        color: Color.fromARGB(255, 19, 118, 198)),
                    SizedBox(
                        width: 5), // Add some spacing between the icon and text
                    Text(QtyPredicted.toString()),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green),
                    SizedBox(
                        width: 5), // Add some spacing between the icon and text
                    Text(QtyMax.toString()),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.red),

                    SizedBox(
                        width: 5), // Add some spacing between the icon and text
                    Text(QtyMin.toString()),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart,
                        color: Color.fromARGB(255, 61, 199, 51)),
                    SizedBox(
                        width: 5), // Add some spacing between the icon and text
                    Text(QtyOrdred.toString()),
                  ],
                ),
              ),
            ],
          ),
          if (product == null)
            Text(
              'Product details not found.',
              style: TextStyle(color: Colors.black),
            ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(actions: <Widget>[
                  TextButton(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Hello'),
                        ),
                        Container(
                          child: Column(
                            children: [
                              SizedBox(
                                child: Text('This is the first text.'),
                              ),
                              SizedBox(
                                  height:
                                      20), // Adding some spacing between the text and button
                              ElevatedButton(
                                onPressed: () => {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ReapprovisonnementPage(
                                                product: product)),
                                  ),
                                },
                                child: Text('Edit'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
              });
        },
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
          .where((product) => product['product_id']
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
    return ListTile(
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
