import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/storage_provider.dart';

void addNewEquipment(
    {required String name, required int quantity, required image}) async {
  // Extract Data From Image
  final String imageExtension = extension(image.name);
  final Uint8List imageData = await image.readAsBytes();

  //Generate Id For Equipment
  List<String> words = name.split(' ');
  String equipmentId = words.map((word) => word.toUpperCase()).join('_');

  final String uploadedImagePath = await uploadImageData(
    imageData: imageData,
    parentFolder: "equipment_images",
    imageName: equipmentId,
    imageExtension: imageExtension,
  );
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final newEquipment = {
    "name": name,
    "totalQuantity": quantity,
    "imageRef": uploadedImagePath
  };
  // final account = await Account.get("eztCYCYXUJb8t1sAUdItwBVZEry2");
  // final Map inventory = account.inventory;
  // print(inventory[equipmentId]);

  db
      .collection("equipment")
      .doc(equipmentId)
      .set(newEquipment)
      .onError((e, _) => print("Error writing document: $e"));
}

// int checkEquipmentCount({required String id, required int uid}) {
//   final docRef = db.collection("cities").doc("SF");
// docRef.get().then(
//   (DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     // ...
//   },
//   onError: (e) => print("Error getting document: $e"),
// );
// }

// IN PROGRESS
void giveUserEquipment(
    {required String uid, required String id, required int quantity}) {
  final db = FirebaseFirestore.instance;
}
