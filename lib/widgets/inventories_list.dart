import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';

class InventoriesList extends StatelessWidget {
  final String currentPageId;
  const InventoriesList({
    super.key,
    required this.currentPageId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: InventoryReference.getAll(),
        builder: (context, AsyncSnapshot<List<InventoryReference>> snapshot) {
          if (snapshot.hasData) {
            if (FirebaseAuth.instance.currentUser != null) {
              String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
              final List<ListTile> listTiles = [];
              final List<InventoryReference> inventoryRefs = snapshot.data!;
              inventoryRefs.forEach((inventoryRef) {
                if (inventoryRef.uid != currentUserUid) {
                  final String name = inventoryRef.name;
                  final String listTileTitle = "${name}'s Inventory";

                  print(listTileTitle);
                  final listTile = ListTile(
                      title: Text(listTileTitle),
                      selected:
                          currentPageId == 'inventory-${inventoryRef.uid}',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InventoryScreen(
                                    inventoryReference: inventoryRef,
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
              return const CircularProgressIndicator();
            }
          } else if (snapshot.hasError) {
            return const Text('Something went wrong');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
