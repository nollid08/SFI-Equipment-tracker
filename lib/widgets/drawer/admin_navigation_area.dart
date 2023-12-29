import 'package:flutter/material.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/screens/manage_admins.dart';
import 'package:sfi_equipment_tracker/screens/manage_stock.dart';
import 'package:sfi_equipment_tracker/screens/manage_storage_locations.dart';
import 'package:sfi_equipment_tracker/screens/reports_screen.dart';
import 'package:sfi_equipment_tracker/screens/transfer_logs_screen.dart';

class AdminNavigationArea extends StatelessWidget {
  const AdminNavigationArea({
    super.key,
    required this.currentPageId,
  });

  final String currentPageId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Account.getCurrent(
          context: context,
        ),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Account account = snapshot.data;
            if (account.type == AccountType.admin) {
              return Column(
                children: [
                  const Divider(
                    height: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Admin',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Manage Stock',
                    ),
                    selected: currentPageId == 'manage-stock',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageStock()),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Manage Storage Locations',
                    ),
                    selected: currentPageId == 'manage-storage-locations',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageStorageLocations(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Manage Admins',
                    ),
                    selected: currentPageId == 'manage-admins',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageAdmins(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Transfer Logs',
                    ),
                    selected: currentPageId == 'transfer-logs',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransferLogsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'View Reports',
                    ),
                    selected: currentPageId == 'reports-screen',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          } else if (snapshot.hasError) {
            return const Text('Error 5407');
          } else {
            return const Center(
                child: Center(
              child: SizedBox.square(
                dimension: 100,
                child: CircularProgressIndicator(),
              ),
            ));
          }
        });
  }
}
