import 'dart:async';
import 'package:footlog/domain/home/entities/player_profile.dart';

import '../../../domain/home/enums/positions.dart';
import '../../../domain/home/repositories/profile_repositories.dart';

class ProfileRepositoryMock implements ProfileRepository {
  PlayerProfile _profile = const PlayerProfile(
    name: 'Имя Фамилия',
    primaryPosition: Position.ST,
    positions: [Position.ST, Position.RW, Position.LW],
  );

  @override
  Future<PlayerProfile> getProfile(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profile;
  }

  @override
  Future<void> saveProfile(String uid, PlayerProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _profile = profile;
  }
}
