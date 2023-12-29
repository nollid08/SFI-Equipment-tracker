// stateless widget that takes an equipment item and displays it in a card
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/models/equipment_owner_relationships.dart';
import 'package:sfi_equipment_tracker/models/global_equipment.dart';
import 'package:sfi_equipment_tracker/models/inventory.dart';
import 'package:sfi_equipment_tracker/models/inventory_owner_relationship.dart';
import 'package:sfi_equipment_tracker/screens/inventory_screen.dart';
import 'package:sfi_equipment_tracker/widgets/list_views/equipment_image.dart';

class EquipmentCard extends StatelessWidget {
  final GlobalEquipmentItem globalEquipmentItem;
  const EquipmentCard({Key? key, required this.globalEquipmentItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(0.0),
      child: SizedBox(
        width: double.infinity,
        height: 800,
        child: FutureBuilder<EquipmentOwnerRelationships>(
            future: EquipmentOwnerRelationships.get(globalEquipmentItem),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Center(
                  child: SizedBox.square(
                    dimension: 100,
                    child: CircularProgressIndicator(),
                  ),
                ));
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  final EquipmentOwnerRelationships equipOwnRels =
                      snapshot.data!;
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      HeroImage(
                        imageRef: equipOwnRels.item.imageRef,
                        child: Column(children: [
                          Text(
                            equipOwnRels.item.name,
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                          Text(
                            "Total Quantity: ${equipOwnRels.item.totalQuantity}",
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 201, 201, 201),
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const Divider();
                                },
                                itemCount: equipOwnRels.owners.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    title: Text(
                                      equipOwnRels.owners[index].account.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Quantity: ${equipOwnRels.owners[index].count}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      final Account account =
                                          equipOwnRels.owners[index].account;
                                      InventoryOwnerRelationship invOwnRel =
                                          InventoryOwnerRelationship
                                              .getFromAccount(account);

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              InventoryScreen(
                                            invOwnRel: invOwnRel,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                })
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: Text("No equipment found"),
                  );
                }
              } else {
                return const Center(
                  child: Text("No equipment found"),
                );
              }
            }),
      ),
    );
  }
}
