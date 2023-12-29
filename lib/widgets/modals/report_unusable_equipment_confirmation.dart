import 'package:flutter/material.dart';

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
