// lib/data/matches/opponents/opponents_repository_rtdb.dart
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:footlog/domain/matches/entities/opponent.dart';
import 'package:footlog/domain/matches/repositories/opponents_repository.dart';

class OpponentsRepositoryRtdb implements IOpponentsRepository {
  final FirebaseDatabase db;
  final FirebaseStorage storage;
  OpponentsRepositoryRtdb(this.db, this.storage);

  DatabaseReference _opRef(String uid, String opponentId) =>
      db.ref('users/$uid/opponents/$opponentId');

  @override
  Future<List<Opponent>> getRecent(String uid, {int limit = 20}) async {

    final snap = await db.ref('users/$uid/opponents')
        .orderByChild('lastPlayedAt')
        .limitToLast(limit)
        .get();

    if (!snap.exists) return [];

    final list = <Opponent>[];
    for (final c in snap.children) {
      final data = (c.value as Map).cast<String, dynamic>();
      list.add(Opponent.fromMap(c.key!, data));
    }


    list.sort((a, b) => (b.lastPlayedAt ?? DateTime(0))
        .compareTo(a.lastPlayedAt ?? DateTime(0)));
    return list;
  }

  @override
  Future<Opponent?> getById(String uid, String id) async {
    final s = await _opRef(uid, id).get();
    if (!s.exists) return null;
    final m = (s.value as Map).cast<String, dynamic>();
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
    final ref = _opRef(uid, id);
    final now = playedAt ?? DateTime.now();


    final snap = await ref.get();
    int current = 0;
    if (snap.exists) {
      final m = (snap.value as Map).cast<String, dynamic>();
      current = (m['matchesCount'] as num?)?.toInt() ?? 0;
    }

    await ref.update({
      'name': name.trim(),
      'name_lc': name.trim().toLowerCase(),
      'lastPlayedAt': now.millisecondsSinceEpoch,
      'matchesCount': current + 1,
      if (logoUrl != null && logoUrl.isNotEmpty) 'logoUrl': logoUrl,
    });
  }

  @override
  Future<String> uploadLogo(
      String uid, {
        required String opponentId,
        required List<int> bytes,
        String contentType = 'image/jpeg',
      }) async {

    final isPng = contentType.toLowerCase().contains('png');
    final ext = isPng ? 'png' : 'jpg';

    final ref = storage.ref('users/$uid/opponents/$opponentId/logo.$ext');

    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: contentType),
    );

    final url = await ref.getDownloadURL();


    await _opRef(uid, opponentId).update({'logoUrl': url});

    return url;
  }
}
