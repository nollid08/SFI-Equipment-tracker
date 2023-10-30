import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth_gate.dart';

enum AccountType { admin, coach, storageLoc }

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
    final userRef = db.collection("users").doc(uid);
    try {
      DocumentSnapshot user = await userRef.get();
      final Map userData = user.data() as Map;
      final String name = userData['name'];
      final bool isAdmin = userData['isAdmin'];
      final AccountType type = isAdmin ? AccountType.admin : AccountType.coach;

      return Account(
        name: name,
        uid: uid,
        type: type,
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<Account> getCurrent({
    required BuildContext context,
  }) async {
    if (FirebaseAuth.instance.currentUser != null) {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final userRef = db.collection("users").doc(currentUserUid);
      try {
        DocumentSnapshot user = await userRef.get();
        final Map userData = user.data() as Map;
        final String name = userData['name'];
        final bool isAdmin = userData['isAdmin'];
        final AccountType type =
            isAdmin ? AccountType.admin : AccountType.coach;
        return Account(
          name: name,
          uid: currentUserUid,
          type: type,
        );
      } catch (e) {
        print(e);
        rethrow;
      }
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
