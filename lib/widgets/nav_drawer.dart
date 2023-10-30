import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/add_new_stock.dart';
import 'package:sfi_equipment_tracker/screens/all_equipment.dart';
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';
import 'package:sfi_equipment_tracker/widgets/inventories_list.dart';

class NavDrawer extends StatelessWidget {
  final String currentPageId;

  const NavDrawer({
    super.key,
    required this.currentPageId,
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
            selected: currentPageId == 'inventory-personal',
            onTap: () async {
              if (FirebaseAuth.instance.currentUser != null) {
                String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
                final InventoryOwnerRelationship inventoryRef =
                    await InventoryOwnerRelationship.get(currentUserUid);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InventoryScreen(
                        invOwnRel: inventoryRef,
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
            selected: currentPageId == 'global-inventory',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllEquipment()),
              );
            },
          ),
          InventoriesList(
            currentPageId: currentPageId,
          ),
          FutureBuilder(
              future: Account.getCurrent(
                context: context,
              ),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  Account account = snapshot.data;
                  if (account.type == AccountType.admin) {
                    return Column(
                      children: [
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
                          title: const Text(
                            'Add New Stock',
                          ),
                          selected: currentPageId == 'add-new-stock',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AddNewStock()),
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                } else if (snapshot.hasError) {
                  return const Text('Error 5407');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ],
      ),
    );
  }
}
