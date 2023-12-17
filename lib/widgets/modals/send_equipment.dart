import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/models/inventory.dart';
import 'package:sfi_equipment_tracker/models/inventory_owner_relationship.dart';
import 'package:sfi_equipment_tracker/widgets/form/equipment_count_chooser.dart';
import 'package:sfi_equipment_tracker/widgets/form/send_confirmation_text.dart';

class SendEquipmentDialog extends StatefulWidget {
  final InventoryItem inventoryItem;
  final List<InventoryOwnerRelationship> inventoryRefs;

  const SendEquipmentDialog({
    super.key,
    required this.inventoryItem,
    required this.inventoryRefs,
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

  void _onTransferQuantityChanged(num? val) {
    if (val == null) {
      return;
    }
    setState(() {
      currentEquipmenQuantity = val.round();
    });

    _onChanged(val);
  }

  void _onRecipientChanged(InventoryOwnerRelationship val) {
    setState(() {
      currentRecipient = val.owner.name;
    });

    _onChanged(val);
  }

  void onSubmit(InventoryItem equipmentItem) {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      debugPrint(_formKey.currentState?.value.toString());
      // Save the slider value as an int
      final int transferQuota = currentEquipmenQuantity;
      final Map data = _formKey.currentState!.value;
      final InventoryOwnerRelationship recipientInvOwnRel = data["recipient"];
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User user = auth.currentUser!;
      final uid = user.uid;
      Inventory.transferEquipmentItem(
        origineeUid: uid,
        recipientUid: recipientInvOwnRel.owner.uid,
        equipmentId: equipmentItem.id,
        transferQuota: transferQuota,
      );
      Navigator.pop(context);
    } else {
      debugPrint(_formKey.currentState?.value.toString());
      debugPrint('validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final InventoryItem equipmentItem = widget.inventoryItem;
    final int equipmentCount = equipmentItem.quantity;
    final int countMidpoint = (equipmentCount / 2).round();
    final List<InventoryOwnerRelationship> invOwnRels = widget.inventoryRefs;
    List<DropdownMenuItem<InventoryOwnerRelationship>> items = [];
    if (FirebaseAuth.instance.currentUser != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      for (final invOwnRel in invOwnRels) {
        if (invOwnRel.owner.uid != uid) {
          items.add(DropdownMenuItem(
            value: invOwnRel,
            child: Text(invOwnRel.owner.name),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Transfer ${equipmentItem.name}",
            style: const TextStyle(fontSize: 26),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Divider(),
          ),
          FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            skipDisabled: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EquipmentCountChooser(
                  onSliderChanged: _onTransferQuantityChanged,
                  equipmentCount: equipmentItem.quantity,
                  initialValue: countMidpoint,
                ),
                const Divider(),
                const SizedBox(
                  height: 4,
                ),
                FormBuilderDropdown(
                    name: "recipient",
                    items: items,
                    onChanged: (value) => _onRecipientChanged(value!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: const InputDecoration(
                      label: Text('Select Recipient'),
                      hintText: "Select Recipient",
                      border: OutlineInputBorder(),
                    )),
                FormBuilderCheckbox(
                  name: 'accept_terms',
                  initialValue: false,
                  onChanged: _onChanged,
                  title: SendConfirmationText(
                    equipmentCount: currentEquipmenQuantity,
                    equipmentItemName: equipmentItem.name,
                    inventoryOwnerFullName: currentRecipient,
                  ),
                  validator: FormBuilderValidators.equal(
                    true,
                    errorText: 'You must confirm to continue',
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(SchoolFitnessBlue),
                    ),
                    onPressed: () => onSubmit(equipmentItem),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
