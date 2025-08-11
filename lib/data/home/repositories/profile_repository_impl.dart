import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footlog/domain/home/entities/player_profile.dart';

import 'package:footlog/data/home/dto/player_profile_dto.dart';

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
    // наши enum значения UPPER_CASE: GK, CB, ...
    return Position.values.firstWhere(
          (p) => p.name.toUpperCase() == s.toUpperCase(),
      orElse: () => Position.ST,
    );
  }

  String _toString(Position p) => p.name.toUpperCase();

  @override
  Future<PlayerProfile> getProfile(String uid) async {
    final snap = await _doc(uid).get();

    if (!snap.exists || snap.data() == null) {
      // Первый запуск — создаём дефолт
      final defaultDto = PlayerProfileDto(
        name: 'Имя Фамилия',
        primaryPosition: 'ST',
        positions: const ['ST'],
      );
      await _doc(uid).set(defaultDto.toJson());
      return PlayerProfile(
        name: defaultDto.name,
        primaryPosition: Position.ST,
        positions: const [Position.ST],
      );
    }

    final dto = PlayerProfileDto.fromJson(snap.data()!);
    return PlayerProfile(
      name: dto.name,
      primaryPosition: _fromString(dto.primaryPosition),
      positions: dto.positions.map(_fromString).toList(),
    );
  }

  @override
  Future<void> saveProfile(String uid, PlayerProfile profile) async {
    final dto = PlayerProfileDto(
      name: profile.name,
      primaryPosition: _toString(profile.primaryPosition),
      positions: profile.positions.map(_toString).toList(),
    );
    await _doc(uid).set(dto.toJson(), SetOptions(merge: true));
  }
}
