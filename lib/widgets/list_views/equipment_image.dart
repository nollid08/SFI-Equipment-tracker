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
    return SizedBox(
      width: 50,
      child: FutureBuilder(
          future: downloadURL,
          builder: (BuildContext context, AsyncSnapshot imageUrl) {
            if (imageUrl.hasData) {
              return SizedBox.square(
                  child: Image.network(
                imageUrl.data,
                fit: BoxFit.cover,
                width: 50,
                cacheWidth: 50,
              ));
            } else {
              return const Center(
                  child: SizedBox.square(
                      dimension: 50, child: CircularProgressIndicator()));
            }
          }),
    );
  }
}
