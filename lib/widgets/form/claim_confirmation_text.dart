import 'package:flutter/material.dart';

class ClaimConfirmationText extends StatelessWidget {
  const ClaimConfirmationText({
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
            text: 'from ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: "$inventoryOwnerFirstName's inventory ",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const TextSpan(
            text: ' to my inventory',
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
