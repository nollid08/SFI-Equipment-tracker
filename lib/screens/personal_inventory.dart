import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/widgets/nav_drawer.dart';

Future<Map?> getInventory(String uid) async {
  final db = FirebaseFirestore.instance;
  final docRef = db.collection("users").doc(uid);
  final request = await docRef.get();
  final data = request.data();
  final Map? inventory = data?["inventory"];
  return inventory;
}

class PersonalInventory extends StatelessWidget {
  const PersonalInventory({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(
          future: getInventory("eztCYCYXUJb8t1sAUdItwBVZEry2"),
          builder: (BuildContext context,
              AsyncSnapshot<Map<dynamic, dynamic>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final Map? inventory = snapshot.data;
                if (inventory != null) {
                  return ListView.builder(
                    itemCount: inventory.length,
                    itemBuilder: (BuildContext context, int index) {
                      String key = inventory.keys.elementAt(index);
                      return Column(
                        children: <Widget>[
                          ListTile(
                            title: Text("$key"),
                            subtitle: Text("${inventory[key]}"),
                          ),
                          const Divider(
                            height: 2.0,
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            } else if (snapshot.connectionState == ConnectionState.none) {
              return const Text("No connection. Error No #000001");
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
