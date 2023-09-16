import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';

class Account {
  final String name;
  final String uid;
  final bool isAdmin;
  final List<InventoryItem> inventory;

  Account(
      {required this.name,
      required this.uid,
      required this.isAdmin,
      required this.inventory});

  static Future<Account> get(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final userRef = db.collection("users").doc(uid);
    try {
      DocumentSnapshot user = await userRef.get();
      final Map userData = user.data() as Map;
      final Inventory inventory = await Inventory.get(uid);
      return Account(
          name: userData['name'],
          uid: uid,
          isAdmin: userData['isAdmin'],
          inventory: inventory.inventory);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
