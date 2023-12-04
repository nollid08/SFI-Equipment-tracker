import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/widgets/admins_list_view.dart';
import 'package:sfi_equipment_tracker/widgets/create_inventory.dart';
import 'package:sfi_equipment_tracker/widgets/storage_locations_list_view.dart';
import '../constants.dart';
import '../widgets/nav_drawer.dart';

class ManageAdmins extends StatelessWidget {
  const ManageAdmins({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manage Admins',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: SchoolFitnessBlue,
          foregroundColor: Colors.white,
        ),
        drawer: const NavDrawer(
          currentPageId: "manage-storage-locations",
        ),
        body: const AdminsListView(
          searchCriteria: "",
        ));
  }
}
