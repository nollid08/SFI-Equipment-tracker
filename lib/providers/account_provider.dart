import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String name;
  final String uid;
  final bool isAdmin;
  final Map inventory;

  Account(
      {required this.name,
      required this.uid,
      required this.isAdmin,
      required this.inventory});

  static Future<Account> get(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final docRef = db.collection("users").doc(uid);
    DocumentSnapshot doc = await docRef.get();
    final Map data = doc.data() as Map;
    return Account(
        name: data['name'],
        uid: uid,
        isAdmin: data['isAdmin'],
        inventory: data['inventory']);
  }
}
