import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/providers/equipment_provider.dart';

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
                    decoration: const InputDecoration(labelText: 'Pick Photo'),
                    maxImages: 1,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
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
    );
  }

  void submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final Map data = _formKey.currentState!.value;
      final String equipmentName = data["equipment_name"];
      final int equipmentQuantity = data["equipment_quantity"].toInt();
      final equipmentImage = data["equipment_image"][0];

      addNewEquipment(
        name: equipmentName,
        quantity: equipmentQuantity,
        image: equipmentImage,
      );
    }
  }
}
