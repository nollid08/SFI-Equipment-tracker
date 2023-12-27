import 'package:cloud_firestore/cloud_firestore.dart';

class Logs {
  static Future<List<Log>> getAll() async {
    final List<Log> logs = [];
    final db = FirebaseFirestore.instance;
    final logsRef = db.collection("logs").orderBy("time", descending: true);
    //get all Documents in the inventory

    final QuerySnapshot logsSnapshot = await logsRef.get();
    // Loop over each item in inventory
    for (final log in logsSnapshot.docs) {
      final Map<String, dynamic> logData = log.data() as Map<String, dynamic>;

      final Timestamp timeStamp = logData["time"];
      final DateTime time = timeStamp.toDate();
      final String recipientUid = logData["recipientUid"];
      final String origineeUid = logData["origineeUid"];
      final String equipmentId = logData["equipmentId"];
      final int quantityTransferred = logData["quantityTransferred"];

      logs.add(
        Log(
          time: time,
          recipientUid: recipientUid,
          origineeUid: origineeUid,
          equipmentId: equipmentId,
          quantityTransferred: quantityTransferred,
        ),
      );
    }

    return logs;
  }

  static Future<void> submit(Log log) async {
    final db = FirebaseFirestore.instance;
    final logRef = db.collection("logs").doc();
    await logRef.set({
      "time": log.time,
      "recipientUid": log.recipientUid,
      "origineeUid": log.origineeUid,
      "equipmentId": log.equipmentId,
      "quantityTransferred": log.quantityTransferred,
    });
  }
}

class Log {
  final DateTime? time;
  final String recipientUid;
  final String origineeUid;
  final String equipmentId;
  final int quantityTransferred;

  Log({
    required this.recipientUid,
    required this.origineeUid,
    required this.equipmentId,
    required this.quantityTransferred,
    required this.time,
  });
}
