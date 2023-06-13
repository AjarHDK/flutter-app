import 'package:flutter/material.dart';
import 'auth.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'fournisseurDetails.dart';

class FournisseurPage extends StatefulWidget {
  @override
  _FournisseurPageState createState() => _FournisseurPageState();
}

class _FournisseurPageState extends State<FournisseurPage> {
  final orpc = Auth.orpc;
  List<dynamic> fournisseurs = [];

  @override
  void initState() {
    super.initState();
    fetchFournisseurs();
  }

  Future<void> fetchFournisseurs() async {
    try {
      final response = await orpc?.callKw({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'display_name',
            'email',
            'phone',
            'city',
            'country_id',
            'website',
            'vat',
            'image_1920',
          ],
        },
      });
      setState(() {
        fournisseurs = response;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch fournisseurs.'),
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

  Widget buildFournisseurItem(dynamic fournisseur) {
    List<int> imageBytes = [];

    if (fournisseur['image_1920'] is String &&
        fournisseur['image_1920'].isNotEmpty) {
      imageBytes = base64.decode(fournisseur['image_1920']);
    }

    Uint8List imageUint8List = Uint8List.fromList(imageBytes);

    return ListTile(
      leading: imageBytes.isNotEmpty
          ? Image.memory(
              imageUint8List,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
          : Container(
              width: 50,
              height: 50,
              color: Colors.grey,
            ),
      title: Text(
        fournisseur['display_name'],
      ),
      onTap: () {
        // Navigate to FournisseurDetailsPage and pass the clicked fournisseur as a parameter
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FournissseurDetailsPage(fournisseur: fournisseur),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fournisseurs'),
      ),
      body: ListView.builder(
        itemCount: fournisseurs.length,
        itemBuilder: (context, index) {
          final fournisseur = fournisseurs[index];
          return buildFournisseurItem(fournisseur);
        },
      ),
    );
  }
}
