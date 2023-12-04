import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/widgets/add_new_equipment_form.dart';
import 'package:sfi_equipment_tracker/widgets/restock_equipment_form.dart';
import '../constants.dart';
import '../widgets/nav_drawer.dart';

class ManageStock extends StatelessWidget {
  const ManageStock({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manage Stock',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
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
          centerTitle: true,
          backgroundColor: SchoolFitnessBlue,
          foregroundColor: Colors.white,
        ),
        drawer: const NavDrawer(
          currentPageId: "manage-stock",
        ),
        body: const TabBarView(
          children: [
            AddNewEquipmentForm(),
            RestockEquipmentForm(),
          ],
        ),
      ),
    );
  }
}
