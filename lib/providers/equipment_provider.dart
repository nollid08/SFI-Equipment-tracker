import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/providers/storage_provider.dart';

Future<bool> registerEquipment({
  required CollectionReference<Map<String, dynamic>> inventoryRef,
  required String name,
  required int quantity,
  required image,
}) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  // Extract Data From Image
  final String imageExtension = extension(image.name);
  final Uint8List imageData = await image.readAsBytes();

  //Generate Id For Equipment
  List<String> words = name.split(' ');
  String equipmentId = words.map((word) => word.toUpperCase()).join('_');
  DocumentReference<Map<String, dynamic>> equipmentRef =
      db.collection("equipment").doc(equipmentId);
  final equipmentDocument = await equipmentRef.get();
  final equipmentExists = equipmentDocument.exists;
  print(equipmentExists);
  if (!equipmentExists) {
    final String uploadedImagePath = await uploadImageData(
      imageData: imageData,
      parentFolder: "equipment_images",
      imageName: equipmentId,
      imageExtension: imageExtension,
    );
    final InventoryItem newEquipment = InventoryItem(
      id: equipmentId,
      name: name,
      quantity: quantity,
      imageRef: uploadedImagePath,
    );

    giveUserEquipment(
        inventoryRef: inventoryRef, id: newEquipment.id, quantity: quantity);

    db.collection("equipment").doc(equipmentId).set({
      "name": newEquipment.name,
      "imageRef": newEquipment.imageRef,
      "totalQuantity": newEquipment.quantity
    }).onError((e, _) => print("Error writing document: $e"));
    return true;
  } else {
    return false;
  }
}

void giveUserEquipment(
    {required CollectionReference<Map<String, dynamic>> inventoryRef,
    required String id,
    required int quantity}) {
  inventoryRef.doc(id).set({"quantity": quantity});
}
