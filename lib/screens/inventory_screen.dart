import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/widgets/adapted_scaffold.dart';
import 'package:sfi_equipment_tracker/widgets/list_views/inventory_list_view.dart';
import 'package:sfi_equipment_tracker/widgets/drawer/nav_drawer.dart';
import 'package:sfi_equipment_tracker/widgets/search_delegates.dart';

import '../models/inventory_owner_relationship.dart';

class InventoryScreen extends StatefulWidget {
  final InventoryOwnerRelationship invOwnRel;

  const InventoryScreen({Key? key, required this.invOwnRel}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      final InventoryOwnerRelationship invOwnRel = widget.invOwnRel;
      final String name = invOwnRel.owner.name;
      final String uid = invOwnRel.owner.uid;
      String inventoryTitle = "${name.split(' ').first}'s Inventory";
      bool isPersonalInventory = false;

      if (currentUserUid == uid) {
        inventoryTitle = "My Inventory";
        isPersonalInventory = true;
      } else if (invOwnRel.owner.type == AccountType.storageLocation) {
        inventoryTitle = name;
      }

      return AdaptedScaffold(
          title: inventoryTitle,
          actions: [
            IconButton(
              iconSize: 30,
              onPressed: () => {
                showSearch(
                  context: context,
                  delegate: InventorySearchDelegate(
                      invOwnRel: invOwnRel,
                      isPersonalInventory: isPersonalInventory),
                ),
              },
              icon: const Icon(Icons.search_outlined),
            ),
          ],
          currentPageId:
              isPersonalInventory ? "inventory-personal" : "inventory-$uid",
          body: InventoryListView(
            invOwnRel: widget.invOwnRel,
            isPersonalInventory: isPersonalInventory,
            searchCriteria: "",
            tiledView: false,
          ));
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
    }
  }
}
