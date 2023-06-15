import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'auth.dart';

class UserPage extends StatefulWidget {
  static List<dynamic> users = [];
  static Map<int, String?> selectedRoles = {};

  @override
  _UserPageState createState() => _UserPageState();

  static Future<void> sendEmailToSelectedUsers(
      List<dynamic> users, Map<int, String?> selectedRoles) async {
    for (var user in users) {
      final selectedRole = selectedRoles[user['id']];
      if (selectedRole == 'Responsable d\'Achat') {
        await sendEmailToUser(user['email']);
      }
    }
  }

  static Future<List<dynamic>> fetchOrderPoints() async {
    final orpc = Auth.orpc;

    try {
      final response = await orpc?.callKw({
        'model': 'stock.warehouse.orderpoint',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'product_id',
            'qty_on_hand',
            'product_min_qty',
            'product_id',
            'qty_to_order'
          ],
        },
      });

      if (response != null && response is List<dynamic>) {
        return response;
      } else {
        print('Invalid or unexpected response: $response');
        return [];
      }
    } catch (e) {
      print('Error fetching order points: $e');
      return [];
    }
  }

  static Future<void> sendEmailToUser(String email) async {
    final username = 'consulaltantstockodoo@gmail.com'; // Your email address
    final password = 'jkaddhfivholdniv'; // Your email password or app password

    final smtpServer = gmail(username, password); // Use Gmail SMTP server

    final message = Message()
      ..from = Address(username, 'Your Name')
      ..recipients.add(email)
      ..subject = 'PDF Report';

    final pdf = pw.Document();
    final orderPoints = await fetchOrderPoints();

    for (var orderPoint in orderPoints) {
      double qtyOnHandDouble =
          double.parse(orderPoint['qty_on_hand'].toString());
      double productMinQtyDouble =
          double.parse(orderPoint['product_min_qty'].toString());
      double.parse(orderPoint['qty_to_order'].toString());

      int qtyOnHand = qtyOnHandDouble.toInt();
      int productMinQty = productMinQtyDouble.toInt();

      if (qtyOnHand < productMinQty) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Container(
                padding: pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Entête du bon de commande
                    pw.Text(
                      'Bon de commande',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    // Informations sur le fournisseur

                    pw.Text(
                      'Fournisseur:',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Adresse : Adresse du fournisseur'),
                    pw.SizedBox(height: 10),
                    pw.Text('Ville : Ville du fournisseur'),
                    pw.SizedBox(height: 20),
                    // Informations sur les produits commandés
                    pw.Text(
                      'Produits commandés',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    // Tableau des produits
                    pw.Table(
                      border: pw.TableBorder.all(),
                      columnWidths: {
                        0: pw.FixedColumnWidth(100),
                        1: pw.FixedColumnWidth(100),
                        2: pw.FixedColumnWidth(100),
                      },
                      children: [
                        // En-tête du tableau
                        pw.TableRow(
                          children: [
                            pw.Text('Produit',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('Quantité',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('Prix',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        // Lignes du tableau
                        pw.TableRow(
                          children: [
                            pw.Text('Produit 1'),
                            pw.Text('5'),
                            pw.Text('\$10.00'),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text('Produit 2'),
                            pw.Text('3'),
                            pw.Text('\$15.00'),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    // Pied de page
                    pw.Text('Total : \$55.00'),
                  ],
                ),
              );
            },
          ),
        );
      }
    }

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
}

class _UserPageState extends State<UserPage> {
  final orpc = Auth.orpc;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await orpc?.callKw({
        'model': 'res.users',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['name', 'email', 'login_date', 'state', 'image_1920'],
        },
      });
      setState(() {
        UserPage.users = response;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch users.'),
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

  Future<void> saveSelectedRole(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'selectedRole_$userId', UserPage.selectedRoles[userId] ?? '');
  }

  Future<void> loadSelectedRole(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      UserPage.selectedRoles[userId] = prefs.getString('selectedRole_$userId');
    });
  }

  Widget buildUserItem(dynamic user) {
    final userId = user['id'];
    return ListTile(
      title: Text(
        user['name'],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user['email'] ?? ''),
          Text('Last Login: ${user['login_date'] ?? ''}'),
          Text('Status: ${user['state'] ?? ''}'),
          DropdownButton<String>(
            value: UserPage.selectedRoles[userId],
            onChanged: (String? newValue) {
              setState(() {
                UserPage.selectedRoles[userId] = newValue;
                saveSelectedRole(userId);
              });
            },
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'Responsable de Stock',
                child: Text('Responsable de Stock'),
              ),
              DropdownMenuItem<String>(
                value: 'Responsable d\'Achat',
                child: Text('Responsable d\'Achat'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: ListView.builder(
        itemCount: UserPage.users.length,
        itemBuilder: (context, index) {
          final user = UserPage.users[index];
          final userId = user['id'];
          if (!UserPage.selectedRoles.containsKey(userId)) {
            loadSelectedRole(userId);
          }
          return buildUserItem(user);
        },
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          UserPage.sendEmailToSelectedUsers(
              UserPage.users, UserPage.selectedRoles);
        },
        child: Text('Send Emails'),
      ),
    );
  }
}
