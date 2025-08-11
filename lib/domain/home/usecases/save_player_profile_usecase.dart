// lib/domain/home/usecases/save_player_profile_usecase.dart
import 'package:footlog/core/my_result.dart';
import 'package:footlog/domain/home/entities/player_profile.dart';

import '../repositories/profile_repositories.dart';


class SavePlayerProfileUseCase {
  final ProfileRepository repo;
  SavePlayerProfileUseCase(this.repo);

  Future<MyResult<void>> call({
    required String uid,
    required PlayerProfile profile,
  }) async {
    try {
      await repo.saveProfile(uid, profile);
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
