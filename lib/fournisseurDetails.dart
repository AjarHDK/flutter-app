import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class FournissseurDetailsPage extends StatelessWidget {
  final dynamic fournisseur;

  const FournissseurDetailsPage({required this.fournisseur});

  @override
  Widget build(BuildContext context) {
    List<int> imageBytes = [];

    if (fournisseur['image_1920'] is String &&
        fournisseur['image_1920'].isNotEmpty) {
      imageBytes = base64.decode(fournisseur['image_1920']);
    }

    Uint8List imageUint8List = Uint8List.fromList(imageBytes);

    return Scaffold(
      appBar: AppBar(
        title: Text(fournisseur['dispaly_name'] ?? ''),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('email: ${fournisseur['email'] ?? ''}'),
                      Text('phone : ${fournisseur['phone'] ?? ''}'),
                      Text('city : ${fournisseur['city'] ?? ''}'),
                      Text('country_id: ${fournisseur['country_id'] ?? ''}'),
                      Text('website: ${fournisseur['website'] ?? ''}'),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                imageBytes.isNotEmpty
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
