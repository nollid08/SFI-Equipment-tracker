import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/widgets/form/claim_button.dart';
import 'package:sfi_equipment_tracker/widgets/form/send_button.dart';
import 'package:sfi_equipment_tracker/widgets/list_views/equipment_image.dart';

class InventoryListView extends StatelessWidget {
  final String searchCriteria;
  final bool tiledView;
  final InventoryOwnerRelationship invOwnRel;
  final bool isPersonalInventory;
  final QuerySnapshot<Map<String, dynamic>>? inventorySnapshot;

  const InventoryListView({
    Key? key,
    required this.searchCriteria,
    required this.tiledView,
    required this.invOwnRel,
    required this.isPersonalInventory,
    this.inventorySnapshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference<Map<String, dynamic>> inventoryReference =
        invOwnRel.inventoryReference;

    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
        inventoryReference.snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: snapshots,
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.hasError) {
          //If there is an error, return a Text widget with the error
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          //If the connection is waiting, return a circular progress indicator
          return const Center(
              child: Center(
            child: SizedBox.square(
              dimension: 400,
              child: CircularProgressIndicator(),
            ),
          ));
        }
        final QuerySnapshot<Map<String, dynamic>> inventorySnapshot =
            snapshot.data!;
        return FutureBuilder(
          future: Inventory.getFromSnapshot(inventorySnapshot),
          builder: (BuildContext context, AsyncSnapshot<Inventory> snapshot) {
            if (snapshot.hasData) {
              final Inventory inventory = snapshot.data!;
              return EquipmentList(
                  inventory: inventory,
                  searchCriteria: searchCriteria,
                  isPersonalInventory: isPersonalInventory,
                  invOwnRel: invOwnRel);
            } else if (snapshot.hasError) {
              return const Text("error 4049");
            } else {
              return const Center(
                child: SizedBox.square(
                  dimension: 100,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class EquipmentList extends StatelessWidget {
  const EquipmentList({
    super.key,
    required this.inventory,
    required this.searchCriteria,
    required this.isPersonalInventory,
    required this.invOwnRel,
  });

  final Inventory inventory;
  final String searchCriteria;
  final bool isPersonalInventory;
  final InventoryOwnerRelationship invOwnRel;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: inventory.inventory.length,
      itemBuilder: (BuildContext context, int index) {
        final InventoryItem item = inventory.inventory[index];
        if (item.name.toLowerCase().contains(searchCriteria)) {
          return ListTile(
            leading: EquipmentImage(imageRef: item.imageRef),
            title: Text(item.name),
            subtitle: Text(item.quantity.toString()),
            trailing: isPersonalInventory
                ? SendButton(
                    inventoryOwner: invOwnRel.owner,
                    item: item,
                  )
                : ClaimButton(
                    inventoryOwner: invOwnRel.owner,
                    item: item,
                  ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
      separatorBuilder: (context, index) {
        final InventoryItem item = inventory.inventory[index];
        if (item.name.toLowerCase().contains(searchCriteria)) {
          return const Divider();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
