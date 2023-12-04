import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/widgets/adapted_scaffold.dart';
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
    return AdaptedScaffold(
      title: 'Manage Storage Locations',
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
      body: const StorageLocationsListView(
        searchCriteria: "",
      ),
      currentPageId: "manage-storage-locations",
    );
  }
}
