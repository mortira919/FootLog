import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footlog/domain/profile/entities/player_profile.dart';
import 'package:footlog/domain/profile/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _db;
  ProfileRepositoryImpl(this._db);

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('profile').doc('main');

  @override
  Future<PlayerProfile?> getProfile(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return PlayerProfile.fromJson(snap.data()!);
  }

  @override
  Future<void> saveProfile(String uid, PlayerProfile p) async {
    // Готовим основную «новую» схему
    final data = p.toJson();

    // Совместимость со старым Home (ничего не ломаем):
    // - пишем primaryPosition
    // - в positions гарантируем наличие текущей позиции
    data['primaryPosition'] = p.position;
    data['positions'] = FieldValue.arrayUnion([p.position]);

    // Служебное поле
    data['updatedAt'] = FieldValue.serverTimestamp();

    // merge: частичное обновление без затирания
    await _doc(uid).set(data, SetOptions(merge: true));
  }
}
