import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/providers/equipment_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/register_gate.dart';

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
  final _formKey = GlobalKey<FormBuilderState>();
  void _onChanged(dynamic val) => debugPrint(val.toString());
  String convertToId(String input) {
    List<String> words = input.split(' ');
    String capitalized = words.map((word) => word.toUpperCase()).join('_');
    return capitalized;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
                    FormBuilderTextField(
                      name: 'equipment_name',
                      decoration: InputDecoration(
                        hintText: 'Equipment Name',
                        hintStyle: const TextStyle(fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    FormBuilderSlider(
                      name: 'equipment_quantity',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.min(1),
                      ]),
                      onChanged: _onChanged,
                      min: 0.0,
                      max: 100.0,
                      initialValue: 7.0,
                      divisions: 100,
                      activeColor: Colors.blue[900],
                      inactiveColor: Colors.blue[100],
                      decoration: const InputDecoration(
                        labelText: 'Equipment Quantity',
                      ),
                    ),
                    FormBuilderImagePicker(
                      name: 'equipment_image',
                      decoration:
                          const InputDecoration(labelText: 'Pick Photo'),
                      maxImages: 1,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    FutureBuilder(
                        future: InventoryOwnerRelationship.getAll(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<InventoryOwnerRelationship>>
                                snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return const CircularProgressIndicator();
                            case ConnectionState.waiting:
                              return const CircularProgressIndicator();
                            default:
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final List<InventoryOwnerRelationship>?
                                    invOwnRels = snapshot.data;
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
                                  );
                                } else {
                                  throw ("No Inventories Found!!!");
                                }
                              }
                          }
                        }),
                    MaterialButton(
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: submitForm,
                      child: const Text('Add Stock',
                          style: TextStyle(color: Colors.white)),
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
        final int equipmentQuantity = data["equipment_quantity"].toInt();
        final equipmentImage = data["equipment_image"][0];
        final InventoryOwnerRelationship recipientInventory = data["recipient"];

        final bool hasEquipmentRegistered = await Equipment.registerEquipment(
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
