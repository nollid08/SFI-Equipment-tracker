import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/add_new_stock.dart';
import 'package:sfi_equipment_tracker/screens/all_equipment.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Image(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('My Inventory'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('All Equipment'),
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllEquipment()),
              );
            },
          ),
          FutureBuilder(
              future: Inventory.getAllInventoryRefs(),
              builder:
                  (context, AsyncSnapshot<List<InventoryReference>> snapshot) {
                if (snapshot.hasData) {
                  final List<ListTile> listTiles = [];
                  final List<InventoryReference> inventoryRefs = snapshot.data!;
                  inventoryRefs.forEach((inventoryRef) {
                    final String name = inventoryRef.name;
                    final String listTileTitle = "${name}'s Inventory";
                    print(listTileTitle);
                    final listTile = ListTile(
                      title: Text(listTileTitle),
                      selected: false,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InventoryScreen(
                                    inventoryReference: inventoryRef,
                                  )),
                        );
                      },
                    );
                    listTiles.add(listTile);
                  });
                  return Column(
                    children: listTiles,
                  );
                } else if (snapshot.hasError) {
                  return const Text('Something went wrong');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          const Divider(
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Admin',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                    fontSize: 18),
              ),
            ),
          ),
          ListTile(
            title: const Text('Add New Stock'),
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddNewStock()),
              );
            },
          ),
        ],
      ),
    );
  }
}
