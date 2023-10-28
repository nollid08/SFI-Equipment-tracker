import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';

class SendEquipmentDialog extends StatefulWidget {
  final InventoryItem inventoryItem;
  final List<InventoryReference> inventoryRefs;

  const SendEquipmentDialog({
    super.key,
    required this.inventoryItem,
    required List<InventoryReference> this.inventoryRefs,
  });

  @override
  State<SendEquipmentDialog> createState() => _SendEquipmentDialogState();
}

class _SendEquipmentDialogState extends State<SendEquipmentDialog> {
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  int currentEquipmenQuantity = -1;
  String currentRecipient = "(No-Recipient-Selected)";
  final _formKey = GlobalKey<FormBuilderState>();
  void _onChanged(dynamic val) {
    debugPrint(val.toString());
  }

  void _onSliderChanged(dynamic val) {
    setState(() {
      currentEquipmenQuantity = val.round();
    });

    _onChanged(val);
  }

  void _onRecipientChanged(dynamic val) {
    setState(() {
      currentRecipient = val.name;
    });

    _onChanged(val);
  }

  @override
  Widget build(BuildContext context) {
    final InventoryItem equipmentItem = widget.inventoryItem;
    final double equipmentCount = equipmentItem.quantity.toDouble();
    final int countMidpoint = (equipmentCount / 2).round();
    final List<InventoryReference> inventoryRefs = widget.inventoryRefs;
    List<DropdownMenuItem<InventoryReference>> items = [];
    if (FirebaseAuth.instance.currentUser != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      for (final element in inventoryRefs) {
        if (element.uid != uid) {
          items.add(DropdownMenuItem(
            value: element,
            child: Text(element.name),
          ));
        }
      }
    } else {
      throw ("No User Logged In!!!");
    }

    setState(() {
      if (currentEquipmenQuantity == -1) {
        currentEquipmenQuantity = countMidpoint;
      }
    });
    return Column(
      children: [
        Text(
          "Transfer ${equipmentItem.name}",
          style: const TextStyle(fontSize: 26),
        ),
        FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          skipDisabled: true,
          child: Column(
            children: [
              EquipmentCountSlider(
                onSliderChanged: _onSliderChanged,
                equipmentCount: equipmentCount,
                countMidpoint: countMidpoint,
              ),
              FormBuilderDropdown(
                name: "recipient",
                items: items,
                onChanged: (value) => _onRecipientChanged(value),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              FormBuilderCheckbox(
                name: 'accept_terms',
                initialValue: false,
                onChanged: _onChanged,
                title: TransferConfirmationText(
                  equipmentCount: currentEquipmenQuantity,
                  equipmentItemName: equipmentItem.name,
                  inventoryOwnerFullName: currentRecipient,
                ),
                validator: FormBuilderValidators.equal(
                  true,
                  errorText: 'You must confirm to continue',
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(SchoolFitnessBlue),
                ),
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    debugPrint(_formKey.currentState?.value.toString());
                    // Save the slider value as an int
                    final int transferQuota = currentEquipmenQuantity;
                    final Map data = _formKey.currentState!.value;
                    final InventoryReference recipientInventory =
                        data["recipient"];
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final User user = auth.currentUser!;
                    final uid = user.uid.toString();
                    Inventory.transferEquipmentItem(
                      origineeUid: uid,
                      recipientUid: recipientInventory.uid,
                      equipmentId: equipmentItem.id,
                      transferQuota: transferQuota,
                    );
                    Navigator.pop(context);
                  } else {
                    debugPrint(_formKey.currentState?.value.toString());
                    debugPrint('validation failed');
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class TransferConfirmationText extends StatelessWidget {
  const TransferConfirmationText({
    super.key,
    required this.equipmentCount,
    required this.equipmentItemName,
    required this.inventoryOwnerFullName,
  });

  final int equipmentCount;
  final String equipmentItemName;
  final String inventoryOwnerFullName;

  @override
  Widget build(BuildContext context) {
    final String inventoryOwnerFirstName = inventoryOwnerFullName.split(" ")[0];
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'I confirm that I want to transfer ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: '${equipmentCount.toString()} $equipmentItemName ',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const TextSpan(
            text: 'from ',
            style: TextStyle(color: Colors.black),
          ),
          const TextSpan(
            text: "my inventory",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          TextSpan(
            text: " to $inventoryOwnerFirstName's inventory",
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class EquipmentCountSlider extends StatelessWidget {
  const EquipmentCountSlider({
    super.key,
    required this.onSliderChanged,
    required this.equipmentCount,
    required this.countMidpoint,
  });
  final void Function(double?) onSliderChanged;
  final double equipmentCount;
  final int countMidpoint;

  @override
  Widget build(BuildContext context) {
    if (equipmentCount == 1) {
      return const Text("1 Item To be transferred");
    }
    return FormBuilderSlider(
      name: 'equipment_quantity',
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.min(1),
      ]),
      onChanged: onSliderChanged,
      min: 1,
      max: equipmentCount,
      initialValue: countMidpoint.toDouble(),
      divisions: equipmentCount.round() - 1,
      activeColor: Colors.blue[900],
      inactiveColor: Colors.blue[100],
      decoration: const InputDecoration(
        labelText: 'Equipment Quantity',
      ),
    );
  }
}
