import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sfi_equipment_tracker/models/account.dart';

class InventoryOwnerRelationship {
  final Account owner;
  final CollectionReference<Map<String, dynamic>> inventoryReference;

  InventoryOwnerRelationship(
      {required this.owner, required this.inventoryReference});

  static Future<InventoryOwnerRelationship> get(String uid) async {
    Account owner = await Account.get(uid);
    if (owner.type == AccountType.coach || owner.type == AccountType.admin) {
      final InventoryOwnerRelationship invOwnRel =
          getCoachFromSnapshot(owner.snapshot);
      return invOwnRel;
    } else if (owner.type == AccountType.storageLocation) {
      final InventoryOwnerRelationship invOwnRel =
          getStorageLocationFromSnapshot(owner.snapshot);
      return invOwnRel;
    } else {
      throw Exception("No user with uid $uid, account type ${owner.type}");
    }
  }

  static Future<InventoryOwnerRelationship> getCoach(String uid) async {
    final db = FirebaseFirestore.instance;
    //check if doc with uid is in users collection (if statement)
    final DocumentSnapshot<Map<String, dynamic>> userRef =
        await db.collection('users').doc(uid).get();
    return getCoachFromSnapshot(userRef);
  }

  static InventoryOwnerRelationship getCoachFromSnapshot(
    DocumentSnapshot userRef,
  ) {
    final db = FirebaseFirestore.instance;
    if (userRef.exists) {
      final Account owner = Account.getCoachAccountFromSnapshot(userRef);
      final CollectionReference<Map<String, dynamic>> reference =
          db.collection("users").doc(owner.uid).collection("inventory");
      final InventoryOwnerRelationship inventoryOwnerRelationship =
          InventoryOwnerRelationship(
        owner: owner,
        inventoryReference: reference,
      );
      return inventoryOwnerRelationship;
    } else {
      throw Exception("No user with uid ${userRef.id}");
    }
  }

  static Future<List<InventoryOwnerRelationship>>
      getAllCoachInvOwnRels() async {
    final List<InventoryOwnerRelationship> inventoryRefs = [];
    final db = FirebaseFirestore.instance;
    final QuerySnapshot usersSnapshot = await db.collection("users").get();
    for (var userSnapshot in usersSnapshot.docs) {
      final InventoryOwnerRelationship inventoryReference =
          InventoryOwnerRelationship.getCoachFromSnapshot(userSnapshot);
      inventoryRefs.add(inventoryReference);
    }

    return inventoryRefs;
  }

  static InventoryOwnerRelationship getStorageLocationFromSnapshot(
    DocumentSnapshot<Object?> storageLocationRef,
  ) {
    final db = FirebaseFirestore.instance;
    if (storageLocationRef.exists) {
      final Account owner =
          Account.getStorageLocationAccountFromSnapshot(storageLocationRef);

      final CollectionReference<Map<String, dynamic>> reference = db
          .collection("storageLocations")
          .doc(owner.uid)
          .collection("inventory");
      final InventoryOwnerRelationship inventoryOwnerRelationship =
          InventoryOwnerRelationship(
        owner: owner,
        inventoryReference: reference,
      );
      return inventoryOwnerRelationship;
    } else {
      throw Exception("No user with uid ${storageLocationRef.id}");
    }
  }

  static Future<InventoryOwnerRelationship> getStorageLocation(
      String uid) async {
    final db = FirebaseFirestore.instance;
    //check if doc with uid is in users collection (if statement)
    final DocumentSnapshot<Map<String, dynamic>> storageLocationRef =
        await db.collection('storageLocations').doc(uid).get();
    return getStorageLocationFromSnapshot(storageLocationRef);
  }

  static Future<List<InventoryOwnerRelationship>>
      getAllStorageLocations() async {
    final List<InventoryOwnerRelationship> inventoryRefs = [];
    final db = FirebaseFirestore.instance;
    final QuerySnapshot storageLocationsSnapshot =
        await db.collection("storageLocations").get();
    for (var storageLocationSnapshot in storageLocationsSnapshot.docs) {
      final InventoryOwnerRelationship inventoryReference =
          InventoryOwnerRelationship.getStorageLocationFromSnapshot(
              storageLocationSnapshot);
      inventoryRefs.add(inventoryReference);
    }

    return inventoryRefs;
  }

  static Future<List<InventoryOwnerRelationship>> getAllInvOwnRels() async {
    final List<InventoryOwnerRelationship> inventoryRefs = [];
    final List<InventoryOwnerRelationship> coachInvOwnRels =
        await getAllCoachInvOwnRels();
    final List<InventoryOwnerRelationship> storageLocationInvOwnRels =
        await getAllStorageLocations();
    inventoryRefs.addAll(coachInvOwnRels);
    inventoryRefs.addAll(storageLocationInvOwnRels);

    return inventoryRefs;
  }

  static InventoryOwnerRelationship getFromAccount(Account account) {
    if (account.type == AccountType.storageLocation) {
      return InventoryOwnerRelationship.getStorageLocationFromSnapshot(
          account.snapshot);
    } else {
      return InventoryOwnerRelationship.getCoachFromSnapshot(account.snapshot);
    }
  }
}
