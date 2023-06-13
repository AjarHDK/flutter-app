import 'package:flutter/material.dart';
import 'auth.dart';
import 'notification_helper.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final orpc = Auth.orpc;
  List<dynamic> pendingReceptions = [];
  List<dynamic> pendingDeliveries = [];
  List<dynamic> pendingTransfers = [];

  @override
  void initState() {
    super.initState();
    fetchOperations();
  }

  Future<void> fetchOperations() async {
    try {
      final receptionResponse = await orpc?.callKw({
        'model': 'stock.picking',
        'method': 'search_read',
        'args': [
          [
            ['picking_type_code', '=', 'incoming']
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

      final deliveryResponse = await orpc?.callKw({
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

      final transferResponse = await orpc?.callKw({
        'model': 'stock.picking',
        'method': 'search_read',
        'args': [
          [
            ['picking_type_code', '=', 'internal']
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

      setState(() {
        pendingReceptions = receptionResponse
            .where((reception) => reception['state'] != 'done')
            .toList();
        pendingDeliveries = deliveryResponse
            .where((delivery) => delivery['state'] != 'done')
            .toList();
        pendingTransfers = transferResponse
            .where((transfer) => transfer['state'] != 'done')
            .toList();
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch operations.'),
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

  void navigateToItemsPage(List<dynamic> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsPage(items),
      ),
    );
  }

  void navigateToNotificationsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPage(
            notifications: NotificationHelper.receivedNotifications),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: navigateToNotificationsPage,
          ),
        ],
      ),
      body: Column(
        children: [
          buildOperationContainer(
            'Receptions',
            pendingReceptions.length.toString(),
            () {
              setState(() {
                // Filter reception items based on the picking_type_id
                List<dynamic> receptionItems = pendingReceptions
                    .where((reception) =>
                        reception['picking_type_id'][0] ==
                        1) // Compare with an integer value (1) instead of a string ('incoming')
                    .toList();

                navigateToItemsPage(receptionItems);
              });
            },
          ),
          buildOperationContainer(
            'Deliveries',
            pendingDeliveries.length.toString(),
            () {
              setState(() {
                // Filter delivery items based on the picking_type_id
                List<dynamic> deliveryItems = pendingDeliveries
                    .where((delivery) =>
                        delivery['picking_type_id'][0] ==
                        2) // Compare with an integer value (2) instead of a string ('outgoing')
                    .toList();

                navigateToItemsPage(deliveryItems);
              });
            },
          ),
          buildOperationContainer(
            'Internal Transfers',
            pendingTransfers.length.toString(),
            () {
              setState(() {
                // Filter internal transfer items based on the picking_type_id
                List<dynamic> transferItems = pendingTransfers
                    .where((transfer) =>
                        transfer['picking_type_id'][0] ==
                        3) // Compare with an integer value (3) instead of a string ('internal')
                    .toList();

                navigateToItemsPage(transferItems);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildOperationContainer(
    String operationName,
    String itemCount,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                operationName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Items: $itemCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemsPage extends StatelessWidget {
  final List<dynamic> items;

  ItemsPage(this.items);

  @override
  Widget build(BuildContext context) {
    print(items);

    return Scaffold(
      appBar: AppBar(title: Text('Items')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item['name']), // Use the 'name' field from the item
            subtitle: Text(item['product_id'][1] ??
                ''), // Use the 'product_id'[1] field from the item
            onTap: () {
              // Handle item tap
            },
          );
        },
      ),
    );
  }
}

class NotificationPage extends StatelessWidget {
  static const String routeName = '/notifications';

  final List<NotificationModel> notifications;
  NotificationPage({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final timestamp = notification.timestamp;
          final formattedDateTime = DateFormat.yMd()
              .add_jm()
              .format(timestamp); // Format the DateTime

          return ListTile(
            title: Text(notification.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body),
                SizedBox(height: 4),
                Text(
                  'Timestamp: $formattedDateTime',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(notification.title),
                    content: Text(notification.body),
                    actions: [
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
