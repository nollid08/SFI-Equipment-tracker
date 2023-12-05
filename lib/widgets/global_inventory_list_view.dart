import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/widgets/equipment_card.dart';
import 'package:sfi_equipment_tracker/widgets/equipment_image.dart';

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
    //Using a stream builder to get the data from the Equipment Collection in the db, retrieve all equipment and return its name, total quantity and image in a ListView
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('equipment')
          .orderBy('name')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            final Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final String equipmentId = document.id;
            final String name = data['name'];
            final int quantity = data['totalQuantity'];
            final String imageRef = data['imageRef'];
            if (name.toLowerCase().contains(widget.searchCriteria)) {
              return ListTile(
                leading: EquipmentImage(imageRef: imageRef),
                title: Text(name),
                subtitle: Text('Total Quantity: $quantity'),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return EquipmentCard(
                        equipmentId: equipmentId,
                      );
                    },
                  );
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          }).toList(),
        );
      },
    );
  }
}
