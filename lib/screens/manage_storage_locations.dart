import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/widgets/adapted_scaffold.dart';
import 'package:sfi_equipment_tracker/widgets/admin/create_inventory.dart';
import 'package:sfi_equipment_tracker/widgets/list_views/storage_locations_list_view.dart';
import '../constants.dart';

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
        backgroundColor: schoolFitnessBlue,
        child: const Icon(Icons.add),
      ),
      body: const StorageLocationsListView(
        searchCriteria: "",
      ),
      currentPageId: "manage-storage-locations",
    );
  }
}
