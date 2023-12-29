import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sfi_equipment_tracker/models/account.dart';
import 'package:sfi_equipment_tracker/models/global_equipment.dart';

class Report {
  final String id;
  final GlobalEquipmentItem inventoryItem;
  final int quantityUnusable;
  final Account ownerUid;
  final Account reporter;
  final DateTime time;
  final String cause;
  final String description;

  Report(
      {required this.id,
      required this.inventoryItem,
      required this.quantityUnusable,
      required this.ownerUid,
      required this.reporter,
      required this.time,
      required this.cause,
      required this.description});

  static Future<List<Report>> getAll() async {
    final List<Report> reports = [];

    final FirebaseFirestore db = FirebaseFirestore.instance;
    final QuerySnapshot<Map<String, dynamic>> reportsSnapshot =
        await db.collection("reports").orderBy("time", descending: true).get();
    final reportDocs = reportsSnapshot.docs;
    for (final reportDocument in reportDocs) {
      final Map<String, dynamic> data = reportDocument.data();
      final String id = reportDocument.id;
      final String inventoryItemId = data["item"];
      final int quantityUnusable = data["quantityUnusable"];
      final String ownerUid = data["ownerUid"];
      final String reporterUid = data["reporterUid"];
      final Timestamp timeStamp = data["time"];
      final DateTime time = timeStamp.toDate();
      final String cause = data["cause"];
      final String description = data["description"];

      final Account owner = await Account.get(ownerUid);
      final Account reporter = await Account.get(reporterUid);

      final GlobalEquipmentItem inventoryItem =
          await GlobalEquipmentItem.get(inventoryItemId);
      final Report report = Report(
        id: id,
        inventoryItem: inventoryItem,
        quantityUnusable: quantityUnusable,
        ownerUid: owner,
        reporter: reporter,
        time: time,
        cause: cause,
        description: description,
      );
      reports.add(report);
    }
    return reports;
  }
}
