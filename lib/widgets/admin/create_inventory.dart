import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/models/inventory.dart';
import 'package:sfi_equipment_tracker/providers/storage_location_provider.dart';

class CreateInventoryDialog extends StatefulWidget {
  const CreateInventoryDialog({
    super.key,
  });

  @override
  State<CreateInventoryDialog> createState() => _CreateInventoryDialogState();
}

class _CreateInventoryDialogState extends State<CreateInventoryDialog> {
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  String currentStorageLocationName = "";
  final _formKey = GlobalKey<FormBuilderState>();
  void _onChanged(dynamic val) {
    debugPrint(val.toString());
  }

  void _onNameChanged(dynamic val) {
    setState(() {
      currentStorageLocationName = val.toString();
    });

    _onChanged(val);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Create Storage Location",
          style: TextStyle(fontSize: 26),
        ),
        FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          skipDisabled: true,
          child: Column(
            children: [
              FormBuilderTextField(
                name: "storage_location_name",
                decoration: const InputDecoration(labelText: "Name"),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                onChanged: _onNameChanged,
              ),
              FormBuilderCheckbox(
                name: 'accept_terms',
                initialValue: false,
                onChanged: _onChanged,
                title: CreationConfirmationText(
                  storageLocationName: currentStorageLocationName != ''
                      ? currentStorageLocationName
                      : "(No Name Entered)",
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
                    StorageLocationManager.create(
                      currentStorageLocationName,
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

class CreationConfirmationText extends StatelessWidget {
  const CreationConfirmationText({
    super.key,
    required this.storageLocationName,
  });

  final String storageLocationName;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text:
                'I confirm that I want to create a new storage location named ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: storageLocationName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const TextSpan(
            text: '. ',
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
