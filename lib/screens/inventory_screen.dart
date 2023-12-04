import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/widgets/inventory_list_view.dart';
import 'package:sfi_equipment_tracker/widgets/nav_drawer.dart';
import 'package:sfi_equipment_tracker/widgets/search_delegates.dart';

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

      return Scaffold(
          appBar: AppBar(
            title: Text(
              inventoryTitle,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: SchoolFitnessBlue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                iconSize: 30,
                onPressed: () => {
                  showSearch(
                    context: context,
                    delegate: InventorySearchDelegate(
                        invOwnRel: widget.invOwnRel,
                        isPersonalInventory: isPersonalInventory),
                  )
                },
                icon: const Icon(Icons.search_outlined),
              ),
              // IconButton(
              //   iconSize: 30,
              //   onPressed: () => {print('hello')},
              //   icon: const Icon(Icons.grid_view_outlined),
              // ),
            ],
          ),
          drawer: isPersonalInventory
              ? const NavDrawer(
                  currentPageId: "inventory-personal",
                )
              : NavDrawer(
                  currentPageId: "inventory-$uid",
                ),
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
      return const CircularProgressIndicator();
    }
  }
}
