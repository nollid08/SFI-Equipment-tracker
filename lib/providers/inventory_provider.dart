import 'package:cloud_firestore/cloud_firestore.dart';

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

  static Future<List<InventoryReference>> getAllInventoryRefs() async {
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
          id: id, type: type, name: name, inventoryReference: reference);
      inventoryRefs.add(inventoryReference);
    }

    return inventoryRefs;
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
  final String id;
  final String type;
  final String name;
  final CollectionReference<Map<String, dynamic>> inventoryReference;

  InventoryReference(
      {required this.id,
      required this.type,
      required this.name,
      required this.inventoryReference});
}
