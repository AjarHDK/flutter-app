import 'package:flutter/material.dart';

class updateReceptionPage extends StatefulWidget {
  final dynamic reception;
  const updateReceptionPage({required this.reception});

  @override
  State<updateReceptionPage> createState() => _updateReceptionPageState();
}

class _updateReceptionPageState extends State<updateReceptionPage> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update  Reception'),
      ),
      body: Center(child: Text(widget.reception['name'])),
    );
  }
}
