import 'package:cloud_firestore/cloud_firestore.dart';

extension FirestoreDocumentExtension on DocumentReference {
  Future<DocumentSnapshot> getSavy() async {
    try {
      DocumentSnapshot? ds = await get(const GetOptions(source: Source.cache));
      print(ds);
      if (ds == null) return get(const GetOptions(source: Source.server));
      return ds;
    } catch (_) {
      return get(const GetOptions(source: Source.server));
    }
  }
}

// https://github.com/furkansarihan/firestore_collection/blob/master/lib/firestore_query.dart
extension FirestoreQueryExtension on Query {
  Future<QuerySnapshot> getSavy() async {
    try {
      QuerySnapshot qs = await this.get(GetOptions(source: Source.cache));
      if (qs.docs.isEmpty) return this.get(GetOptions(source: Source.server));
      return qs;
    } catch (_) {
      return this.get(GetOptions(source: Source.server));
    }
  }
}
