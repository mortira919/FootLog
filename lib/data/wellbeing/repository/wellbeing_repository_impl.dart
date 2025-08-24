import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footlog/domain/wellbeing/entities/wellbeing_entry.dart';
import 'package:footlog/domain/wellbeing/repositories/wellbeing_repository.dart';

class WellbeingRepositoryImpl implements WellbeingRepository {
  final FirebaseFirestore db;
  WellbeingRepositoryImpl(this.db);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      db.collection('users').doc(uid).collection('wellbeing');

  @override
  Future<WellbeingEntry?> loadEntry({
    required String uid,
    required DateTime date,
  }) async {
    final id = WellbeingEntry.docId(date);
    final snap = await _col(uid).doc(id).get();
    if (!snap.exists) return null;
    return WellbeingEntry.fromJson(snap.data()!);
  }

  @override
  Future<void> saveEntry({
    required String uid,
    required WellbeingEntry entry,
  }) async {
    final id = WellbeingEntry.docId(entry.date);
    await _col(uid).doc(id).set(entry.toJson(), SetOptions(merge: true));
  }
}
