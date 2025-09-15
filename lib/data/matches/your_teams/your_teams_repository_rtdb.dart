import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:footlog/domain/matches/entities/your_team.dart';
import 'package:footlog/domain/matches/repositories/your_teams_repository.dart';

class YourTeamsRepositoryRtdb implements IYourTeamsRepository {
  final FirebaseDatabase rtdb;
  final FirebaseStorage storage;

  YourTeamsRepositoryRtdb(this.rtdb, this.storage);

  DatabaseReference _root(String uid) => rtdb.ref('users/$uid/your_teams');

  @override
  Future<List<YourTeam>> getRecent(String uid, {int limit = 20}) async {
    final snap = await _root(uid)
        .orderByChild('lastPlayedAt')
        .limitToLast(limit)
        .get();

    final list = <YourTeam>[];
    if (snap.value is Map) {
      final m = (snap.value as Map).cast<String, dynamic>();
      m.forEach((id, v) {
        if (v is Map) {
          list.add(YourTeam.fromMap(id, v.cast<String, dynamic>()));
        }
      });
      list.sort((a, b) {
        final at = a.lastPlayedAt?.millisecondsSinceEpoch ?? 0;
        final bt = b.lastPlayedAt?.millisecondsSinceEpoch ?? 0;
        return bt.compareTo(at);
      });
    }
    return list;
  }

  @override
  Future<YourTeam?> getById(String uid, String id) async {
    final s = await _root(uid).child(id).get();
    if (!s.exists || s.value is! Map) return null;
    return YourTeam.fromMap(id, (s.value as Map).cast<String, dynamic>());
  }

  @override
  Future<void> upsertFromMatch(
      String uid, {
        required String name,
        DateTime? playedAt,
        String? logoUrl,
      }) async {
    final id = YourTeam.idFromName(name);
    final ref = _root(uid).child(id);

    final existing = await ref.get();
    int matches = 0;
    if (existing.exists && existing.value is Map) {
      final m = (existing.value as Map).cast<String, dynamic>();
      matches = (m['matchesCount'] as num?)?.toInt() ?? 0;
    }

    await ref.update({
      'name': name.trim(),
      if (logoUrl != null && logoUrl.isNotEmpty) 'logoUrl': logoUrl,
      'lastPlayedAt': (playedAt ?? DateTime.now()).millisecondsSinceEpoch,
      'matchesCount': matches + 1,
      'name_lc': name.trim().toLowerCase(),
    });
  }

  @override
  Future<String> uploadLogo(
      String uid, {
        required String teamId,
        required List<int> bytes,
        String contentType = 'image/jpeg',
      }) async {
    final clean = teamId.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final ref = storage.ref('users/$uid/team/$clean/logo.jpg');
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: contentType),
    );
    return await ref.getDownloadURL();
  }
}
