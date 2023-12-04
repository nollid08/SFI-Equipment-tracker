import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/providers/storage_provider.dart';

class AllGlobalEquipment {
  final List<GlobalEquipmentItem> equipmentList;

  AllGlobalEquipment({required this.equipmentList});

  static Future<AllGlobalEquipment> get() async {
    final List<GlobalEquipmentItem> equipmentList = [];

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
        GlobalEquipmentItem(
          id: id,
          name: name,
          totalQuantity: totalQuantity,
          imageRef: imageRef,
        ),
      );
    }
    return AllGlobalEquipment(equipmentList: equipmentList);
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
      inventoryRef.doc(equipmentId).set({"quantity": quantity});

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

  static void updateTotalEquipmentQuantity({
    required String equipmentId,
    required int quantity,
  }) async {
    //Create DB Ref
    final FirebaseFirestore db = FirebaseFirestore.instance;
    //Equipment Ref
    final DocumentReference<Map<String, dynamic>> equipmentRef =
        db.collection("equipment").doc(equipmentId);
    //Get Equipment Data
    final DocumentSnapshot<Map<String, dynamic>> equipmentDocument =
        await equipmentRef.get();
    final Map<String, dynamic> equipmentData =
        equipmentDocument.data() as Map<String, dynamic>;
    //Total Equipment Quantity
    final int totalQuantity = equipmentData["totalQuantity"];
    //Amended Total Equipment Quantity
    final int newTotalQuantity = totalQuantity + quantity;
    //Update Total Equipment Quantity
    equipmentRef.update({"totalQuantity": newTotalQuantity});
  }
}

class GlobalEquipmentItem {
  final String id;
  final String name;
  final int totalQuantity;
  final String imageRef;

  GlobalEquipmentItem(
      {required this.id,
      required this.name,
      required this.totalQuantity,
      required this.imageRef});
}

class GlobalEquipmentOwnerRelationships {
  final GlobalEquipmentItem equipmentItem;
  final List<GlobalEquipmentUserRelationship> relationships;

  GlobalEquipmentOwnerRelationships({
    required this.equipmentItem,
    required this.relationships,
  });

  static Future<GlobalEquipmentOwnerRelationships> get(
      String equipmentId) async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot<Map<String, dynamic>> userSnapshot =
        await db.collection("users").get();
    final DocumentSnapshot<Map<String, dynamic>> equipmentSnapshot =
        await db.collection("equipment").doc(equipmentId).get();
    final Map<String, dynamic> equipmentData =
        equipmentSnapshot.data() as Map<String, dynamic>;

    final String name = equipmentData["name"];
    final String imageRef = equipmentData["imageRef"];
    final int totalQuantity = equipmentData["totalQuantity"];
    final GlobalEquipmentOwnerRelationships equipmentUserRelationships =
        GlobalEquipmentOwnerRelationships(
      equipmentItem: GlobalEquipmentItem(
        id: equipmentId,
        name: name,
        totalQuantity: totalQuantity,
        imageRef: imageRef,
      ),
      relationships: [],
    );
    for (var docSnapshot in userSnapshot.docs) {
      final String userId = docSnapshot.id;
      final DocumentReference<Map<String, dynamic>> userRef =
          db.collection("users").doc(userId);
      final CollectionReference<Map<String, dynamic>> inventoryRef =
          userRef.collection("inventory");
      final DocumentSnapshot doc = await inventoryRef.doc(equipmentId).get();
      if (doc.exists) {
        final Account user = await Account.get("mkhK7z6u64gq7gyqt2zXD9sWIRV2");
        final String userName = user.name;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final int quantity = data["quantity"];
        final GlobalEquipmentUserRelationship equipmentUserRelationship =
            GlobalEquipmentUserRelationship(
          userId: userId,
          userName: userName,
          equipmentCount: quantity,
        );
        equipmentUserRelationships.relationships.add(equipmentUserRelationship);
        print("Successfully completed");
      } else {
        print("No such document!");
      }
    }

    return equipmentUserRelationships;
  }
}

class GlobalEquipmentUserRelationship {
  final String userId;
  final String userName;
  final int equipmentCount;

  GlobalEquipmentUserRelationship({
    required this.userId,
    required this.userName,
    required this.equipmentCount,
  });
}
