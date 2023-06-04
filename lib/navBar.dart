import 'package:flutter/material.dart';
import 'package:odoo/Reception.dart';
import 'package:odoo/product_page.dart';
import 'user_page.dart';
import 'stockPage.dart';

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
            onTap: () => print('dash'),
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
            onTap: () => print('four'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Emplacement'),
            onTap: () => print('emp'),
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
            onTap: () => print('liv'),
          ),
          ListTile(
            leading: Icon(Icons.insert_chart),
            title: Text('Rapport'),
            onTap: () => print('RP'),
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
