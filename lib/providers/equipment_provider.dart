import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/providers/storage_provider.dart';

class Equipment {
  final List<EquipmentItem> equipmentList;

  Equipment({required this.equipmentList});

  static Future<Equipment> get() async {
    final List<EquipmentItem> equipmentList = [];

    final db = FirebaseFirestore.instance;
    final equipmentRef = db.collection("equipment");
    //get all Documents in the inventory

    final QuerySnapshot inventorySnapshot = await equipmentRef.get();
    // Loop over each item in inventory
    for (final equipmentItem in inventorySnapshot.docs) {
      final Map<String, dynamic> equipmentItemData =
          equipmentItem.data() as Map<String, dynamic>;

      final String id = equipmentItem.id;
      final String name = equipmentItemData["name"];
      final int totalQuantity = equipmentItemData["totalQuantity"];
      final String imageRef = equipmentItemData["imageRef"];

      // Get name and image

      equipmentList.add(
        EquipmentItem(
          id: id,
          name: name,
          totalQuantity: totalQuantity,
          imageRef: imageRef,
        ),
      );
    }
    return Equipment(equipmentList: equipmentList);
  }

  static Future<bool> registerEquipment({
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

  //Create a static function that takes in an equipment id and quantity and updates the equipment quantity in both the global inventory and the user's inventory
  static void updateEquipmentQuantity(
      {required String equipmentId,
      required int quantity,
      required CollectionReference<Map<String, dynamic>> inventoryRef}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference<Map<String, dynamic>> equipmentRef =
        db.collection("equipment").doc(equipmentId);
    final DocumentSnapshot<Map<String, dynamic>> equipmentDocument =
        await equipmentRef.get();
    final Map<String, dynamic> equipmentData =
        equipmentDocument.data() as Map<String, dynamic>;
    final int totalQuantity = equipmentData["totalQuantity"];
    final int newTotalQuantity = totalQuantity + quantity;
    equipmentRef.update({"totalQuantity": newTotalQuantity});
    giveUserEquipment(
        inventoryRef: inventoryRef, id: equipmentId, quantity: quantity);
  }

  static void giveUserEquipment(
      {required CollectionReference<Map<String, dynamic>> inventoryRef,
      required String id,
      required int quantity}) {
    inventoryRef.doc(id).set({"quantity": quantity});
  }
}

class EquipmentItem {
  final String id;
  final String name;
  final int totalQuantity;
  final String imageRef;

  EquipmentItem(
      {required this.id,
      required this.name,
      required this.totalQuantity,
      required this.imageRef});
}
