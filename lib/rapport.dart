import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'commande.dart';

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
  List<dynamic> additionalData = [];
  List<dynamic> receptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          'product_id',
          'location_id',
          'location_dest_id',
          'create_date',
          'write_date',
          'picking_type_code',
        ],
      ],
      'kwargs': {},
    });

    final additionalResponse = await orpc?.callKw({
      'model': 'stock.move',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'fields': [
          'id',
          'reference',
          'picking_id',
          'state',
          'product_uom_qty',
          'quantity_done',
        ],
      },
    });

    if (validatedDeliveries != null) {
      setState(() {
        _validatedDeliveries = validatedDeliveries;
        receptions = validatedDeliveries;
        additionalData = additionalResponse;
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
          'product_id',
          'location_id',
          'location_dest_id',
          'create_date',
          'write_date',
          'picking_type_code',
        ],
      ],
      'kwargs': {},
    });
    final additionalResponse = await orpc?.callKw({
      'model': 'stock.move',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'fields': [
          'id',
          'reference',
          'picking_id',
          'state',
          'product_uom_qty',
          'quantity_done',
        ],
      },
    });
    if (validatedReceptions != null) {
      setState(() {
        receptions = validatedReceptions;
        _validatedReceptions = validatedReceptions;
        additionalData = additionalResponse;
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
          'product_id',
          'location_id',
          'location_dest_id',
          'create_date',
          'write_date',
          'picking_type_code',
        ],
      ],
      'kwargs': {},
    });
    final additionalResponse = await orpc?.callKw({
      'model': 'stock.move',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'fields': [
          'id',
          'reference',
          'picking_id',
          'state',
          'product_uom_qty',
          'quantity_done',
        ],
      },
    });
    if (validatedInternals != null) {
      setState(() {
        receptions = validatedInternals;
        _validatedInternals = validatedInternals;
        additionalData = additionalResponse;
        _isLoading = false;
      });
    }
  }

  Widget _buildDeliveryList() {
    return ListView.builder(
      itemCount: _validatedDeliveries.length,
      itemBuilder: (context, index) {
        dynamic delivery = _validatedDeliveries[index];
        var productName = delivery['product_id'][1];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  reception: delivery,
                  additionalData: additionalData,
                ),
              ),
            );
          },
          child: Card(
            child: ListTile(
              title: Text('Delivery'),
              subtitle: Text(productName),
              leading: Icon(Icons.local_shipping),
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
        var productName = reception['product_id'][1];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  reception: reception,
                  additionalData: additionalData,
                ),
              ),
            );
          },
          child: Card(
            child: ListTile(
              title: Text('Reception'),
              subtitle: Text(productName),
              leading: Icon(Icons.check_box),
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
        var productName = internal['product_id'][1];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  reception: internal,
                  additionalData: additionalData,
                ),
              ),
            );
          },
          child: Card(
            child: ListTile(
              title: Text('Internal'),
              subtitle: Text(productName),
              leading: Icon(Icons.swap_horiz),
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
        title: Text('Bon de Mouvement'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                'Deliveries',
                style: TextStyle(
                    fontSize: 11), // Adjust the fontSize value as needed
              ),
            ),
            Tab(
              child: Text(
                'Receptions',
                style: TextStyle(
                    fontSize: 11), // Adjust the fontSize value as needed
              ),
            ),
            Tab(
              child: Text(
                'Internals',
                style: TextStyle(
                    fontSize: 11), // Adjust the fontSize value as needed
              ),
            ),
            Tab(
              child: Text(
                'Commande',
                style: TextStyle(
                    fontSize: 11), // Adjust the fontSize value as needed
              ),
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
                FournisseursPrPage(),
              ],
            ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final dynamic reception;
  final List<dynamic> additionalData;

  DetailsPage({required this.reception, required this.additionalData});

  List<DataRow> _buildRows() {
    List<DataRow> rows = [];

    // Add the reception/delivery/internal transfer details row
    rows.add(
      DataRow(
        cells: [
          DataCell(Text('Réference')),
          DataCell(Text(reception['name'])),
        ],
      ),
    );

    rows.add(
      DataRow(
        cells: [
          DataCell(Text('Opération')),
          DataCell(Text(reception['picking_type_code'])),
        ],
      ),
    );

    rows.add(
      DataRow(
        cells: [
          DataCell(Text('De')),
          DataCell(Text(reception['location_id'][1])),
        ],
      ),
    );

    rows.add(
      DataRow(
        cells: [
          DataCell(Text('Vers')),
          DataCell(Text(reception['location_dest_id'][1])),
        ],
      ),
    );

    rows.add(
      DataRow(
        cells: [
          DataCell(Text('Date planifiée')),
          DataCell(Text(reception['create_date'])),
        ],
      ),
    );

    rows.add(
      DataRow(
        cells: [
          DataCell(Text('Date effective')),
          DataCell(Text(reception['write_date'])),
        ],
      ),
    );

    // If additional data is available, add the related details row
    if (additionalData.isNotEmpty) {
      var relatedData = additionalData.firstWhere(
        (data) => data['picking_id'][0] == reception['id'],
        orElse: () => null,
      );

      if (relatedData != null) {
        rows.add(
          DataRow(
            cells: [
              DataCell(Text('Statut')),
              DataCell(Text(relatedData['state'])),
            ],
          ),
        );

        rows.add(
          DataRow(
            cells: [
              DataCell(Text('Quantité')),
              DataCell(Text(relatedData['quantity_done'].toString())),
            ],
          ),
        );
      }
    }

    return rows;
  }

  Future<void> _generateAndOpenPDF() async {
    final pdf = pw.Document();

    // Add content to the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: _buildPDFContent(),
            ),
          );
        },
      ),
    );

    // Save the PDF file locally
    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/bon_de_mouvement.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the saved PDF file
    OpenFile.open(filePath);
  }

  List<pw.Widget> _buildPDFContent() {
    List<pw.Widget> content = [];

    // Add the title
    content.add(
      pw.Text(
        'Bon de Mouvement',
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );

    // Create a list of data rows for the table
    List<pw.TableRow> tableRows = [];

    // Add the reception/delivery/internal transfer details row
    tableRows.add(pw.TableRow(
      children: [
        pw.Text('Champs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('Valeur', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    ));

    tableRows.add(pw.TableRow(
      children: [
        pw.Text('Référence'),
        pw.Text(reception['name']),
      ],
    ));

    tableRows.add(pw.TableRow(
      children: [
        pw.Text('Opération'),
        pw.Text(reception['picking_type_code']),
      ],
    ));

    tableRows.add(pw.TableRow(
      children: [
        pw.Text('De'),
        pw.Text(reception['location_id'][1]),
      ],
    ));

    tableRows.add(pw.TableRow(
      children: [
        pw.Text('Vers'),
        pw.Text(reception['location_dest_id'][1]),
      ],
    ));

    tableRows.add(pw.TableRow(
      children: [
        pw.Text('Date planifiée'),
        pw.Text(reception['create_date']),
      ],
    ));

    tableRows.add(pw.TableRow(
      children: [
        pw.Text('Date effective'),
        pw.Text(reception['write_date']),
      ],
    ));

    // If additional data is available, add the related details row
    if (additionalData.isNotEmpty) {
      var relatedData = additionalData.firstWhere(
        (data) => data['picking_id'][0] == reception['id'],
        orElse: () => null,
      );

      if (relatedData != null) {
        tableRows.add(pw.TableRow(
          children: [
            pw.Text('Statut'),
            pw.Text(relatedData['state']),
          ],
        ));

        tableRows.add(pw.TableRow(
          children: [
            pw.Text('Quantité'),
            pw.Text(relatedData['quantity_done'].toString()),
          ],
        ));
      }
    }

    // Increase the height of each row
    final double rowHeight = 50; // Adjust the height as needed

    // Increase the cell padding
    // Adjust the padding as needed

    // Create the table widget
    final table = pw.Table(
      children: tableRows,
      border: pw.TableBorder.all(
        width: 1,
      ),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: {
        0: pw.FractionColumnWidth(0.3),
        1: pw.FractionColumnWidth(0.7),
      },
    );

    // Wrap the table inside a container to set its height
    final container = pw.Container(
      height: rowHeight *
          tableRows.length, // Set the height based on the number of rows
      child: table,
    );

    // Add the table to the PDF content
    content.add(
        pw.SizedBox(height: 20)); // Add spacing between the title and table
    content.add(container);

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bon de Mouvement'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              _generateAndOpenPDF();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('Champs')),
            DataColumn(label: Text('Valeur')),
          ],
          rows: _buildRows(),
        ),
      ),
    );
  }
}
