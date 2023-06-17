import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class FournisseursPrPage extends StatefulWidget {
  @override
  State<FournisseursPrPage> createState() => _FournisseursPrPageState();
}

class _FournisseursPrPageState extends State<FournisseursPrPage> {
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
      // Fetch data from the 'stock.warehouse.orderpoint' model
      final response = await orpc?.callKw({
        'model': 'stock.warehouse.orderpoint',
        'method': 'search_read',
        'args': [[]],
        'kwargs': {
          'fields': [
            'product_id',
            'qty_on_hand',
            'product_min_qty',
            'location_id',
            'qty_to_order'
          ],
        },
      });

      setState(() {
        receptions = response;
      });

      // Iterate over the fetched receptions and retrieve additional data from other models
      for (final reception in receptions) {
        final productID = reception['product_id'][0];
        final qtyOnHand = reception['qty_on_hand'];
        final productMinQty = reception['product_min_qty'];

        if (qtyOnHand < productMinQty) {
          // Fetch data from the 'product.product' model
          final productResponse = await orpc?.callKw({
            'model': 'product.product',
            'method': 'search_read',
            'args': [
              [
                ['id', '=', productID],
              ],
            ],
            'kwargs': {
              'fields': ['name'],
            },
          });

          // Fetch data from the 'product.supplierinfo' model
          final supplierResponse = await orpc?.callKw({
            'model': 'product.supplierinfo',
            'method': 'search_read',
            'args': [
              [
                ['product_tmpl_id', '=', productID],
              ],
            ],
            'kwargs': {
              'fields': ['partner_id', 'price', 'delay'],
            },
          });
          final productTemplateResponse = await orpc?.callKw({
            'model': 'product.template',
            'method': 'search_read',
            'args': [
              [
                ['id', '=', productID],
              ],
            ],
            'kwargs': {
              'fields': ['taxes_id'],
            },
          });

          // Process and store the additional data
          final additionalInfo = {
            'product': productResponse[0]['name'],
            'tva': productTemplateResponse[0]['taxes_id'],
            'suppliers': [],
          };

          // Iterate over supplier information
          for (final supplier in supplierResponse) {
            final supplierID = supplier['partner_id'][0];

            // Fetch data from the 'res.partner' model
            final supplierData = await orpc?.callKw({
              'model': 'res.partner',
              'method': 'read',
              'args': [
                [supplierID],
              ],
              'kwargs': {
                'fields': ['email', 'phone', 'display_name'],
              },
            });

            // Add supplier data to the additional info
            final supplierInfo = {
              'supplier': supplierData[0]['display_name'],
              'email': supplierData[0]['email'],
              'phone': supplierData[0]['phone'],
              'price': supplier['price'],
              'delay': supplier['delay'],
            };
            additionalInfo['suppliers'].add(supplierInfo);
          }

          additionalData.add(additionalInfo);
        }
      }
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
      body: ListView.builder(
        itemCount: additionalData.length,
        itemBuilder: (context, index) {
          final reception = receptions[index];
          final additionalInfo = additionalData[index];
          return buildProductItem(reception, additionalInfo, context);
        },
      ),
    );
  }
}

Widget buildProductItem(
    dynamic reception, dynamic additionalInfo, BuildContext context) {
  return ListTile(
    leading: Icon(
      Icons.remove_shopping_cart,
    ),
    title: Row(
      children: [
        Text(additionalInfo['product'] ?? ''),
        SizedBox(width: 60), // Add space between the product title and location
        Icon(Icons.location_on),

        Text(
          '${reception['location_id'][1]}',
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsPage(reception, additionalInfo),
        ),
      );
    },
  );
}

// Obtenez la date actuelle
DateTime now = DateTime.now();

// Formatez la date au format souhaité
String formattedDate = DateFormat('dd/MM/yyyy').format(now);

class ProductDetailsPage extends StatefulWidget {
  final dynamic reception;
  final dynamic additionalInfo;

  ProductDetailsPage(this.reception, this.additionalInfo);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  TextEditingController editedPriceTextController = TextEditingController();
  TextEditingController editedQtyToOrderTextController =
      TextEditingController();
  TextEditingController totalPriceTextController = TextEditingController();
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    editedPriceTextController.text =
        widget.additionalInfo['suppliers'][0]['price'].toString();
    editedQtyToOrderTextController.text =
        widget.reception['qty_to_order'].toString();
    calculateTotalPrice(); // Calculate initial total price
  }

  void calculateTotalPrice() {
    double editedPrice = double.tryParse(editedPriceTextController.text) ?? 0.0;
    double editedQtyToOrder =
        double.tryParse(editedQtyToOrderTextController.text) ?? 0.0;
    setState(() {
      totalPrice = (((editedPrice * 0.2) + editedPrice) * editedQtyToOrder);
    });
    totalPriceTextController.text = totalPrice.toString();
  }

  @override
  void dispose() {
    editedPriceTextController.dispose();
    editedQtyToOrderTextController.dispose();
    totalPriceTextController.dispose();
    super.dispose();
  }

  Future<void> _generateAndOpenPDF() async {
    final updatedQuantity =
        double.tryParse(editedQtyToOrderTextController.text) ?? 0.0;
    final updatedPrice = double.tryParse(editedPriceTextController.text) ?? 0.0;
    final pdf = pw.Document();

    // Add content to the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: _buildPDFContent(updatedQuantity, updatedPrice),
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

  List<pw.Widget> _buildPDFContent(double quantity, double price) {
    List<pw.Widget> content = [];

    // Add the title with a bar above it
    content.add(
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(
              width: 2.0,
            ),
          ),
        ),
        alignment: pw.Alignment.center,
        child: pw.Text(
          'Bon de Commande',
          style: pw.TextStyle(
            fontSize: 40,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );

    // Add spacing between the title and content
    content.add(pw.SizedBox(height: 70));

    // Add company information on the left
    content.add(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Entreprise: Droneway'),
                pw.SizedBox(height: 10),
                pw.Text('Adresse: Casablanca, Maroc '),
                pw.SizedBox(height: 10),
                pw.Text('Téléphone: +21269915193'),
                pw.SizedBox(height: 10),
                pw.Text('Email: hajar.dekdegue.3@gmail.com'),
                // Add more company information if needed
              ],
            ),
          ),
          pw.SizedBox(
              width:
                  20), // Add spacing between company and supplier information
          // Add supplier information on the right
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    'Fournisseur: ${widget.additionalInfo['suppliers'][0]['supplier']}'),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Email : ${widget.additionalInfo['suppliers'][0]['email']}'),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Télé: ${widget.additionalInfo['suppliers'][0]['phone']}'),
                // Add more supplier information if needed
              ],
            ),
          ),
        ],
      ),
    );

    // Add spacing between sections
    content.add(pw.SizedBox(height: 90));

    // Add order details in a table
    content.add(
      pw.Container(
        alignment: pw.Alignment.center,
        child: pw.Table(
          border: pw.TableBorder.all(
            width: 1,
            style: pw.BorderStyle.solid,
          ),
          tableWidth: pw.TableWidth.max,
          children: [
            // Table header
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Nom du produit',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Date de la demande',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Qantité demandée',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Prix unitaire',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                    'Toutes taxes comprises',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Table data
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(widget.additionalInfo['product']),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text('$formattedDate'),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(quantity.toString()),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(price.toString() + ' DH'),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                      (quantity * (price + (price * 0.2))).toString() + ' DH'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    content.add(pw.SizedBox(height: 50));

    content.add(
      pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Container(
          height: 1,
          width: 180,
          color: PdfColors.black,
        ),
      ),
    );
    content.add(pw.SizedBox(height: 15));
    content.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            'Montant hors taxes',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 20),
          pw.Text(
            (price * quantity).toString() + ' DH',
          ),
        ],
      ),
    );
    content.add(pw.SizedBox(height: 20));
    content.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            'TVA 20%',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 20),
          pw.Text(
            (price * 0.2).toString() + ' DH',
          ),
        ],
      ),
    );
    content.add(pw.SizedBox(height: 15));
    content.add(
      pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Container(
          height: 1,
          width: 180,
          color: PdfColors.black,
        ),
      ),
    );

    content.add(pw.SizedBox(height: 20));
    content.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            'Prix Total',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 20),
          pw.Text(
            (quantity * (price + (price * 0.2))).toString() + ' DH',
          ),
        ],
      ),
    );
    content.add(pw.SizedBox(height: 180));
    content.add(
      pw.Divider(
        thickness: 2.0,
      ),
    );

    return content;
  }

  Future<void> sendEmailToUser(String email) async {
    final updatedQuantity =
        double.tryParse(editedQtyToOrderTextController.text) ?? 0.0;
    final updatedPrice = double.tryParse(editedPriceTextController.text) ?? 0.0;
    final username = 'consulaltantstockodoo@gmail.com'; // Your email address
    final password = 'jkaddhfivholdniv'; // Your email password or app password

    final smtpServer = gmail(username, password); // Use Gmail SMTP server

    final message = Message()
      ..from = Address(username, 'Your Name')
      ..recipients.add(email)
      ..subject = 'PDF Report';

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(
                width: 2.0,
              ),
            ),
          ),
          alignment: pw.Alignment.center,
          child: pw.Column(
            children: [
              pw.Text(
                'Bon de Commande',
                style: pw.TextStyle(
                  fontSize: 40,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Entreprise: Droneway'),
                        pw.SizedBox(height: 10),
                        pw.Text('Adresse: Casablanca, Maroc'),
                        pw.SizedBox(height: 10),
                        pw.Text('Téléphone: +21269915193'),
                        pw.SizedBox(height: 10),
                        pw.Text('Email: hajar.dekdegue.3@gmail.com'),
                        // Add more company information if needed
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // Add spacing between company and supplier information
                  // Add supplier information on the right
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Fournisseur: ${widget.additionalInfo['suppliers'][0]['supplier']}',
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Email: ${widget.additionalInfo['suppliers'][0]['email']}',
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Télé: ${widget.additionalInfo['suppliers'][0]['phone']}',
                        ),
                        // Add more supplier information if needed
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(
                  width: 1,
                  style: pw.BorderStyle.solid,
                ),
                tableWidth: pw.TableWidth.max,
                children: [
                  // Table header
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Nom du produit',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Date de la demande',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Qantité demandée',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                        // Ajuste la largeur de la colonne
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Prix unitaire',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Toutes taxes comprises',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Table data
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(widget.additionalInfo['product']),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(DateTime.now().toString()),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(updatedQuantity.toString()),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(updatedPrice.toString() + ' DH'),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          (updatedQuantity *
                                      (updatedPrice + (updatedPrice * 0.2)))
                                  .toString() +
                              ' DH',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  height: 1,
                  width: 180,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Montant hors taxes',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    (updatedPrice * updatedQuantity).toString() + ' DH',
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'TVA 20%',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    (updatedPrice * 0.2).toString() + ' DH',
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  height: 1,
                  width: 180,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Prix Total',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    (updatedQuantity * (updatedPrice + (updatedPrice * 0.2)))
                            .toString() +
                        ' DH',
                  ),
                ],
              ),
              pw.SizedBox(height: 280),
              pw.Divider(
                thickness: 2.0,
              ),
            ],
          ),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/example.pdf');
    await file.writeAsBytes(await pdf.save());

    final attachment = FileAttachment(file);
    message.attachments.add(attachment);

    try {
      await send(message, smtpServer);
      print('Email sent successfully!');
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String tva = "20%";

    return Scaffold(
      appBar: AppBar(
        title: Text('Bon de Commande'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              _generateAndOpenPDF();
            },
          ),
          IconButton(
            icon: Icon(Icons.email),
            onPressed: () {
              sendEmailToUser(
                  widget.additionalInfo['suppliers'][0]['email'].toString());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: widget.additionalInfo['product'].toString(),
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Produit',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: editedPriceTextController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: editedQtyToOrderTextController,
                decoration: InputDecoration(
                  labelText: 'Qty to Order',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: tva,
                decoration: InputDecoration(
                  labelText: 'Tva',
                  enabled: false,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: widget.reception['location_id'][1].toString(),
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Emplacement',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              for (final supplier in widget.additionalInfo['suppliers'])
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: supplier['supplier'].toString(),
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Fournisseur',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: supplier['email'].toString(),
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: supplier['phone'].toString(),
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: supplier['delay'].toString(),
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Délai',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 8),
              TextFormField(
                controller: totalPriceTextController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Total Price',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  calculateTotalPrice(); // Update the total price
                },
                child: Text('Update Total Price'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
