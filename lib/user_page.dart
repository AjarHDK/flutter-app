import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            'qty_to_order',
            'location_id',
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
    final username = 'consulaltantstockodoo@gmail.com'; // Votre adresse e-mail
    final password =
        'jkaddhfivholdniv'; // Votre mot de passe e-mail ou mot de passe d'application

    final smtpServer =
        gmail(username, password); // Utiliser le serveur SMTP de Gmail

    final message = Message()
      ..from = Address(username, 'ConsultantStockOdoo')
      ..recipients.add(email)
      ..subject = 'Urgent : Rupture de stock - Confirmation requise';

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
        // Informations sur le produit
        String productName = orderPoint['product_id'][1].toString();
        String quantity = orderPoint['qty_on_hand'].toString();
        String emplacement = orderPoint['location_id'][1].toString();

        // Corps de l'e-mail
        String emailBody =
            '''
<html>
  <body style="text-align: justify;">
    <p>Cher/Chère Responsable des Achats,</p>
    <p>Nous avons identifié une rupture de stock pour certains produits. Un bon de commande a été automatiquement généré pour les produits concernés :</p>
    <ul>
      <li>Produit : $productName</li>
      <li>Quantité : $quantity</li>
      <li>Emplacement : $emplacement</li>
    </ul>
    <p>Veuillez confirmer le bon de commande généré au niveau de l'application <span style="font-weight: bold; color: purple;">ConsultantStockOdoo</span> dès que possible afin que nous puissions réapprovisionner notre stock dans les meilleurs délais.</p>
    <p>Merci de votre collaboration.</p>
    
  </body>
</html>
''';

        message.html = emailBody;

        message.html = emailBody;

        try {
          final sendReport = await send(message, smtpServer);
          print('Message envoyé : ${sendReport}');
        } catch (e) {
          print('Erreur lors denvoi: $e');
        }
      }
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
    );
  }
}
