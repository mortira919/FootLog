import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/match_dto.dart';

/// Контракт удалённого источника (только Firestore, без маппинга в Domain)
abstract class MatchesRemoteDataSource {
  Future<String> add(String uid, MatchDto dto);
  Future<void> update(String uid, MatchDto dto); // dto.id обязателен
  Future<void> delete(String uid, String matchId);
  Future<List<MatchDto>> getRecent(String uid, {int limit = 5});
}

class MatchesRemoteDataSourceImpl implements MatchesRemoteDataSource {
  final FirebaseFirestore db;
  MatchesRemoteDataSourceImpl(this.db);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      db.collection('users').doc(uid).collection('matches');

  @override
  Future<String> add(String uid, MatchDto dto) async {
    final ref = await _col(uid).add(dto.toJson());
    return ref.id;
  }

  @override
  Future<void> update(String uid, MatchDto dto) async {
    final id = dto.id;
    if (id == null) {
      throw Exception('MatchesRemoteDataSource.update: dto.id is null');
    }
    await _col(uid).doc(id).set(dto.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> delete(String uid, String matchId) {
    return _col(uid).doc(matchId).delete();
  }

  @override
  Future<List<MatchDto>> getRecent(String uid, {int limit = 5}) async {
    final snap = await _col(uid).orderBy('date', descending: true).limit(limit).get();
    return snap.docs.map((d) => MatchDto.fromJson(d.id, d.data())).toList();
  }
}
