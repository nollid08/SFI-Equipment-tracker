import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/models/inventory.dart';
import 'package:sfi_equipment_tracker/models/inventory_owner_relationship.dart';
import 'package:sfi_equipment_tracker/widgets/form/equipment_count_chooser.dart';
import 'package:sfi_equipment_tracker/widgets/modals/report_unusable_equipment_confirmation.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({
    super.key,
    required this.invOwnRels,
  });

  final List<InventoryOwnerRelationship> invOwnRels;

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  InventoryOwnerRelationship? selectedInvOwnRel;
  Inventory? selectedInventory;
  InventoryItem? inventoryItem;
  int? equipmentCount;
  final _formKey = GlobalKey<FormBuilderState>();

  void setSelectedInventory(
      InventoryOwnerRelationship selectedInvOwnRel) async {
    final Inventory inventory =
        await Inventory.getFromInvOwnRel(selectedInvOwnRel);
    setState(() {
      selectedInventory = inventory;
      inventoryItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'A report should only be filed when equipment is missing or damaged beyond the point of use. Once a report is filed, the equipment is removed from the system and a record is made',
              textAlign: TextAlign.justify,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            const CauseChip(),
            const IncidentDescriptionTextBox(),
            const SizedBox(height: 16),
            SourceInventoryDropdown(
              invOwnRels: widget.invOwnRels,
              onChanged: (InventoryOwnerRelationship? newSelectedInvOwnRel) => {
                if (newSelectedInvOwnRel != null)
                  {
                    setState(() {
                      selectedInvOwnRel = newSelectedInvOwnRel;
                      setSelectedInventory(selectedInvOwnRel!);
                    })
                  }
              },
            ),
            Builder(builder: (BuildContext context) {
              if (selectedInventory != null) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    EquipmentDropdown(
                      inventory: selectedInventory!,
                      onChanged: (newInventoryItem) => {
                        if (newInventoryItem != null)
                          {
                            setState(() {
                              inventoryItem = newInventoryItem;
                              print(inventoryItem!.name);
                            })
                          }
                      },
                    ),
                    Builder(
                      builder: (context) {
                        if (inventoryItem != null) {
                          int itemAmount = inventoryItem!.quantity;
                          int initialAmount = (itemAmount / 2).round();

                          equipmentCount = initialAmount;

                          return Column(
                            children: [
                              const SizedBox(height: 16),
                              EquipmentCountChooser(
                                onSliderChanged: (num? amount) =>
                                    {equipmentCount = amount!.toInt()},
                                initialValue: initialAmount,
                                equipmentCount: inventoryItem!.quantity,
                                isBold: true,
                                customLabel:
                                    'How many items are Missing/Damaged?',
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add),
                                onPressed: onSubmit,
                                label: const Text('Submit'),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox(height: 0);
                        }
                      },
                    ),
                  ],
                );
              } else {
                return const SizedBox(height: 0);
              }
            })
          ],
        ),
      ),
    );
  }

  void onSubmit() async {
    if (_formKey.currentState?.saveAndValidate(
          autoScrollWhenFocusOnInvalid: true,
        ) ??
        false) {
      // _formKey.currentState.
      if (equipmentCount != null) {
        final FirebaseAuth auth = FirebaseAuth.instance;
        final User user = auth.currentUser!;
        final uid = user.uid;
        final String description =
            _formKey.currentState!.fields['description']!.value.toString();
        final String cause =
            _formKey.currentState!.fields['toggleSwitch']!.value.toString();
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: ConfirmReportDialog(
              confirmationText:
                  'Are you sure you want to report that $equipmentCount ${inventoryItem!.name}(s) are $cause? If so, a log will be made and they will be removed from the system. This action cannot be undone. Are you sure you want to confirm?',
              onSubmit: () async {
                await Inventory.reportEquipmentItem(
                  inventoryItem: inventoryItem!,
                  quantityUnusable: equipmentCount!,
                  invOwnRel: selectedInvOwnRel!,
                  reporterUid: uid,
                  description: description,
                  cause: cause,
                );
              },
            ),
          ),
        );
        //clear the form, reset all state
        setState(() {
          _formKey.currentState!.reset();
          selectedInvOwnRel = null;
          selectedInventory = null;
          inventoryItem = null;
          equipmentCount = null;
        });
      } else {
        debugPrint('validation failed');
      }
    } else {
      debugPrint(_formKey.currentState?.value.toString());
      debugPrint('validation failed');
    }
  }
}

class IncidentDescriptionTextBox extends StatelessWidget {
  const IncidentDescriptionTextBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Describe The Incident:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        FormBuilderTextField(
          name: 'description',
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'What occured?',
          ),
          validator: FormBuilderValidators.required(),
          maxLines: 3,
        ),
      ],
    );
  }
}

class SourceInventoryDropdown extends StatelessWidget {
  const SourceInventoryDropdown({
    super.key,
    required this.invOwnRels,
    required this.onChanged,
  });
  final List<InventoryOwnerRelationship> invOwnRels;
  final void Function(InventoryOwnerRelationship? sourceInventory) onChanged;
  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<InventoryOwnerRelationship>> dropdownItems = [];
    invOwnRels.forEach((InventoryOwnerRelationship invOwnRel) {
      dropdownItems.add(DropdownMenuItem<InventoryOwnerRelationship>(
        value: invOwnRel,
        child: Text(invOwnRel.owner.name),
      ));
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text('Source Inventory:',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        FormBuilderDropdown<InventoryOwnerRelationship>(
          name: 'source-inventory-dropdown',
          onChanged: (value) => onChanged(value),
          decoration: const InputDecoration(
            label: Text('What Inventory was the equipment from?'),
            hintText: "What Inventory was the equipment from?",
            border: OutlineInputBorder(),
          ),
          items: dropdownItems,
        ),
      ],
    );
  }
}

class EquipmentDropdown extends StatelessWidget {
  const EquipmentDropdown({
    super.key,
    required this.inventory,
    required this.onChanged,
  });
  final Inventory inventory;
  final void Function(InventoryItem? inventoryItem) onChanged;
  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<InventoryItem>> dropdownItems = [];
    for (InventoryItem inventoryItem in inventory.inventory) {
      dropdownItems.add(DropdownMenuItem<InventoryItem>(
        value: inventoryItem,
        child: Text('${inventoryItem.name} (Q: ${inventoryItem.quantity} )'),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text('Equipment Type:',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        FormBuilderDropdown(
          name: 'equipment-dropdown',
          decoration: const InputDecoration(
            label: Text('What equipment is gone?'),
            hintText: "What equipment is gone?",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => onChanged(value),
          items: dropdownItems,
        ),
      ],
    );
  }
}

class CauseChip extends StatelessWidget {
  const CauseChip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('The Equipment Is:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        FormBuilderChoiceChip(
          name: 'toggleSwitch',
          initialValue: false,
          alignment: WrapAlignment.spaceEvenly,
          decoration: const InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          validator: FormBuilderValidators.required(),
          options: const [
            FormBuilderChipOption(
              value: 'missing',
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child:
                    SizedBox(width: 100, child: Center(child: Text('Missing'))),
              ),
            ),
            FormBuilderChipOption(
              value: 'damaged',
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child:
                    SizedBox(width: 100, child: Center(child: Text('Damaged'))),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
