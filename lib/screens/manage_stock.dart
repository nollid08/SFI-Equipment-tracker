import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/widgets/adapted_scaffold.dart';
import 'package:sfi_equipment_tracker/widgets/admin/add_new_equipment_form.dart';
import 'package:sfi_equipment_tracker/widgets/admin/restock_equipment_form.dart';

class ManageStock extends StatelessWidget {
  const ManageStock({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: AdaptedScaffold(
        title: "Manage Stock",
        bottom: TabBar(
          tabs: [
            Tab(
              text: 'New Equipment',
              icon: Icon(Icons.add_circle_outline),
            ),
            Tab(
              text: 'Restock equipment',
              icon: Icon(Icons.restore),
            ),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
        ),
        currentPageId: "manage-stock",
        body: TabBarView(
          children: [
            AddNewEquipmentForm(),
            RestockEquipmentForm(),
          ],
        ),
      ),
    );
  }
}
