import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/models/inventory.dart';
import 'package:sfi_equipment_tracker/widgets/modals/claim_equipment.dart';

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
