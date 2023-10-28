import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String name;
  final String uid;

  Account({
    required this.name,
    required this.uid,
  });

  static Future<Account> get(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final userRef = db.collection("users").doc(uid);
    try {
      DocumentSnapshot user = await userRef.get();
      final Map userData = user.data() as Map;
      return Account(
        name: userData['name'],
        uid: uid,
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
