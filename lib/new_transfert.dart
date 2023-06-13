import 'package:flutter/material.dart';
import 'auth.dart';

class ProductTemplate {
  final int id;
  final String name;

  ProductTemplate({required this.id, required this.name});
}

class NewTransfertPage extends StatefulWidget {
  @override
  _NewTransfertPageState createState() => _NewTransfertPageState();
}

class _NewTransfertPageState extends State<NewTransfertPage> {
  final orpc = Auth.orpc;
  TextEditingController productQtyController = TextEditingController();
  TextEditingController quantityDoneController = TextEditingController();
  DateTime createDate = DateTime.now();
  DateTime createTime = DateTime.now();
  DateTime writeDate = DateTime.now();
  DateTime writeTime = DateTime.now();
  List<ProductTemplate> _productTemplates = [];
  List<ProductTemplate> _productPickingTemplates = [];
  List<ProductTemplate> _productDestinationTemplates = [];
  List<ProductTemplate> _productLocationTemplates = [];
  int? _selectedProductId;
  int? _selectedPickingTypeId;
  int? _selectedDestinationId;
  int? _selectedLocationId;
  bool isSubmitButtonEnabled = false;
  bool isSubmitButtonEnabledDraft = false;

  @override
  void initState() {
    super.initState();
    getProductTemplates();
    getPickingTypeIds();
    getDestinationIds();
    getLocationIds();
    productQtyController.addListener(updateSubmitButtonStatus);
    quantityDoneController.addListener(updateSubmitButtonStatus);
  }

  @override
  void dispose() {
    // Dispose of the text editing controllers
    productQtyController.dispose();
    quantityDoneController.dispose();
    super.dispose();
  }

  void updateSubmitButtonStatus() {
    setState(() {
      // Update the enabled status of the submit button based on the text fields' values
      isSubmitButtonEnabledDraft = quantityDoneController.text.isEmpty;
    });
  }

  Future<void> getProductTemplates() async {
    String modelProduct = 'product.template';
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
          .toList();
    });
  }

  Future<void> getPickingTypeIds() async {
    String modelProduct = 'stock.picking.type';
    List<dynamic> results = await orpc?.callKw({
      'model': modelProduct,
      'method': 'search_read',
      'args': [
        [
          ['code', '=', 'internal']
        ],
        ['id', 'name', 'warehouse_id'],
      ],
      'kwargs': {},
    });

    setState(() {
      _productPickingTemplates = results
          .map((record) => ProductTemplate(
                id: record['id'],
                name: record['warehouse_id'][1].toString() +
                    ' : ' +
                    record['name'],
              ))
          .toList();
    });
  }

  Future<void> getDestinationIds() async {
    String modelProduct = 'stock.location';
    List<dynamic> results = await orpc?.callKw({
      'model': modelProduct,
      'method': 'search_read',
      'args': [
        [],
        ['id', 'complete_name'],
      ],
      'kwargs': {},
    });

    setState(() {
      _productDestinationTemplates = results
          .map((record) => ProductTemplate(
                id: record['id'],
                name: record['complete_name'],
              ))
          .toList();
    });
  }

  Future<void> getLocationIds() async {
    String modelProduct = 'stock.location';
    List<dynamic> results = await orpc?.callKw({
      'model': modelProduct,
      'method': 'search_read',
      'args': [
        [],
        ['id', 'complete_name'],
      ],
      'kwargs': {},
    });

    setState(() {
      _productLocationTemplates = results
          .map((record) => ProductTemplate(
                id: record['id'],
                name: record['complete_name'],
              ))
          .toList();
    });
  }

  void showCustomDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> createPickingRecord(String message) async {
    if (_selectedProductId == null) {
      // Product not selected
      return;
    }

    String modelPicking = 'stock.picking';
    String modelMove = 'stock.move';

    int newPickingId = await orpc?.callKw({
      'model': modelPicking,
      'method': 'create',
      'args': [
        {
          'location_id': _selectedLocationId,
          'location_dest_id': _selectedDestinationId,
          'picking_type_id': _selectedPickingTypeId,
          'picking_type_code': 'internal',
          'use_create_lots': true,
          'use_existing_lots': false,
          'create_date': DateTime(
            createDate.year,
            createDate.month,
            createDate.day,
            createTime.hour,
            createTime.minute,
          ).toIso8601String(), // Use selected create_date and create_time
          'write_date': DateTime(
            writeDate.year,
            writeDate.month,
            writeDate.day,
            writeTime.hour,
            writeTime.minute,
          ).toIso8601String(), // Use selected write_date and write_time
        },
      ],
      'kwargs': {},
    });

    int moveLineId = await orpc?.callKw({
      'model': modelMove,
      'method': 'create',
      'args': [
        {
          'picking_id': newPickingId,
          'product_id': _selectedProductId,
          // User input for product_uom_qty
          'location_id': _selectedLocationId, // Source location
          'location_dest_id': _selectedDestinationId, // Destination location
          'name': 'Move Line Description', // Description of the move line
        },
      ],
      'kwargs': {},
    });

    await orpc?.callKw({
      'model': modelMove,
      'method': 'write',
      'args': [
        [moveLineId],
        {
          'quantity_done': quantityDoneController.text.isNotEmpty
              ? int.parse(quantityDoneController.text)
              : 0,
        }, // User input for quantity_done
      ],
      'kwargs': {},
    });

    await orpc?.callKw({
      'model': modelPicking,
      'method': 'button_validate',
      'args': [
        [newPickingId],
      ],
      'kwargs': {},
    });

    print('New reception record ID: $newPickingId');
    showCustomDialog(context, message);
  }

  Future<void> createPickingRecordPart2(String message) async {
    if (_selectedProductId == null) {
      // Product not selected
      return;
    }

    String modelPicking = 'stock.picking';
    String modelMove = 'stock.move';

    int newPickingId = await orpc?.callKw({
      'model': modelPicking,
      'method': 'create',
      'args': [
        {
          'location_id': _selectedLocationId,
          'location_dest_id': _selectedDestinationId,
          'picking_type_id': _selectedPickingTypeId,
          'picking_type_code': 'internal',
          'use_create_lots': true,
          'use_existing_lots': false,
          'create_date': DateTime(
            createDate.year,
            createDate.month,
            createDate.day,
            createTime.hour,
            createTime.minute,
          ).toIso8601String(), // Use selected create_date and create_time
          'write_date': DateTime(
            writeDate.year,
            writeDate.month,
            writeDate.day,
            writeTime.hour,
            writeTime.minute,
          ).toIso8601String(), // Use selected write_date and write_time
        },
      ],
      'kwargs': {},
    });

    int moveLineId = await orpc?.callKw({
      'model': modelMove,
      'method': 'create',
      'args': [
        {
          'picking_id': newPickingId,
          'product_id': _selectedProductId,
          // User input for product_uom_qty
          'location_id': _selectedLocationId, // Source location
          'location_dest_id': _selectedDestinationId, // Destination location
          'name': 'Move Line Description', // Description of the move line
        },
      ],
      'kwargs': {},
    });

    await orpc?.callKw({
      'model': 'stock.picking',
      'method': 'action_reset_draft',
      'args': [
        [moveLineId],
        // User input for quantity_done
      ],
      'kwargs': {},
    });
    print('New transfert record ID: $newPickingId');
    showCustomDialog(context, message);
  }

  Future<void> selectCreateDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: createDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        createDate = selectedDate;
      });
    }
  }

  Future<void> selectCreateTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(createTime),
    );

    if (selectedTime != null) {
      setState(() {
        createTime = DateTime(
          createDate.year,
          createDate.month,
          createDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  Future<void> selectWriteDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: writeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        writeDate = selectedDate;
      });
    }
  }

  Future<void> selectWriteTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(writeTime),
    );

    if (selectedTime != null) {
      setState(() {
        writeTime = DateTime(
          writeDate.year,
          writeDate.month,
          writeDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isQtyDoneFilled = quantityDoneController.text.isNotEmpty;
    bool isSubmitButtonEnabled = isQtyDoneFilled;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Reception'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
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
              DropdownButtonFormField<int>(
                value: _selectedPickingTypeId,
                onChanged: (value) {
                  setState(() {
                    _selectedPickingTypeId = value;
                  });
                },
                items: _productPickingTemplates
                    .map((template) => DropdownMenuItem<int>(
                          value: template.id,
                          child: Text(template.name),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Picking Type ID',
                ),
              ),
              DropdownButtonFormField<int>(
                value: _selectedLocationId,
                onChanged: (value) {
                  setState(() {
                    _selectedLocationId = value;
                  });
                },
                items: _productLocationTemplates
                    .map((template) => DropdownMenuItem<int>(
                          value: template.id,
                          child: Text(template.name),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'source',
                ),
              ),
              DropdownButtonFormField<int>(
                value: _selectedDestinationId,
                onChanged: (value) {
                  setState(() {
                    _selectedDestinationId = value;
                  });
                },
                items: _productDestinationTemplates
                    .map((template) => DropdownMenuItem<int>(
                          value: template.id,
                          child: Text(template.name),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Destination',
                ),
              ),
              TextField(
                controller: quantityDoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity Done',
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Create Date:'),
                  TextButton(
                    onPressed: () => selectCreateDate(context),
                    child: Text(createDate
                        .toString()
                        .split(' ')[0]), // Display only the date
                  ),
                  TextButton(
                    onPressed: () => selectCreateTime(context),
                    child: Text(createTime
                        .toString()
                        .split(' ')[1]), // Display only the time
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Write Date:'),
                  TextButton(
                    onPressed: () => selectWriteDate(context),
                    child: Text(writeDate
                        .toString()
                        .split(' ')[0]), // Display only the date
                  ),
                  TextButton(
                    onPressed: () => selectWriteTime(context),
                    child: Text(writeTime
                        .toString()
                        .split(' ')[1]), // Display only the time
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isSubmitButtonEnabledDraft
                    ? () => createPickingRecordPart2(
                        'Transfert created in draft mode')
                    : null,
                child: Text('brouillon'),
              ),
              ElevatedButton(
                onPressed: isSubmitButtonEnabled
                    ? () => createPickingRecord('Transfert interne validated')
                    : null,
                child: Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
