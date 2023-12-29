import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/models/global_equipment.dart';
import 'package:sfi_equipment_tracker/models/inventory_owner_relationship.dart';

class EquipmentOwnerRelationships {
  final List<Owner> owners;
  final GlobalEquipmentItem item;

  EquipmentOwnerRelationships({required this.owners, required this.item});

  static Future<EquipmentOwnerRelationships> get(
      GlobalEquipmentItem item) async {
    final List<InventoryOwnerRelationship> invOwnRels =
        await InventoryOwnerRelationship.getAllInvOwnRels();
    final List<Owner> allOwners = await generateOwnersList(invOwnRels, item);
    final EquipmentOwnerRelationships equipOwnRels =
        EquipmentOwnerRelationships(owners: allOwners, item: item);
    return equipOwnRels;
  }

  static Future<List<Owner>> generateOwnersList(
    List<InventoryOwnerRelationship> invOwnRels,
    GlobalEquipmentItem item,
  ) async {
    final List<Owner> allOwners = [];
    for (InventoryOwnerRelationship invOwnRel in invOwnRels) {
      final CollectionReference<Map<String, dynamic>> inventoryReference =
          invOwnRel.inventoryReference;
      final QuerySnapshot<Map<String, dynamic>> inventorySnapshot =
          await inventoryReference.get();
      for (var inventoryItem in inventorySnapshot.docs) {
        final Map<String, dynamic> baseItemData = inventoryItem.data();
        final String id = inventoryItem.id;
        final Owner owner = Owner(
          account: invOwnRel.owner,
          count: baseItemData["quantity"],
        );
        if (id == item.id) {
          allOwners.add(owner);
        } else {}
      }
    }
    return allOwners;
  }

  static Future<List<EquipmentOwnerRelationships>> getAll() {
    final List<EquipmentOwnerRelationships> allEquipOwnRels = [];
    return GlobalEquipment.get().then((GlobalEquipment globalEquipment) async {
      final List<GlobalEquipmentItem> allEquipment =
          globalEquipment.equipmentList;
      for (final GlobalEquipmentItem item in allEquipment) {
        final EquipmentOwnerRelationships equipOwnRels =
            await EquipmentOwnerRelationships.get(item);
        allEquipOwnRels.add(equipOwnRels);
      }
      return allEquipOwnRels;
    });
  }
}

class Owner {
  final Account account;
  final int count;

  Owner({required this.account, required this.count});
}
