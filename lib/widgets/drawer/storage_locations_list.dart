import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';

class StorageLocationsList extends StatelessWidget {
  final String currentPageId;
  const StorageLocationsList({
    super.key,
    required this.currentPageId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Storage Locations',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
              fontSize: 18),
        ),
        FutureBuilder(
            future: InventoryOwnerRelationship.getAllStorageLocations(),
            builder: (context,
                AsyncSnapshot<List<InventoryOwnerRelationship>> snapshot) {
              if (snapshot.hasData) {
                if (FirebaseAuth.instance.currentUser != null) {
                  String currentUserUid =
                      FirebaseAuth.instance.currentUser!.uid;
                  final List<ListTile> listTiles = [];
                  final List<InventoryOwnerRelationship> invOwnRels =
                      snapshot.data!;
                  invOwnRels.forEach((invOwnRel) {
                    if (invOwnRel.owner.uid != currentUserUid) {
                      final String name = invOwnRel.owner.name;

                      final listTile = ListTile(
                          title: Text(name),
                          selected: currentPageId ==
                              'inventory-${invOwnRel.owner.uid}',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InventoryScreen(
                                        invOwnRel: invOwnRel,
                                      )),
                            );
                          });
                      listTiles.add(listTile);
                    } else {
                      return;
                    }
                  });
                  return Column(
                    children: listTiles,
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const AuthGate(),
                    ),
                  );
                  return const Center(
                    child: SizedBox.square(
                      dimension: 100,
                      child: CircularProgressIndicator(),
                    ),
                  );
                  ;
                }
              } else if (snapshot.hasError) {
                return const Text('Something went wrong');
              } else {
                return const Center(
                  child: SizedBox.square(
                    dimension: 100,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            }),
      ],
    );
  }
}
