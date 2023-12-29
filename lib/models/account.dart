import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth_gate.dart';

enum AccountType { admin, coach, storageLocation }

class Account {
  final String name;
  final String uid;
  final AccountType type;
  final DocumentSnapshot<Object?> snapshot;
  Account({
    required this.name,
    required this.uid,
    required this.type,
    required this.snapshot,
  });

  static Future<Account> get(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    //check if doc with uid is in users collection (if statement)
    final DocumentSnapshot<Map<String, dynamic>> potentialUserRef =
        await db.collection('users').doc(uid).get();
    final DocumentSnapshot<Map<String, dynamic>> potentialStorageLocationRef =
        await db.collection('storageLocations').doc(uid).get();
    if (potentialUserRef.exists) {
      final userRef = potentialUserRef;
      DocumentSnapshot user = userRef;
      final Account account = Account.getCoachAccountFromSnapshot(user);

      return account;
    } else if (potentialStorageLocationRef.exists) {
      DocumentSnapshot storageLocation = potentialStorageLocationRef;
      final Account account =
          Account.getStorageLocationAccountFromSnapshot(storageLocation);
      return account;
    } else {
      throw Exception("No user with uid $uid");
    }
  }

  static Future<Account> getCoach(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final userRef = db.collection("users").doc(uid);
    DocumentSnapshot user = await userRef.get();
    final Account account = Account.getCoachAccountFromSnapshot(user);

    return account;
  }

  static Future<Account> getStorageLocation(String uid) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final storageLocationRef = db.collection("storageLocations").doc(uid);

    DocumentSnapshot storageLocation = await storageLocationRef.get();
    final Account account =
        Account.getStorageLocationAccountFromSnapshot(storageLocation);

    return account;
  }

  static Account getStorageLocationAccountFromSnapshot(
      DocumentSnapshot<Object?> snapshot) {
    final Map<String, dynamic> userData =
        snapshot.data() as Map<String, dynamic>;
    final String name = userData['name'];
    final String uid = snapshot.id;
    const AccountType type = AccountType.storageLocation;

    return Account(
      name: name,
      uid: uid,
      type: type,
      snapshot: snapshot,
    );
  }

  static Account getCoachAccountFromSnapshot(
      DocumentSnapshot<Object?> snapshot) {
    final Map<String, dynamic> userData =
        snapshot.data() as Map<String, dynamic>;
    final String name = userData['name'];
    final bool isAdmin = userData['isAdmin'];
    final String uid = snapshot.id;

    return Account(
        name: name,
        uid: uid,
        type: isAdmin ? AccountType.admin : AccountType.coach,
        snapshot: snapshot);
  }

  static Future<List<Account>> getAllCoaches() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final coaches = await db.collection("users").get();
    final List<Account> accounts = [];
    for (var coach in coaches.docs) {
      final Account account = Account.getCoachAccountFromSnapshot(coach);
      accounts.add(account);
    }

    return accounts;
  }

  static Future<List<Account>> getAllStorageLocations() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final storageLocations = await db.collection("storageLocations").get();
    final List<Account> accounts = [];
    for (var storageLocation in storageLocations.docs) {
      final Account account =
          Account.getStorageLocationAccountFromSnapshot(storageLocation);
      accounts.add(account);
    }

    return accounts;
  }

  static Future<List<Account>> getAll() async {
    final List<Account> accounts = [];
    final List<Account> coaches = await Account.getAllCoaches();
    final List<Account> storageLocations =
        await Account.getAllStorageLocations();
    accounts.addAll(coaches);
    accounts.addAll(storageLocations);
    return accounts;
  }

  static Future<Account> getCurrent({
    required BuildContext context,
  }) async {
    if (FirebaseAuth.instance.currentUser != null) {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      return Account.getCoach(currentUserUid);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const AuthGate(),
        ),
      );
      throw Exception("No user logged in");
    }
  }

  static Future<bool> setAdminStatus({
    required String uid,
    required bool isAdmin,
  }) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference<Map<String, dynamic>> userRef =
        db.collection('users').doc(uid);
    try {
      await userRef.update({'isAdmin': isAdmin});
      return true;
    } catch (e) {
      return false;
    }
  }
}
