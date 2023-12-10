import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/manage_admins.dart';
import 'package:sfi_equipment_tracker/screens/manage_stock.dart';
import 'package:sfi_equipment_tracker/screens/all_equipment.dart';
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';
import 'package:sfi_equipment_tracker/screens/manage_storage_locations.dart';
import 'package:sfi_equipment_tracker/widgets/inventories_list.dart';
import 'package:sfi_equipment_tracker/widgets/storage_locations_list.dart';

class NavDrawer extends StatefulWidget {
  final String currentPageId;

  const NavDrawer({
    super.key,
    required this.currentPageId,
  });

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
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
            selected: widget.currentPageId == 'inventory-personal',
            onTap: () async {
              if (FirebaseAuth.instance.currentUser != null) {
                String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
                final InventoryOwnerRelationship inventoryRef =
                    await InventoryOwnerRelationship.get(currentUserUid);
                if (context.mounted) {
                  Navigator.pushReplacement(
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
            selected: widget.currentPageId == 'global-inventory',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AllEquipment()),
              );
            },
          ),
          InventoriesList(
            currentPageId: widget.currentPageId,
          ),
          StorageLocationsList(
            currentPageId: widget.currentPageId,
          ),
          AdminNavigationArea(
            currentPageId: widget.currentPageId,
          ),
        ],
      ),
    );
  }
}

class AdminNavigationArea extends StatelessWidget {
  const AdminNavigationArea({
    super.key,
    required this.currentPageId,
  });

  final String currentPageId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
                      'Manage Stock',
                    ),
                    selected: currentPageId == 'manage-stock',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageStock()),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Manage Storage Locations',
                    ),
                    selected: currentPageId == 'manage-storage-locations',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageStorageLocations(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Manage Admins',
                    ),
                    selected: currentPageId == 'manage-admins',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageAdmins(),
                        ),
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
            return const Center(
                child: Center(
              child: SizedBox.square(
                dimension: 100,
                child: CircularProgressIndicator(),
              ),
            ));
          }
        });
  }
}
