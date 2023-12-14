// stateless widget that takes an equipment item and displays it in a card
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/providers/equipment_provider.dart';

class EquipmentCard extends StatelessWidget {
  final String equipmentId;
  const EquipmentCard({Key? key, required this.equipmentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Future<GlobalEquipmentOwnerRelationships> equipmentuserRelationships =
        GlobalEquipmentOwnerRelationships.get(equipmentId);
    return Card(
      child: SizedBox(
        width: double.infinity,
        height: 400,
        child: FutureBuilder<Object>(
            future: equipmentuserRelationships,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final GlobalEquipmentOwnerRelationships
                    equipmentUserRelationships =
                    snapshot.data as GlobalEquipmentOwnerRelationships;
                final GlobalEquipmentItem equipment =
                    equipmentUserRelationships.equipmentItem;
                final Future<String> downloadUrlFuture = FirebaseStorage
                    .instance
                    .ref()
                    .child(equipment.imageRef)
                    .getDownloadURL();
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FutureBuilder(
                        future: downloadUrlFuture,
                        builder:
                            (BuildContext context, AsyncSnapshot imageUrl) {
                          if (imageUrl.hasData) {
                            return SizedBox(
                              height: 100,
                              width: double.infinity,
                              child: Image.network(
                                imageUrl.data,
                                fit: BoxFit.cover,
                                height: 100,
                              ),
                            );
                          } else {
                            return const Center(
                              child: SizedBox.square(
                                dimension: 100,
                                child: CircularProgressIndicator(),
                              ),
                            );
                            ;
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            equipment.name,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            "Total Quantity: ${equipment.totalQuantity}",
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ListView.separated(
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider();
                              },
                              itemCount: equipmentUserRelationships
                                  .relationships.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(
                                    equipmentUserRelationships
                                        .relationships[index].userName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Quantity: ${equipmentUserRelationships.relationships[index].equipmentCount}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const Center(
                  child: SizedBox.square(
                    dimension: 40,
                    child: Center(
                      child: SizedBox.square(
                        dimension: 100,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }
}
