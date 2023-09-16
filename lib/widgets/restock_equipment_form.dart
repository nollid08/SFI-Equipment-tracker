import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/providers/account_provider.dart';
import 'package:sfi_equipment_tracker/providers/equipment_provider.dart';
import 'package:sfi_equipment_tracker/providers/inventory_provider.dart';
import 'package:sfi_equipment_tracker/screens/register_gate.dart';

class RestockEquipmentForm extends StatefulWidget {
  const RestockEquipmentForm({Key? key}) : super(key: key);

  @override
  State<RestockEquipmentForm> createState() {
    return _RestockEquipmentFormState();
  }
}

class _RestockEquipmentFormState extends State<RestockEquipmentForm> {
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  final _formKey = GlobalKey<FormBuilderState>();
  void _onChanged(dynamic val) => debugPrint(val.toString());

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
                    FutureBuilder(
                        future: Equipment.get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<Equipment> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return const CircularProgressIndicator();
                            case ConnectionState.waiting:
                              return const CircularProgressIndicator();
                            default:
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final List<EquipmentItem>? inventoryRefs =
                                    snapshot.data?.equipmentList;
                                if (inventoryRefs != null) {
                                  return FormBuilderDropdown(
                                    name: "equipment",
                                    items: inventoryRefs
                                        .map(
                                          (inventoryRefs) => DropdownMenuItem(
                                            child: Text(inventoryRefs.name),
                                            value: inventoryRefs,
                                          ),
                                        )
                                        .toList(),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                    ]),
                                  );
                                } else {
                                  return const Text("No Equipment Found!!!");
                                }
                              }
                          }
                        }),
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
                    FutureBuilder(
                        future: Inventory.getAllInventoryRefs(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<InventoryReference>> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return const CircularProgressIndicator();
                            case ConnectionState.waiting:
                              return const CircularProgressIndicator();
                            default:
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final List<InventoryReference>? inventoryRefs =
                                    snapshot.data;
                                if (inventoryRefs != null) {
                                  return FormBuilderDropdown(
                                    name: "recipient",
                                    items: inventoryRefs
                                        .map(
                                          (inventoryRefs) => DropdownMenuItem(
                                            child: Text(inventoryRefs.name),
                                            value: inventoryRefs,
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
        final EquipmentItem equipment = data["equipment"];
        final int equipmentQuantity = data["equipment_quantity"].toInt();
        final InventoryReference recipientInventory = data["recipient"];
        print("fdfg");
        //Update the equipment quantity on cloud firestore using function from equipment provider
        Equipment.updateEquipmentQuantity(
            equipmentId: equipment.id,
            quantity: equipmentQuantity,
            inventoryRef: recipientInventory.inventoryReference);
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
