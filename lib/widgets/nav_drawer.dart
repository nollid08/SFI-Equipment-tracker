import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/add_new_stock.dart';
import 'package:sfi_equipment_tracker/screens/all_equipment.dart';
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';
import 'package:sfi_equipment_tracker/widgets/inventories_list.dart';

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
            onTap: () async {
              if (FirebaseAuth.instance.currentUser != null) {
                String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
                final InventoryReference inventoryRef =
                    await InventoryReference.get(currentUserUid);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InventoryScreen(
                        inventoryReference: inventoryRef,
                      ),
                    ),
                  );
                }
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const AuthGate(),
                  ),
                );
              }
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
          const InventoriesList(),
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
