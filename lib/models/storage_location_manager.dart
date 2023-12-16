import 'package:cloud_firestore/cloud_firestore.dart';

class StorageLocationManager {
  static void create(String name) {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final storageLocationRef = db.collection("storageLocations").doc();
    storageLocationRef.set({
      "name": name,
    });
  }

  static Future<bool> delete(String id) async {
    //If storageLoc inventory subcollection is empty, delete and return true, otherwise return false
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final storageLocationRef = db.collection("storageLocations").doc(id);
    final QuerySnapshot<Map<String, dynamic>> inventorySnapshot =
        await storageLocationRef.collection("inventory").get();
    if (inventorySnapshot.docs.isEmpty) {
      storageLocationRef.delete();
      return true;
    } else {
      return false;
    }
  }
}
