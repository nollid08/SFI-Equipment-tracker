import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/storage_location_manager.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';

import '../../models/inventory_owner_relationship.dart';

class StorageLocationsListView extends StatefulWidget {
  final String searchCriteria;

  const StorageLocationsListView({Key? key, required this.searchCriteria})
      : super(key: key);

  @override
  State<StorageLocationsListView> createState() =>
      _StorageLocationsListViewState();
}

class _StorageLocationsListViewState extends State<StorageLocationsListView> {
  _StorageLocationsListViewState();

  @override
  Widget build(BuildContext context) {
    //Using a stream builder to get the data from the Equipment Collection in the db, retrieve all equipment and return its name, total quantity and image in a ListView
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('storageLocations')
          .orderBy('name')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          //If there is an error, return a Text widget with the error
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox.square(
              dimension: 100,
              child: CircularProgressIndicator(),
            ),
          );
        }
        void delete(String id) async {
          bool documentDeleted = await StorageLocationManager.delete(id);
          if (documentDeleted) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Storage Location deleted'),
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Storage Location not deleted. Please empty the inventory first.'),
                ),
              );
            }
          }
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            final Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final String name = data['name'];
            final String uid = document.id;
            if (name.toLowerCase().contains(widget.searchCriteria)) {
              return Column(
                children: [
                  ListTile(
                    title: Text(name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final InventoryOwnerRelationship invOwnRel =
                                await InventoryOwnerRelationship.get(uid);
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InventoryScreen(
                                    invOwnRel: invOwnRel,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_browser_outlined),
                          label: const Text('View'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => delete(document.id),
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
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
