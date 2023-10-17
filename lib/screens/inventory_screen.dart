import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/widgets/inventory_list_view.dart';
import 'package:sfi_equipment_tracker/widgets/nav_drawer.dart';

class InventoryScreen extends StatefulWidget {
  final InventoryReference inventoryReference;

  const InventoryScreen({Key? key, required this.inventoryReference})
      : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final String name = widget.inventoryReference.name;
    final String uid = widget.inventoryReference.uid;
    final String inventoryTitle = "${name}'s Inventory";
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Inventory',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: SchoolFitnessBlue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              iconSize: 30,
              onPressed: () => {print('hello')},
              icon: const Icon(Icons.search_outlined),
            ),
            IconButton(
              iconSize: 30,
              onPressed: () => {print('hello')},
              icon: const Icon(Icons.grid_view_outlined),
            ),
          ],
        ),
        drawer: const NavDrawer(),
        body: InventoryListView(
          inventoryOwner: Account(
            name: name,
            uid: uid,
          ),
          inventory: widget.inventoryReference.inventoryReference,
          searchCriteria: "",
          tiledView: false,
        ));
    ;
  }
}
