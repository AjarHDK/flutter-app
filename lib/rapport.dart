import 'package:flutter/material.dart';
import 'auth.dart';

class RapportPage extends StatefulWidget {
  @override
  _RapportPageState createState() => _RapportPageState();
}

class _RapportPageState extends State<RapportPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> _validatedDeliveries = [];
  List<dynamic> _validatedReceptions = [];
  List<dynamic> _validatedInternals = [];
  bool _isLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchValidatedDeliveries();
    fetchValidatedReceptions();
    fetchValidatedInternals();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> fetchValidatedDeliveries() async {
    final orpc = Auth.orpc;
    String modelPicking = 'stock.picking';

    dynamic validatedDeliveries = await orpc?.callKw({
      'model': modelPicking,
      'method': 'search_read',
      'args': [
        [
          ['state', '=', 'done'],
          ['picking_type_code', '=', 'outgoing'], // Filter by delivery
        ],
        [
          'name',
          'location_id',
          'location_dest_id',
          'create_date',
          'write_date',
          'picking_type_code',
        ],
      ],
      'kwargs': {},
    });

    if (validatedDeliveries != null) {
      setState(() {
        _validatedDeliveries = validatedDeliveries;
        _isLoading = false;
      });
    }
  }

  Future<void> fetchValidatedReceptions() async {
    final orpc = Auth.orpc;
    String modelPicking = 'stock.picking';

    dynamic validatedReceptions = await orpc?.callKw({
      'model': modelPicking,
      'method': 'search_read',
      'args': [
        [
          ['state', '=', 'done'],
          ['picking_type_code', '=', 'incoming'], // Filter by reception
        ],
        [
          'name',
          'location_id',
          'location_dest_id',
          'create_date',
          'write_date',
          'picking_type_code',
        ],
      ],
      'kwargs': {},
    });

    if (validatedReceptions != null) {
      setState(() {
        _validatedReceptions = validatedReceptions;
        _isLoading = false;
      });
    }
  }

  Future<void> fetchValidatedInternals() async {
    final orpc = Auth.orpc;
    String modelPicking = 'stock.picking';

    dynamic validatedInternals = await orpc?.callKw({
      'model': modelPicking,
      'method': 'search_read',
      'args': [
        [
          ['state', '=', 'done'],
          ['picking_type_code', '=', 'internal'], // Filter by internal
        ],
        [
          'name',
          'location_id',
          'location_dest_id',
          'create_date',
          'write_date',
          'picking_type_code',
        ],
      ],
      'kwargs': {},
    });

    if (validatedInternals != null) {
      setState(() {
        _validatedInternals = validatedInternals;
        _isLoading = false;
      });
    }
  }

  Widget _buildDeliveryList() {
    return ListView.builder(
      itemCount: _validatedDeliveries.length,
      itemBuilder: (context, index) {
        dynamic delivery = _validatedDeliveries[index];
        String pickingName = delivery['name'] ?? '';
        dynamic createDate = delivery['create_date'] ?? '';
        dynamic writeDate = delivery['write_date'] ?? '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  pickingName: pickingName,
                  createDate: createDate,
                  writeDate: writeDate,
                  type: 'Delivery',
                ),
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.local_shipping), // Delivery icon
            title: Text('Picking Name: $pickingName'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: Delivery'),
                Text('Create Date: $createDate'),
                Text('Write Date: $writeDate'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceptionList() {
    return ListView.builder(
      itemCount: _validatedReceptions.length,
      itemBuilder: (context, index) {
        dynamic reception = _validatedReceptions[index];
        String pickingName = reception['name'] ?? '';
        dynamic createDate = reception['create_date'] ?? '';
        dynamic writeDate = reception['write_date'] ?? '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  pickingName: pickingName,
                  createDate: createDate,
                  writeDate: writeDate,
                  type: 'Reception',
                ),
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.download), // Reception icon
            title: Text('Picking Name: $pickingName'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: Reception'),
                Text('Create Date: $createDate'),
                Text('Write Date: $writeDate'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInternalList() {
    return ListView.builder(
      itemCount: _validatedInternals.length,
      itemBuilder: (context, index) {
        dynamic internal = _validatedInternals[index];
        String pickingName = internal['name'] ?? '';
        dynamic createDate = internal['create_date'] ?? '';
        dynamic writeDate = internal['write_date'] ?? '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  pickingName: pickingName,
                  createDate: createDate,
                  writeDate: writeDate,
                  type: 'Internal Transfer',
                ),
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.swap_horiz), // Internal transfer icon
            title: Text('Picking Name: $pickingName'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: Internal Transfer'),
                Text('Create Date: $createDate'),
                Text('Write Date: $writeDate'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapport'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.local_shipping), // Delivery icon
              text: 'Delivery',
            ),
            Tab(
              icon: Icon(Icons.download), // Reception icon
              text: 'Reception',
            ),
            Tab(
              icon: Icon(Icons.swap_horiz), // Internal transfer icon
              text: 'Internal',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDeliveryList(),
                _buildReceptionList(),
                _buildInternalList(),
              ],
            ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final String pickingName;
  final dynamic createDate;
  final dynamic writeDate;
  final String type;

  DetailsPage({
    required this.pickingName,
    required this.createDate,
    required this.writeDate,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Picking Name: $pickingName'),
            Text('Type: $type'),
            Text('Create Date: $createDate'),
            Text('Write Date: $writeDate'),
          ],
        ),
      ),
    );
  }
}
