import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:path/path.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/equipment_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/widgets/claim_equipment_form.dart';

class ClaimEquipment extends StatefulWidget {
  final InventoryItem inventoryItem;

  const ClaimEquipment(
      {super.key,
      required this.inventoryItem,
      required this.close,
      required this.inventoryOwner});

  final Function() close;
  final Account inventoryOwner;

  @override
  State<ClaimEquipment> createState() => _ClaimEquipmentState();
}

class _ClaimEquipmentState extends State<ClaimEquipment> {
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

  void _onSubmit(dynamic val) {
    setState(() {
      currentEquipmenQuantity = val.round();
    });

    _onChanged(val);
  }

  @override
  Widget build(BuildContext context) {
    final InventoryItem equipmentItem = widget.inventoryItem;
    final double equipmentCount = equipmentItem.quantity.toDouble();
    final int countMidpoint = (equipmentCount / 2).round();
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
              FormBuilderSlider(
                name: 'equipment_quantity',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.min(1),
                ]),
                onChanged: _onSliderChanged,
                min: 1,
                max: equipmentCount,
                initialValue: countMidpoint.toDouble(),
                divisions: equipmentCount.round() - 1,
                activeColor: Colors.blue[900],
                inactiveColor: Colors.blue[100],
                decoration: const InputDecoration(
                  labelText: 'Equipment Quantity',
                ),
              ),
              FormBuilderCheckbox(
                name: 'accept_terms',
                initialValue: false,
                onChanged: _onChanged,
                title: TransferConfirmationText(
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
                      MaterialStateProperty.all<Color>(SchoolFitnessBlue),
                ),
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    debugPrint(_formKey.currentState?.value.toString());
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
          TextSpan(
            text: "$inventoryOwnerFirstName's inventory ",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const TextSpan(
            text: ' to my inventory',
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
