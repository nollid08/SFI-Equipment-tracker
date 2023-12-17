import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/screens/manage_admins.dart';
import 'package:sfi_equipment_tracker/screens/manage_stock.dart';
import 'package:sfi_equipment_tracker/screens/all_equipment.dart';
import 'package:sfi_equipment_tracker/screens/auth_gate.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';
import 'package:sfi_equipment_tracker/screens/manage_storage_locations.dart';
import 'package:sfi_equipment_tracker/screens/report_mising_equipment_screen.dart';
import 'package:sfi_equipment_tracker/widgets/drawer/admin_navigation_area.dart';
import 'package:sfi_equipment_tracker/widgets/drawer/inventories_list.dart';
import 'package:sfi_equipment_tracker/widgets/drawer/storage_locations_list.dart';

import '../../models/inventory_owner_relationship.dart';

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
      width: 320,
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
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Divider(
              height: 1,
            ),
          ),
          InventoriesList(
            currentPageId: widget.currentPageId,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Divider(
              height: 1,
            ),
          ),
          StorageLocationsList(
            currentPageId: widget.currentPageId,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 4.0, left: 12.0, right: 12.0),
            child: Divider(
              height: 1,
            ),
          ),
          ListTile(
            title: const Text('Report Missing/Damaged Equipment'),
            selected: widget.currentPageId == 'report_missing_equipment',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReportMissingEquipmentScreen()),
              );
            },
          ),
          AdminNavigationArea(
            currentPageId: widget.currentPageId,
          ),
        ],
      ),
    );
  }
}
