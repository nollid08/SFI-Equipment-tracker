import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/widgets/adapted_scaffold.dart';
import 'package:sfi_equipment_tracker/widgets/admins_list_view.dart';

class ManageAdmins extends StatelessWidget {
  const ManageAdmins({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptedScaffold(
        title: 'Manage Admins',
        currentPageId: "manage-storage-locations",
        body: AdminsListView(
          searchCriteria: "",
        ));
  }
}
