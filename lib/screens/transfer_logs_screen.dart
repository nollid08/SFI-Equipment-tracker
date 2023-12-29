import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/models/inventory_owner_relationship.dart';
import 'package:sfi_equipment_tracker/models/logs.dart';
import 'package:sfi_equipment_tracker/widgets/adapted_scaffold.dart';
import 'package:sfi_equipment_tracker/widgets/form/report_form.dart';

class TransferLogsScreen extends StatelessWidget {
  const TransferLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptedScaffold(
      title: 'Transfer Logs',
      currentPageId: 'transfer-logs',
      body: FutureBuilder<List<Account>>(
          future: Account.getAll(),
          builder: (context, accountsSnapshot) {
            if (accountsSnapshot.hasData) {
              final List<Account> accounts = accountsSnapshot.data!;
              return FutureBuilder<List<Log>>(
                future: Logs.getAll(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Log>> logsSnapshot) {
                  if (logsSnapshot.hasData) {
                    final List<Log> logs = logsSnapshot.data!;
                    return ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final Log log = logs[index];
                        String recipientName = log.recipientUid;
                        String origineeName = log.origineeUid;
                        accounts.forEach((account) {
                          if (log.recipientUid == account.uid) {
                            recipientName = account.name;
                          }
                          if (log.origineeUid == account.uid) {
                            origineeName = account.name;
                          }
                        });
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                  "${log.quantityTransferred} ${log.equipmentId}'s transferred from $origineeName to $recipientName"),
                              subtitle: Text(log.time.toString()),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    );
                  } else if (logsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(child: Text("Error"));
                  }
                },
              );
            } else if (accountsSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text("Error"));
            }
          }),
    );
  }
}
