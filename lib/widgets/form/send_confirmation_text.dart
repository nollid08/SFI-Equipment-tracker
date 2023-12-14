import 'package:flutter/material.dart';

class SendConfirmationText extends StatelessWidget {
  const SendConfirmationText({
    super.key,
    required this.equipmentCount,
    required this.equipmentItemName,
    required this.inventoryOwnerFullName,
  });

  final int equipmentCount;
  final String equipmentItemName;
  final String inventoryOwnerFullName;

  @override
  Widget build(BuildContext context) {
    final String inventoryOwnerFirstName = inventoryOwnerFullName.split(" ")[0];
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'I confirm that I want to transfer ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: '${equipmentCount.toString()} $equipmentItemName ',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const TextSpan(
            text: 'from my inventory to ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: "$inventoryOwnerFirstName's Inventory",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
