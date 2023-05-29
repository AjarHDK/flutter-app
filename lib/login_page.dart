import 'package:flutter/material.dart';
import 'auth.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController dbNameController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _authenticate(BuildContext context) async {
    try {
      await Auth.authenticate(
        urlController.text,
        dbNameController.text,
        userController.text,
        passwordController.text,
      );
      Navigator.pushNamed(context, HomePage.routeName);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Authentication Failed'),
            content:
                Text('Unable to authenticate. Please check your credentials.'),
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
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: urlController,
              decoration: InputDecoration(labelText: 'URL'),
            ),
            TextField(
              controller: dbNameController,
              decoration: InputDecoration(labelText: 'Database Name'),
            ),
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _authenticate(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
