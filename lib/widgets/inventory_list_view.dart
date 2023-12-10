import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/widgets/equipment_image.dart';
import 'package:sfi_equipment_tracker/widgets/claim_equipment.dart';
import 'package:sfi_equipment_tracker/widgets/send_equipment.dart';

class InventoryListView extends StatelessWidget {
  final String searchCriteria;
  final bool tiledView;
  final InventoryOwnerRelationship invOwnRel;
  final bool isPersonalInventory;

  const InventoryListView({
    Key? key,
    required this.searchCriteria,
    required this.tiledView,
    required this.invOwnRel,
    required this.isPersonalInventory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final CollectionReference inventoryReference = invOwnRel.inventoryReference;
    print(invOwnRel);
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final inventoryReference =
        db.collection("users").doc(invOwnRel.owner.uid).collection("inventory");

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

class ClaimButton extends StatelessWidget {
  const ClaimButton({
    super.key,
    required this.inventoryOwner,
    required this.item,
  });

  final Account inventoryOwner;
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: const Text("Claim"),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: ClaimEquipmentDialog(
              inventoryOwner: inventoryOwner,
              inventoryItem: item,
            ),
          ),
        );
      },
    );
  }
}

class SendButton extends StatelessWidget {
  const SendButton({
    super.key,
    required this.inventoryOwner,
    required this.item,
  });

  final Account inventoryOwner;
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: const Text("Send"),
      onPressed: () async {
        print("Send Equipment");
        final inventoryRefs =
            await InventoryOwnerRelationship.getAllInvOwnRels();
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: SendEquipmentDialog(
                inventoryItem: item,
                inventoryRefs: inventoryRefs,
              ),
            ),
          );
        }
      },
    );
  }
}
