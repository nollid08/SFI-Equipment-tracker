import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class EquipmentImage extends StatelessWidget {
  const EquipmentImage({
    super.key,
    required this.imageRef,
  });
  final String imageRef;

  @override
  Widget build(BuildContext context) {
    final Future<String> downloadURL =
        FirebaseStorage.instance.ref().child(imageRef).getDownloadURL();
    return FutureBuilder(
        future: downloadURL,
        builder: (BuildContext context, AsyncSnapshot imageUrl) {
          if (imageUrl.hasData) {
            return Image.network(imageUrl.data);
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
