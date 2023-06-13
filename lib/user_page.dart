import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final orpc = Auth.orpc;
  List<dynamic> users = [];
  String? selectedRole; // Variable to hold the selected role

  @override
  void initState() {
    super.initState();
    loadSelectedRole();
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
        users = response;
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

  Future<void> saveSelectedRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRole', selectedRole ?? '');
  }

  Future<void> loadSelectedRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('selectedRole');
    });
  }

  Future<void> sendEmailToUser(String email) async {
    final username = 'your_email@gmail.com'; // Your email address
    final password = 'your_password'; // Your email password or app password

    final smtpServer = gmail(username, password); // Use Gmail SMTP server

    final message = Message()
      ..from = Address(username, 'Your Name')
      ..recipients.add(email)
      ..subject = 'Subject of the email'
      ..text = 'Body of the email';

    try {
      await send(message, smtpServer);
      print('Email sent successfully!');
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  Widget buildUserItem(dynamic user) {
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
          if (selectedRole == 'Responsable d\'Achat')
            ElevatedButton(
              onPressed: () {
                sendEmailToUser(user['email']);
              },
              child: Text('Send Email'),
            ),
          if (selectedRole != 'Responsable d\'Achat')
            Text('Only "Responsable d\'Achat" can receive emails.'),
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
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return buildUserItem(user);
        },
      ),
    );
  }
}
