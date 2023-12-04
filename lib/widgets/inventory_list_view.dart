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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: invOwnRel.inventoryReference.snapshots(),
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
