import 'package:flutter/material.dart';
import 'auth.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final orpc = Auth.orpc;
  List<dynamic> users = [];

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

  Widget buildUserItem(dynamic user) {
    return ListTile(
      //leading: CircleAvatar(
      // backgroundImage: NetworkImage(user['image_1920'] ?? ''),
      //),
      title: Text(
        user['name'],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user['email'] ?? ''),
          Text('Last Login: ${user['login_date'] ?? ''}'),
          Text('Status: ${user['state'] ?? ''}'),
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
