import 'package:flutter/material.dart';
import 'auth.dart';
import 'updateTransfert.dart';
import 'newLivraison.dart';

class LivraisonPage extends StatefulWidget {
  @override
  State<LivraisonPage> createState() => _LivraisonPageState();
}

class _LivraisonPageState extends State<LivraisonPage> {
  final orpc = Auth.orpc;
  List<dynamic> receptions = [];
  List<dynamic> additionalData = [];

  @override
  void initState() {
    super.initState();
    fetchReception();
  }

  Future<void> fetchReception() async {
    try {
      final response = await orpc?.callKw({
        'model': 'stock.picking',
        'method': 'search_read',
        'args': [
          [
            ['picking_type_code', '=', 'outgoing']
          ],
        ],
        'kwargs': {
          'fields': [
            'id',
            'product_id',
            'name',
            'partner_id',
            'scheduled_date',
            'picking_type_id',
            'state',
          ],
        },
      });

      final additionalResponse = await orpc?.callKw({
        'model':
            'stock.move', // Replace 'other.model' with the actual model name
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'reference',
            'state',
            'product_uom_qty',
          ], // Replace with the desired fields
        },
      });

      setState(() {
        receptions = response;
        additionalData = additionalResponse;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch Receptions.'),
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
      appBar: AppBar(title: Text('Livraison'), actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewLivraisonPage(),
              ),
            );
          },
        ),
      ]),
      body: ListView.builder(
        itemCount: receptions.length,
        itemBuilder: (context, index) {
          final reception = receptions[index];
          return buildProductItem(reception, additionalData,
              context); // Pass additionalData as a parameter
        },
      ),
    );
  }
}

Widget buildProductItem(
    dynamic reception, List<dynamic> additionalData, BuildContext context) {
  // Add additionalData parameter
  final additionalItem = additionalData.firstWhere(
    (item) => item['reference'] == reception['name'],
    orElse: () => null,
  );

  return ListTile(
    title: Text(reception['name'] ?? ''),
    // subtitle: Text(reception['partner_id'][1].toString()),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('date: ${reception['scheduled_date'] ?? ''}'),
        Text('Status: ${reception['state']}'),
        Text('type operation: ${reception['picking_type_id'][1]}'),
        Text(
            'product: ${reception['product_id'] is bool ? 'none' : reception['product_id'][1].toString()}'),
        Text('id: ${reception['id'].toString()}'),
        if (additionalItem != null) ...[
          Text('quantity: ${additionalItem['product_uom_qty']}'),
        ],
      ],
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateTransfertPage(
            reception: reception,
            additionalItem: additionalItem,
          ),
        ),
      );
    },
  );
}
