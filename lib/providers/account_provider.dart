import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth_gate.dart';

enum AccountType { admin, coach, storageLocation }

class Account {
  final String name;
  final String uid;
  final AccountType type;

  Account({
    required this.name,
    required this.uid,
    required this.type,
  });

  static Future<Account> get(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    //check if doc with uid is in users collection (if statement)
    final DocumentSnapshot<Map<String, dynamic>> potentialUserRef =
        await db.collection('users').doc(uid).get();
    final DocumentSnapshot<Map<String, dynamic>> potentialStorageLocationRef =
        await db.collection('storageLocations').doc(uid).get();
    if (potentialUserRef.exists) {
      final userRef = db.collection("users").doc(uid);
      try {
        DocumentSnapshot user = await userRef.get();
        final Map userData = user.data() as Map;
        final String name = userData['name'];
        final bool isAdmin = userData['isAdmin'];
        final AccountType type =
            isAdmin ? AccountType.admin : AccountType.coach;

        return Account(
          name: name,
          uid: uid,
          type: type,
        );
      } catch (e) {
        print(e);
        rethrow;
      }
    } else if (potentialStorageLocationRef.exists) {
      final storageLocationRef = db.collection("storageLocations").doc(uid);
      try {
        DocumentSnapshot storageLocation = await storageLocationRef.get();
        final Map userData = storageLocation.data() as Map;
        final String name = userData['name'];
        const AccountType type = AccountType.storageLocation;

        return Account(
          name: name,
          uid: uid,
          type: type,
        );
      } catch (e) {
        print(e);
        rethrow;
      }
    } else {
      throw Exception("No user with uid $uid");
    }
  }

  static Future<Account> getCurrent({
    required BuildContext context,
  }) async {
    if (FirebaseAuth.instance.currentUser != null) {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      return Account.get(currentUserUid);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const AuthGate(),
        ),
      );

      return Account(name: "", uid: "", type: AccountType.coach);
    }
  }
}
