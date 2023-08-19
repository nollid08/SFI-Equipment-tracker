import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> isUserInitialised(String uid) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final user = await db.collection("users").doc(uid).get();
  final bool isUserInitialised = user.exists;
  return isUserInitialised;
}

void initialiseUser({required String uid, required String name}) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final newUser = {
    "name": name,
    "inventory": null,
    "isAdmin": false,
  };

  db
      .collection("users")
      .doc(uid)
      .set(newUser)
      .onError((e, _) => print("Error writing document: $e"));
}
