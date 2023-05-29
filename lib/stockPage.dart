import 'package:flutter/material.dart';
import 'auth.dart';
import 'dart:convert';
import 'dart:typed_data';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final orpc = Auth.orpc;
  List<dynamic> stocks = [];
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchStock();
  }

  Future<void> fetchStock() async {
    try {
      final response = await orpc?.callKw({
        'model': 'product.product',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'display_name',
            'qty_available',
            'free_qty',
            'incoming_qty',
            'outgoing_qty',
            'list_price'
          ],
        },
      });
      setState(() {
        stocks = response;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch stock.'),
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

  void navigateToStockDetails(dynamic stock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailsPage(
          stock: stock,
        ),
      ),
    ).then((result) {
      if (result == true) {
        fetchStock(); // Refresh the stock list after modifications
      }
    });
  }

  Map<String, double> getTotalQtyAvailable() {
    double totalQty = 0;
    double totalPrice = 0;

    for (final stock in stocks) {
      final product = products.firstWhere(
        (p) => p['name'] == stock['display_name'],
        orElse: () => null,
      );
      if (product != null) {
        final incomingQty = stock['incoming_qty'];
        final outgoingQty = stock['outgoing_qty'];
        final listPrice = stock['list_price'];

        final qtyAvailable = product['qty_available'];
        if (qtyAvailable is double) {
          totalQty += qtyAvailable;
          totalPrice += (incomingQty - outgoingQty) * listPrice;
        }
      }
    }

    return {'totalQty': totalQty, 'totalPrice': totalPrice};
  }

  Widget buildStockItem(dynamic stock, dynamic product) {
    List<int> imageBytes = [];

    if (product != null &&
        product['image_1920'] != null &&
        product['image_1920'] is String &&
        product['image_1920'].isNotEmpty) {
      imageBytes = base64.decode(product['image_1920']);
    }
    Uint8List imageUint8List = Uint8List.fromList(imageBytes);

    final String stockName = stock['display_name'];
    final double incomingQty = stock['incoming_qty'];
    final double outgoingQty = stock['outgoing_qty'];
    final double listPrice = stock['list_price'];

    return InkWell(
      onTap: () {
        navigateToStockDetails(stock);
      },
      child: Card(
        child: ListTile(
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
          title: Text(stockName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product != null)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${incomingQty.toStringAsFixed(2)} (',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'IN ',
                        style:
                            TextStyle(color: Color.fromARGB(255, 244, 97, 5)),
                      ),
                      TextSpan(
                        text: ') - ${outgoingQty.toString()} (',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'OUT',
                        style:
                            TextStyle(color: Color.fromARGB(178, 14, 198, 21)),
                      ),
                      TextSpan(
                        text: ') = ${(incomingQty - outgoingQty)}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.yellow),
                  SizedBox(
                      width: 5), // Add some spacing between the icon and text
                  Text(
                    '${(incomingQty - outgoingQty)} x ${listPrice.toStringAsFixed(2)} = ${(incomingQty - outgoingQty) * listPrice}',
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.inventory,
                            color: Color.fromARGB(223, 8, 118, 11)),
                        SizedBox(
                            width:
                                5), // Add some spacing between the icon and text
                        Text('${product?['qty_available'] ?? ''}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.bar_chart,
                            color: Color.fromARGB(255, 19, 118, 198)),
                        SizedBox(
                            width:
                                5), // Add some spacing between the icon and text
                        Text('${product?['virtual_available'] ?? ''}'),
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
              Icons.more_vert,
              color: Colors.grey,
            ),
            onPressed: () {
              navigateToStockDetails(stock);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalStock = getTotalQtyAvailable();
    final totalQty = totalStock['totalQty'];
    final totalPrice = totalStock['totalPrice'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Text(
                  'Total Qty Available: $totalQty',
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                Text(
                  'Total Price: $totalPrice',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: stocks.length,
              itemBuilder: (BuildContext context, int index) {
                final stock = stocks[index];
                final product = products.firstWhere(
                  (p) => p['name'] == stock['display_name'],
                  orElse: () => null,
                );
                return buildStockItem(stock, product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StockDetailsPage extends StatelessWidget {
  final dynamic stock;

  const StockDetailsPage({Key? key, required this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Stock Name: ${stock['display_name']}'),
            Text('Qty Available: ${stock['qty_available']}'),
            Text('Free Qty: ${stock['free_qty']}'),
            Text('Incoming Qty: ${stock['incoming_qty']}'),
            Text('Outgoing Qty: ${stock['outgoing_qty']}'),
            Text('List Price: ${stock['list_price']}'),
          ],
        ),
      ),
    );
  }
}
