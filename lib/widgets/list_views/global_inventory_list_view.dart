import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/global_equipment.dart';
import 'package:sfi_equipment_tracker/widgets/modals/equipment_card.dart';
import 'package:sfi_equipment_tracker/widgets/list_views/equipment_image.dart';

class GlobalInventoryListView extends StatefulWidget {
  final String uid;
  final String searchCriteria;

  const GlobalInventoryListView(
      {Key? key, required this.uid, required this.searchCriteria})
      : super(key: key);

  @override
  State<GlobalInventoryListView> createState() =>
      _GlobalInventoryListViewState();
}

class _GlobalInventoryListViewState extends State<GlobalInventoryListView> {
  _GlobalInventoryListViewState();

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    //Using a stream builder to get the data from the Equipment Collection in the db, retrieve all equipment and return its name, total quantity and image in a ListView
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.collection("equipment").snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            //If there is an error, return a Text widget with the error
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            //If the connection is waiting, return a circular progress indicator
            return const Center(
                child: Center(
              child: SizedBox.square(
                dimension: 100,
                child: CircularProgressIndicator(),
              ),
            ));
          }

          if (snapshot.hasData) {
            final QuerySnapshot<Map<String, dynamic>> data = snapshot.data!;
            final GlobalEquipment allEquipment =
                GlobalEquipment.getFromSnapshot(data);
            return ListView.separated(
                itemCount: allEquipment.equipmentList.length,
                itemBuilder: (BuildContext context, int index) {
                  final GlobalEquipmentItem item =
                      allEquipment.equipmentList[index];
                  return ListTile(
                    leading: EquipmentImage(imageRef: item.imageRef),
                    title: Text(item.name),
                    subtitle: Text("Total Quantity: ${item.totalQuantity}"),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return EquipmentCard(
                            globalEquipmentItem: item,
                          );
                        },
                      );
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  final GlobalEquipmentItem item =
                      allEquipment.equipmentList[index];
                  if (item.name.toLowerCase().contains(widget.searchCriteria)) {
                    return const Divider();
                  } else {
                    return const SizedBox.shrink();
                  }
                });
          } else {
            return const Center(
              child: Text("No equipment found"),
            );
          }
        });
  }
}
