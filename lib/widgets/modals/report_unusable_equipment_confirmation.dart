import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sfi_equipment_tracker/constants.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/models/inventory.dart';
import 'package:sfi_equipment_tracker/widgets/form/claim_confirmation_text.dart';
import 'package:sfi_equipment_tracker/widgets/form/equipment_count_chooser.dart';

class ConfirmReportDialog extends StatelessWidget {
  const ConfirmReportDialog({
    super.key,
    required this.onSubmit,
    required this.confirmationText,
  });

  final Function onSubmit;
  final String confirmationText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(confirmationText),
            ElevatedButton(
              onPressed: () async {
                await onSubmit();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
