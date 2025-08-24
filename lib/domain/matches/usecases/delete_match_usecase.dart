import 'package:footlog/core/my_result.dart';
import 'package:footlog/domain/matches/repositories/matches_repository.dart';

class DeleteMatchUseCase {
  final MatchesRepository repo;
  DeleteMatchUseCase(this.repo);

  Future<MyResult<void>> call(String uid, String matchId) async {
    try {
      await repo.deleteMatch(uid, matchId);
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
