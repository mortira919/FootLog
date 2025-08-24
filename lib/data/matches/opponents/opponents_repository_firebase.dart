import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:footlog/domain/matches/entities/opponent.dart';
import 'package:footlog/domain/matches/repositories/opponents_repository.dart';

class OpponentsRepositoryFirebase implements IOpponentsRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  OpponentsRepositoryFirebase(this._db, this._storage);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('opponents');

  @override
  Future<List<Opponent>> getRecent(String uid, {int limit = 20}) async {
    final q = await _col(uid)
        .orderBy('lastPlayedAt', descending: true)
        .limit(limit)
        .get();
    return q.docs.map((d) => Opponent.fromMap(d.id, d.data())).toList(growable: false);
  }

  @override
  Future<Opponent?> getById(String uid, String id) async {
    final snap = await _col(uid).doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return Opponent.fromMap(snap.id, snap.data()!);
  }

  @override
  Future<void> upsertFromMatch(
      String uid, {
        required String name,
        DateTime? playedAt,
        String? logoUrl,
      }) async {
    final id = Opponent.idFromName(name);
    final ref = _col(uid).doc(id);

    await _db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final ts = (playedAt ?? DateTime.now()).millisecondsSinceEpoch;

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final cnt = (data['matchesCount'] as num?)?.toInt() ?? 0;
        final currentLogo = data['logoUrl'] as String?;
        tx.update(ref, {
          'name': name.trim(),
          'lastPlayedAt': ts,
          'matchesCount': cnt + 1,
          if (logoUrl != null && (currentLogo == null || currentLogo.isEmpty))
            'logoUrl': logoUrl,
          'name_lc': name.toLowerCase(),
        });
      } else {
        tx.set(ref, {
          'name': name.trim(),
          'logoUrl': logoUrl,
          'lastPlayedAt': ts,
          'matchesCount': 1,
          'name_lc': name.toLowerCase(),
        });
      }
    });
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
