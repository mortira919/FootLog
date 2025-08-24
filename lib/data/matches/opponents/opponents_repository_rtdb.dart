import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:footlog/domain/matches/entities/opponent.dart';
import 'package:footlog/domain/matches/repositories/opponents_repository.dart';

class OpponentsRepositoryRtdb implements IOpponentsRepository {
  final FirebaseDatabase _db;
  final FirebaseStorage _storage;
  OpponentsRepositoryRtdb(this._db, this._storage);

  DatabaseReference _col(String uid) => _db.ref('users/$uid/opponents');

  @override
  Future<List<Opponent>> getRecent(String uid, {int limit = 20}) async {
    final q = _col(uid).orderByChild('lastPlayedAt').limitToLast(limit);
    final snap = await q.get();
    if (!snap.exists) return const [];
    final list = <Opponent>[];
    for (final c in snap.children) {
      final m = Map<String, dynamic>.from(c.value as Map);
      list.add(Opponent.fromMap(c.key!, m));
    }
    // orderByChild + limitToLast -> от старых к новым; разворачиваем, чтобы новые сверху
    list.sort((a, b) => (b.lastPlayedAt ?? DateTime(0)).compareTo(a.lastPlayedAt ?? DateTime(0)));
    return list;
  }

  @override
  Future<Opponent?> getById(String uid, String id) async {
    final snap = await _col(uid).child(id).get();
    if (!snap.exists || snap.value == null) return null;
    final m = Map<String, dynamic>.from(snap.value as Map);
    return Opponent.fromMap(id, m);
  }

  @override
  Future<void> upsertFromMatch(
      String uid, {
        required String name,
        DateTime? playedAt,
        String? logoUrl,
      }) async {
    final id = Opponent.idFromName(name);
    final ref = _col(uid).child(id);
    final nowTs = (playedAt ?? DateTime.now()).millisecondsSinceEpoch;

    final snap = await ref.get();
    if (snap.exists && snap.value != null) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      final cnt = (data['matchesCount'] as num?)?.toInt() ?? 0;
      final currentLogo = data['logoUrl'] as String?;
      await ref.update({
        'name': name.trim(),
        'lastPlayedAt': nowTs,
        'matchesCount': cnt + 1,
        if (logoUrl != null && (currentLogo == null || currentLogo.isEmpty)) 'logoUrl': logoUrl,
        'name_lc': name.toLowerCase(),
      });
    } else {
      await ref.set({
        'name': name.trim(),
        'logoUrl': logoUrl,
        'lastPlayedAt': nowTs,
        'matchesCount': 1,
        'name_lc': name.toLowerCase(),
      });
    }
  }

  @override
  Future<String> uploadLogo(
      String uid, {
        required String opponentId,
        required List<int> bytes,
        String contentType = 'image/jpeg',
      }) async {
    final path = 'users/$uid/opponents/$opponentId/logo.jpg';
    final ref = _storage.ref(path);
    await ref.putData(Uint8List.fromList(bytes), SettableMetadata(contentType: contentType));
    return await ref.getDownloadURL();
  }
}
