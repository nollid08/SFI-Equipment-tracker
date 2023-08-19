import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

Future<String> uploadImageData({
  required Uint8List imageData,
  required String parentFolder,
  required String imageName,
  required String imageExtension,
}) async {
  final storageRef = FirebaseStorage.instance.ref();
  final imagesRef = storageRef.child(parentFolder);
  final equipmentImageRef = imagesRef.child(imageName + imageExtension);
  final TaskSnapshot imageUploadTask =
      await equipmentImageRef.putData(imageData);
  return (imageUploadTask.ref.fullPath);
}
