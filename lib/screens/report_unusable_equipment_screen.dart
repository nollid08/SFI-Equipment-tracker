
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/inventory_owner_relationship.dart';
import 'package:sfi_equipment_tracker/widgets/adapted_scaffold.dart';
import 'package:sfi_equipment_tracker/widgets/form/report_form.dart';

class ReportUnusableEquipmentScreen extends StatelessWidget {
  const ReportUnusableEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptedScaffold(
      title: 'Report Unusable Equipment',
      currentPageId: 'report_missing_equipment',
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<InventoryOwnerRelationship>>(
              future: InventoryOwnerRelationship.getAllInvOwnRels(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final List<InventoryOwnerRelationship> invOwnRels =
                      snapshot.data!;
                  return ReportForm(
                    invOwnRels: invOwnRels,
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text("Error"));
                }
              }),
        ),
      ),
    );
  }
}
