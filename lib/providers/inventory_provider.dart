import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';

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

  static void claimEquipmentItem({
    required Account originAccount,
    required String currentUserUid,
    required String equipmentId,
    required int transferQuota,
  }) async {
    // Get the count of the equipment in the originAccount's inventory
    final db = FirebaseFirestore.instance;
    final originAccountRef = db.collection("users").doc(originAccount.uid);
    final originInventoryRef = originAccountRef.collection("inventory");
    final originEquipmentRef = originInventoryRef.doc(equipmentId);
    final originEquipmentDoc = await originEquipmentRef.get();
    final originEquipmentData =
        originEquipmentDoc.data() as Map<String, dynamic>;
    final int originEquipmentCount = originEquipmentData["quantity"];

    // Check if the equipment is in the current users inventory, if yes, Get the count of the equipment in the originAccount's inventory, if not, print "!!"
    final currentUserRef = db.collection("users").doc(currentUserUid);
    final currentUserInventoryRef = currentUserRef.collection("inventory");
    final currentUserEquipmentRef = currentUserInventoryRef.doc(equipmentId);
    final currentUserEquipmentDoc = await currentUserEquipmentRef.get();
    final currentUserEquipmentData =
        currentUserEquipmentDoc.data() as Map<String, dynamic>;
    int currentUserEquipmentCount = 0;
    // If the equipment is in the current users inventory, update the count of the equipment in the current users inventory
    if (currentUserEquipmentDoc.exists) {
      currentUserEquipmentCount = currentUserEquipmentData["quantity"];
    }
    final int originAccountEquipmentCount =
        originEquipmentCount - transferQuota;
    originEquipmentRef.update({"quantity": originAccountEquipmentCount});
    final int newCurrentUserEquipmentCount =
        currentUserEquipmentCount + transferQuota;
    currentUserEquipmentRef.update({"quantity": newCurrentUserEquipmentCount});

    cleanupInventory(originInventoryRef);
  }

  static void cleanupInventory(
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

class InventoryReference {
  final String uid;
  final String type;
  final String name;
  final CollectionReference<Map<String, dynamic>> inventoryReference;

  InventoryReference(
      {required this.uid,
      required this.type,
      required this.name,
      required this.inventoryReference});

  static Future<InventoryReference> get(String uid) async {
    final db = FirebaseFirestore.instance;
    final DocumentSnapshot userSnapshot =
        await db.collection("users").doc(uid).get();
    final Map userData = userSnapshot.data() as Map;
    const String type = "coach";
    final String name = userData["name"];
    final CollectionReference<Map<String, dynamic>> reference =
        db.collection("users").doc(userSnapshot.id).collection("inventory");
    final InventoryReference inventoryReference = InventoryReference(
        uid: uid, type: type, name: name, inventoryReference: reference);

    return inventoryReference;
  }

  static Future<List<InventoryReference>> getAll() async {
    final List<InventoryReference> inventoryRefs = [];
    final db = FirebaseFirestore.instance;
    final QuerySnapshot usersSnapshot = await db.collection("users").get();
    for (var userSnapshot in usersSnapshot.docs) {
      final String id = userSnapshot.id;
      const String type = "coach";
      final Map userData = userSnapshot.data() as Map;
      final String name = userData["name"];
      final CollectionReference<Map<String, dynamic>> reference =
          db.collection("users").doc(userSnapshot.id).collection("inventory");
      final InventoryReference inventoryReference = InventoryReference(
          uid: id, type: type, name: name, inventoryReference: reference);
      inventoryRefs.add(inventoryReference);
    }

    return inventoryRefs;
  }
}
