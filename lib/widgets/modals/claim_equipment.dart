import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/models/inventory.dart';
import 'package:sfi_equipment_tracker/widgets/form/claim_confirmation_text.dart';
import 'package:sfi_equipment_tracker/widgets/form/equipment_count_chooser.dart';

class ClaimEquipmentDialog extends StatefulWidget {
  final InventoryItem inventoryItem;

  const ClaimEquipmentDialog(
      {super.key, required this.inventoryItem, required this.inventoryOwner});

  final Account inventoryOwner;

  @override
  State<ClaimEquipmentDialog> createState() => _ClaimEquipmentDialogState();
}

class _ClaimEquipmentDialogState extends State<ClaimEquipmentDialog> {
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  int currentEquipmenQuantity = -1;
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

  @override
  Widget build(BuildContext context) {
    final InventoryItem equipmentItem = widget.inventoryItem;
    final int equipmentCount = equipmentItem.quantity;
    final int countMidpoint = (equipmentCount / 2).round();
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
              children: [
                EquipmentCountChooser(
                  onSliderChanged: _onSliderChanged,
                  equipmentCount: equipmentCount,
                  initialValue: countMidpoint,
                ),
                FormBuilderCheckbox(
                  name: 'accept_terms',
                  initialValue: false,
                  onChanged: _onChanged,
                  title: ClaimConfirmationText(
                    equipmentCount: currentEquipmenQuantity,
                    equipmentItemName: equipmentItem.name,
                    inventoryOwnerFullName: widget.inventoryOwner.name,
                  ),
                  validator: FormBuilderValidators.equal(
                    true,
                    errorText: 'You must confirm to continue',
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(schoolFitnessBlue),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      debugPrint(_formKey.currentState?.value.toString());
                      // Save the slider value as an int
                      final int transferQuota = currentEquipmenQuantity;
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final User user = auth.currentUser!;
                      final uid = user.uid.toString();
                      Inventory.transferEquipmentItem(
                        origineeUid: widget.inventoryOwner.uid,
                        recipientUid: uid,
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
      ),
    );
  }
}
