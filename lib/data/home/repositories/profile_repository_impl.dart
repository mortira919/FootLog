import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footlog/domain/home/entities/player_profile.dart';

import '../../../domain/home/enums/positions.dart';
import '../../../domain/home/repositories/profile_repositories.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore db;
  ProfileRepositoryImpl(this.db);

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      db.collection('users').doc(uid).collection('profile');

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _collection(uid).doc('main');

  // -- mapping helpers
  Position _fromString(String s) {
    return Position.values.firstWhere(
          (p) => p.name.toUpperCase() == s.toUpperCase(),
      orElse: () => Position.ST,
    );
  }

  String _toString(Position p) => p.name.toUpperCase();

  @override
  Future<PlayerProfile> getProfile(String uid) async {
    final snap = await _doc(uid).get();
    final data = snap.data();

    // Если профиля ещё нет — создаём дефолт СРАЗУ в обоих форматах
    if (data == null) {
      final pos = 'ST';
      await _doc(uid).set({
        'name': 'Имя Фамилия',
        // старый формат для Home:
        'primaryPosition': pos,
        'positions': [pos],
        // новое поле, которое пишет экран редактирования:
        'position': pos,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const PlayerProfile(
        name: 'Имя Фамилия',
        primaryPosition: Position.ST,
        positions: [Position.ST],
      );
    }

    // --- ЧТЕНИЕ С УЧЁТОМ ОБОИХ ФОРМАТОВ ---
    final name = (data['name'] ?? 'Имя Фамилия') as String;

    // 1) новое поле 'position' (от экрана редактирования)
    // 2) старое поле 'primaryPosition'
    // 3) первый элемент из массива 'positions'
    var posStr = (data['position'] ?? data['primaryPosition'] ?? '') as String;
    if (posStr.isEmpty) {
      final arr = data['positions'];
      if (arr is List && arr.isNotEmpty && arr.first is String) {
        posStr = arr.first as String;
      }
    }
    if (posStr.isEmpty) posStr = 'ST';

    final listRaw = (data['positions'] as List?)?.cast<String>() ?? <String>[posStr];
    final positions = listRaw.map(_fromString).toList();

    return PlayerProfile(
      name: name,
      primaryPosition: _fromString(posStr),
      positions: positions,
    );
  }

  @override
  Future<void> saveProfile(String uid, PlayerProfile profile) async {
    final primary = _toString(profile.primaryPosition);
    final list = profile.positions.map(_toString).toList();

    // Пишем и старые, и новые поля, чтобы оба экрана были счастливы.
    await _doc(uid).set({
      'name': profile.name,
      // старый формат, который уже использует Home:
      'primaryPosition': primary,
      'positions': list,
      // новое поле, которое использует экран редактирования:
      'position': primary,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
