import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/report.dart';
import 'package:sfi_equipment_tracker/widgets/adapted_scaffold.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptedScaffold(
      title: 'View Reports',
      currentPageId: 'reports-screen',
      body: FutureBuilder<List<Report>>(
          future: Report.getAll(),
          builder: (context, reportsSnapshot) {
            if (reportsSnapshot.hasData) {
              final List<Report> reports = reportsSnapshot.data!;
              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final Report report = reports[index];
                  String ownerName = report.ownerUid.name;
                  String reporterName = report.reporter.name;
                  return Column(
                    children: [
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(TextSpan(children: [
                              const TextSpan(
                                  text: "Report: ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text:
                                    "$reporterName reported that ${report.quantityUnusable} ${report.inventoryItem.name} from $ownerName's inventory were ${report.cause}",
                              ),
                            ])),
                            Text.rich(TextSpan(children: [
                              const TextSpan(
                                  text: "Explanation: ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: report.description,
                              ),
                            ])),
                          ],
                        ),
                        subtitle: Text(report.time.toString()),
                      ),
                      const Divider(),
                    ],
                  );
                },
              );
            } else if (reportsSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text("Error"));
            }
          }),
    );
  }
}
