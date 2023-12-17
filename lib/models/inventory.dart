import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_owner_relationship.dart';

class Inventory {
  final List<InventoryItem> inventory;

  Inventory({required this.inventory});

  static Future<Inventory> get(String uid) async {
    final List<InventoryItem> inventory = [];

    final db = FirebaseFirestore.instance;
    final userRef = db.collection("users").doc(uid);
    final inventoryRef = userRef.collection("inventory");
    //get all Documents in the inventory

    final QuerySnapshot inventorySnapshot = await inventoryRef.get();
    // Loop over each item in inventory
    for (final inventoryItem in inventorySnapshot.docs) {
      final Map<String, dynamic> baseItemData =
          inventoryItem.data() as Map<String, dynamic>;

      final String id = inventoryItem.id;
      final int quantity = baseItemData["quantity"];
      // Get name and image

      final globalInventoryRef = db.collection("equipment").doc(id);
      final doc = await globalInventoryRef.get();
      final supplementaryItemData = doc.data() as Map<String, dynamic>;

      final String imageRef = supplementaryItemData["imageRef"];
      final String name = supplementaryItemData["name"];

      inventory.add(
        InventoryItem(
          id: id,
          name: name,
          quantity: quantity,
          imageRef: imageRef,
        ),
      );
    }
    return Inventory(inventory: inventory);
  }

  static Future<Inventory> getFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> inventorySnapshot) async {
    final List<InventoryItem> inventory = [];

    final db = FirebaseFirestore.instance;

    for (final inventoryItem in inventorySnapshot.docs) {
      final Map<String, dynamic> baseItemData = inventoryItem.data();

      final String id = inventoryItem.id;
      final int quantity = baseItemData["quantity"];
      // Get name and image

      final globalInventoryRef = db.collection("equipment").doc(id);
      final doc = await globalInventoryRef.get();
      final supplementaryItemData = doc.data() as Map<String, dynamic>;

      final String imageRef = supplementaryItemData["imageRef"];
      final String name = supplementaryItemData["name"];

      inventory.add(
        InventoryItem(
          id: id,
          name: name,
          quantity: quantity,
          imageRef: imageRef,
        ),
      );
    }

    return Inventory(inventory: inventory);
  }

  static void transferEquipmentItem({
    required String origineeUid,
    required String recipientUid,
    required String equipmentId,
    required int transferQuota,
  }) async {
    final InventoryOwnerRelationship originInvOwnRel =
        await InventoryOwnerRelationship.get(origineeUid);
    final originEquipmentRef =
        originInvOwnRel.inventoryReference.doc(equipmentId);
    final originEquipmentDoc = await originEquipmentRef.get();
    final originEquipmentData =
        originEquipmentDoc.data() as Map<String, dynamic>;
    final int originEquipmentCount = originEquipmentData["quantity"];

    final InventoryOwnerRelationship recipientInvOwnRel =
        await InventoryOwnerRelationship.get(recipientUid);
    final recipientEquipmentRef =
        recipientInvOwnRel.inventoryReference.doc(equipmentId);
    final recipientEquipmentDoc = await recipientEquipmentRef.get();
    int recipientEquipmentCount = 0;

    // If the equipment is in the current users inventory, update the count of the equipment in the current users inventory
    if (recipientEquipmentDoc.exists) {
      final recipientEquipmentData =
          recipientEquipmentDoc.data() as Map<String, dynamic>;
      recipientEquipmentCount = recipientEquipmentData["quantity"];
    }

    final int originAccountEquipmentCount =
        originEquipmentCount - transferQuota;
    await originEquipmentRef.update({"quantity": originAccountEquipmentCount});
    final int newrecipientEquipmentCount =
        recipientEquipmentCount + transferQuota;
    if (recipientEquipmentDoc.exists) {
      await recipientEquipmentRef
          .update({"quantity": newrecipientEquipmentCount});
    } else {
      await recipientEquipmentRef.set({"quantity": newrecipientEquipmentCount});
    }
    // Get rid of equipment items with a count of 0!
    cleanUpInventory(originInvOwnRel.inventoryReference);
    cleanUpInventory(recipientInvOwnRel.inventoryReference);
  }

  static void addEquipmentItem({
    required InventoryOwnerRelationship invOwnRel,
    required String equipmentId,
    required int quantity,
  }) async {
    final equipmentRef = invOwnRel.inventoryReference.doc(equipmentId);
    final equipmentDoc = await equipmentRef.get();
    int equipmentCount = 0;

    // If the equipment is in the current users inventory, update the count of the equipment in the current users inventory
    if (equipmentDoc.exists) {
      final equipmentData = equipmentDoc.data() as Map<String, dynamic>;
      equipmentCount = equipmentData["quantity"];
    }

    final int newEquipmentCount = equipmentCount + quantity;
    if (equipmentDoc.exists) {
      await equipmentRef.update({"quantity": newEquipmentCount});
    } else {
      await equipmentRef.set({"quantity": newEquipmentCount});
    }
  }

  static void cleanUpInventory(
      CollectionReference<Map<String, dynamic>> inventoryRef) async {
    final QuerySnapshot<Map<String, dynamic>> inventorySnapshot =
        await inventoryRef.get();
    for (var inventoryItem in inventorySnapshot.docs) {
      final Map<String, dynamic> inventoryItemData = inventoryItem.data();
      final int quantity = inventoryItemData["quantity"];
      if (quantity == 0) {
        inventoryItem.reference.delete();
      }
    }
  }
}

class InventoryItem {
  final String id;
  final String name;
  final int quantity;
  final String imageRef;

  InventoryItem(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.imageRef});
}
