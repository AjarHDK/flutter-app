import 'package:flutter/material.dart';
import 'navBar.dart';

class HomePage extends StatelessWidget {
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text(
          'Hello, you are logged in!',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
