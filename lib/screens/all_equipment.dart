import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/widgets/equipment_card.dart';
import 'package:sfi_equipment_tracker/widgets/equipment_image.dart';
import 'package:sfi_equipment_tracker/widgets/nav_drawer.dart';

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
        drawer: const NavDrawer(),
        body: GlobalInventoryListView(uid: uid),
      );
    } else {
      return const Text('error #00002');
    }
  }
}

class GlobalInventoryListView extends StatefulWidget {
  final String uid;

  const GlobalInventoryListView({Key? key, required this.uid})
      : super(key: key);

  @override
  State<GlobalInventoryListView> createState() =>
      _GlobalInventoryListViewState();
}

class _GlobalInventoryListViewState extends State<GlobalInventoryListView> {
  _GlobalInventoryListViewState();

  @override
  Widget build(BuildContext context) {
    //Using a stream builder to get the data from the Equipment Collection in the db, retrieve all equipment and return its name, total quantity and image in a ListView
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('equipment')
          .orderBy('name')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          //If there is an error, return a Text widget with the error
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          //If the connection is waiting, return a circular progress indicator
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            final Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final String equipmentId = document.id;
            final String name = data['name'];
            final int quantity = data['totalQuantity'];
            final String imageRef = data['imageRef'];

            return ListTile(
              leading: EquipmentImage(imageRef: imageRef),
              title: Text(name),
              subtitle: Text('Total Quantity: $quantity'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return EquipmentCard(
                      equipmentId: equipmentId,
                    );
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
