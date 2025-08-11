// lib/domain/home/usecases/get_player_profile_usecase.dart
import 'package:footlog/core/my_result.dart';
import 'package:footlog/domain/home/entities/player_profile.dart';

import '../repositories/profile_repositories.dart';

class GetPlayerProfileUseCase {
  final ProfileRepository repo;
  GetPlayerProfileUseCase(this.repo);

  Future<MyResult<PlayerProfile>> call(String uid) async {
    try {
      final profile = await repo.getProfile(uid);
      return Success(profile);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
