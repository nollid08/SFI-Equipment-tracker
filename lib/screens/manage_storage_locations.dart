import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/widgets/add_new_equipment_form.dart';
import 'package:sfi_equipment_tracker/widgets/create_inventory.dart';
import 'package:sfi_equipment_tracker/widgets/restock_equipment_form.dart';
import 'package:sfi_equipment_tracker/widgets/storage_locations_list_view.dart';
import '../constants.dart';
import '../widgets/nav_drawer.dart';

class ManageStorageLocations extends StatelessWidget {
  const ManageStorageLocations({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Manage Storage Locations',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: SchoolFitnessBlue,
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) => const AlertDialog(
                  content: CreateInventoryDialog(),
                ),
              );
            },
            backgroundColor: SchoolFitnessBlue,
            child: const Icon(Icons.add),
          ),
          drawer: const NavDrawer(
            currentPageId: "manage-storage-locations",
          ),
          body: const StorageLocationsListView(
            searchCriteria: "",
          )),
    );
  }
}
