import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/models/global_equipment.dart';
import 'package:sfi_equipment_tracker/screens/register_gate.dart';
import 'package:sfi_equipment_tracker/widgets/form/equipment_count_chooser.dart';

import '../../models/inventory_owner_relationship.dart';

class AddNewEquipmentForm extends StatefulWidget {
  const AddNewEquipmentForm({Key? key}) : super(key: key);

  @override
  State<AddNewEquipmentForm> createState() {
    return _AddNewEquipmentFormState();
  }
}

class _AddNewEquipmentFormState extends State<AddNewEquipmentForm> {
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  int selectedAmount = 50;
  final _formKey = GlobalKey<FormBuilderState>();
  void onSliderChanged(num? val) => selectedAmount = val!.toInt();
  String convertToId(String input) {
    List<String> words = input.split(' ');
    String capitalized = words.map((word) => word.toUpperCase()).join('_');
    return capitalized;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: <Widget>[
            FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              skipDisabled: true,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    const EquipmentNameTextBox(),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 6,
                      ),
                      child: Divider(),
                    ),
                    EquipmentCountChooser(
                      onSliderChanged: onSliderChanged,
                      equipmentCount: 200,
                      initialValue: selectedAmount,
                      customLabel: "Select amount To Be Added",
                      isBold: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      child: Divider(),
                    ),
                    FormBuilderImagePicker(
                      name: 'equipment_image',
                      decoration: const InputDecoration(
                        labelText: 'Pick Photo',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                      maxImages: 1,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 6,
                      ),
                      child: Divider(),
                    ),
                    const SelectInventoryDropdown(),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 6,
                      ),
                      child: Divider(),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      onPressed: submitForm,
                      label: const Text(
                        'Add Stock',
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      // Check to make sure user is signed in
      if (user != null) {
        final Map data = _formKey.currentState!.value;
        final String equipmentName = data["equipment_name"];
        final int equipmentQuantity = selectedAmount;
        final equipmentImage = data["equipment_image"][0];
        final InventoryOwnerRelationship recipientInventory = data["recipient"];

        final bool hasEquipmentRegistered =
            await GlobalEquipment.registerEquipment(
          inventoryRef: recipientInventory.inventoryReference,
          name: equipmentName,
          quantity: equipmentQuantity,
          image: equipmentImage,
        );
        if (hasEquipmentRegistered) {
          _formKey.currentState?.reset();
        } else {
          if (mounted) {
            return showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Uh Oh!'),
                    content: const SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('This item already exists!'),
                          Text('(Try giving it a different name)'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('I Understand'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          }
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const RegisterGate(),
          ),
        );
      }
    }
  }
}

class SelectInventoryDropdown extends StatelessWidget {
  const SelectInventoryDropdown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Inventory:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 6,
        ),
        FutureBuilder(
            future: InventoryOwnerRelationship.getAllInvOwnRels(),
            builder: (BuildContext context,
                AsyncSnapshot<List<InventoryOwnerRelationship>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const Center(
                    child: SizedBox.square(
                      dimension: 60,
                      child: CircularProgressIndicator(),
                    ),
                  );
                case ConnectionState.waiting:
                  return const Center(
                    child: SizedBox.square(
                      dimension: 60,
                      child: CircularProgressIndicator(),
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final List<InventoryOwnerRelationship>? invOwnRels =
                        snapshot.data;
                    if (invOwnRels != null) {
                      return FormBuilderDropdown(
                        name: "recipient",
                        items: invOwnRels
                            .map(
                              (invOwnRel) => DropdownMenuItem(
                                value: invOwnRel,
                                child: Text(invOwnRel.owner.name),
                              ),
                            )
                            .toList(),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        decoration: const InputDecoration(
                          labelText: 'Where is it stored?',
                          border: OutlineInputBorder(),
                        ),
                      );
                    } else {
                      throw ("No Inventories Found!!!");
                    }
                  }
              }
            }),
      ],
    );
  }
}

class EquipmentNameTextBox extends StatelessWidget {
  const EquipmentNameTextBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Equipment Name',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(
          height: 6,
        ),
        FormBuilderTextField(
          name: 'equipment_name',
          decoration: const InputDecoration(
            labelText: 'Name of new equipment?',
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
      ],
    );
  }
}
