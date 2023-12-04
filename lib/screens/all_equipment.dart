import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/widgets/global_inventory_list_view.dart';
import 'package:sfi_equipment_tracker/widgets/nav_drawer.dart';
import 'package:sfi_equipment_tracker/widgets/search_delegates.dart';

Future<Map?> getInventory(String uid) async {
  final db = FirebaseFirestore.instance;
  final docRef = db.collection("users").doc(uid);
  final request = await docRef.get();
  final data = request.data();
  final Map? inventory = data?["inventory"];
  return inventory;
}

class AllEquipment extends StatelessWidget {
  const AllEquipment({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      print(uid);
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Inventory',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: SchoolFitnessBlue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              iconSize: 30,
              onPressed: () => {
                showSearch(
                  context: context,
                  delegate: GlobalInventorySearchDelegate(
                    uid: uid,
                  ),
                )
              },
              icon: const Icon(Icons.search_outlined),
            ),
            // IconButton(
            //   iconSize: 30,
            //   onPressed: () => {print('hello')},
            //   icon: const Icon(Icons.filter_alt_outlined),
            // ),
          ],
        ),
        drawer: const NavDrawer(currentPageId: "global-inventory"),
        body: GlobalInventoryListView(uid: uid, searchCriteria: ""),
      );
    } else {
      return const Text('error #00002');
    }
  }
}
