import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/widgets/nav_drawer.dart';

class PersonalInventory extends StatelessWidget {
  const PersonalInventory({super.key});

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
              onPressed: () => {print('hello')},
              icon: const Icon(Icons.search_outlined),
            ),
            IconButton(
              iconSize: 30,
              onPressed: () => {print('hello')},
              icon: const Icon(Icons.filter_alt_outlined),
            ),
          ],
        ),
        drawer: const NavDrawer(
          currentPageId: "legacy-personal-inventory",
        ),
        body: Inventory(uid: uid),
      );
    } else {
      return const Text('error #00002');
    }
  }
}

class Inventory extends StatefulWidget {
  final String uid;

  const Inventory({Key? key, required this.uid}) : super(key: key);

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late final Stream<QuerySnapshot> _inventoryStream = FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .collection("inventory")
      .snapshots();

  _InventoryState();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _inventoryStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print("error");
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print("loading");
          return const Text("Loading");
        }
        return ListView(
          children: snapshot.data!.docs
              .map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                print(data.toString());
                return ListTile(
                  title: Text(document.id.toString()),
                  subtitle: Text(data['quantity'].toString()),
                );
              })
              .toList()
              .cast(),
        );
      },
    );
  }
}
