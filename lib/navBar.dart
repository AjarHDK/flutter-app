import 'package:flutter/material.dart';
import 'package:odoo/dashboardPage.dart';
import 'fournisseurPage.dart';
import 'package:odoo/product_page.dart';
import 'user_page.dart';
import 'stockPage.dart';
import 'Reception.dart';
import 'livraison.dart';
import 'transfer.dart';
import 'approvisonnement.dart';
import 'rapport.dart';

class NavBar extends StatelessWidget {
  NavBar();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("droneway2.com"),
            accountEmail: Text("hajar.dekdegue.3@gmail.com"),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'images/greeting.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashbord'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Users'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPage()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Products'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductPage()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('Stock'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StockPage()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Fournisseur'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FournisseurPage()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.check_box),
            title: Text('Reception'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReceptionPage()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text('Livraison'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LivraisonPage()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.swap_horiz),
            title: Text('Transfert interne'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TransfertInternalPage()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Bon de Mouvement'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RapportPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.sync),
            title: Text('Reaprovisonnement'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ApprovisonnementPage()),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => print('sett'),
          ),
        ],
      ),
    );
  }
}
