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

class HeroImage extends StatelessWidget {
  const HeroImage({
    super.key,
    required this.imageRef,
    required this.child,
  });
  final String imageRef;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Future<String> downloadURL =
        FirebaseStorage.instance.ref().child(imageRef).getDownloadURL();
    return FutureBuilder(
        future: downloadURL,
        builder: (BuildContext context, AsyncSnapshot imageUrl) {
          if (imageUrl.hasData) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:
                      Image.network(imageUrl.data, width: 300, cacheWidth: 300,
                          errorBuilder: (context, error, stackTrace) {
                    return Expanded(
                        child: Container(
                      color: Colors.grey,
                    ));
                  }, loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Expanded(
                          child: Container(
                        color: Colors.grey,
                      ));
                    }
                  }).image,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.darken),
                ),
              ),
              width: double.infinity,
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Center(child: child)),
            );
          } else {
            return Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 121, 121, 121)),
              width: double.infinity,
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Center(child: child)),
            );
          }
        });
  }
}
