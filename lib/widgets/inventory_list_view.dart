import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/widgets/equipment_image.dart';
import 'package:sfi_equipment_tracker/widgets/claim_equipment.dart';

class InventoryListView extends StatelessWidget {
  final CollectionReference<Map<String, dynamic>> inventory;
  final String searchCriteria;
  final Account inventoryOwner;
  final bool tiledView;

  const InventoryListView({
    Key? key,
    required this.inventory,
    required this.searchCriteria,
    required this.tiledView,
    required this.inventoryOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: inventory.snapshots(),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.hasData) {
          final QuerySnapshot<Map<String, dynamic>> inventorySnapshot =
              snapshot.data!;
          return FutureBuilder(
            future: Inventory.getFromSnapshot(inventorySnapshot),
            builder: (BuildContext context, AsyncSnapshot<Inventory> snapshot) {
              if (snapshot.hasData) {
                final Inventory inventory = snapshot.data!;
                return ListView.builder(
                  itemCount: inventory.inventory.length,
                  itemBuilder: (BuildContext context, int index) {
                    final InventoryItem item = inventory.inventory[index];
                    if (item.name.toLowerCase().contains(searchCriteria)) {
                      return ListTile(
                        leading: EquipmentImage(imageRef: item.imageRef),
                        title: Text(item.name),
                        subtitle: Text(item.quantity.toString()),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: ClaimEquipment(
                                close: () => {
                                  print("close dialog"),
                                },
                                inventoryOwner: inventoryOwner,
                                inventoryItem: item,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              } else if (snapshot.hasError) {
                return const Text("error 4049");
              } else {
                return const CircularProgressIndicator();
              }
            },
          );
        } else if (snapshot.hasError) {
          return const Text('Something went wrong');
        } else {
          return const Text("Loading");
        }
      },
    );
  }
}
