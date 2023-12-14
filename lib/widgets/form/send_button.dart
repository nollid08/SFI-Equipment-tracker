import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/widgets/modals/send_equipment.dart';

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
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: FutureBuilder<Object>(
                  future: InventoryOwnerRelationship.getAllInvOwnRels(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<InventoryOwnerRelationship> invOwnRels =
                          snapshot.data as List<InventoryOwnerRelationship>;
                      return SendEquipmentDialog(
                        inventoryItem: item,
                        inventoryRefs: invOwnRels,
                      );
                    } else {
                      return const SizedBox(
                        height: 400,
                        width: 250,
                        child: Center(
                          child: SizedBox.square(
                            dimension: 100,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                  }),
            ),
          );
        }
      },
    );
  }
}
