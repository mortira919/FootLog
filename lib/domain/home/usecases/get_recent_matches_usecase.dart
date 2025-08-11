// lib/domain/home/usecases/get_recent_matches_usecase.dart
import 'package:footlog/core/my_result.dart';
import 'package:footlog/domain/home/repositories/matches_repository.dart';
import 'package:footlog/domain/home/entities/recent_match.dart';

class GetRecentMatchesUseCase {
  final MatchesRepository repo;
  GetRecentMatchesUseCase(this.repo);

  Future<MyResult<List<RecentMatch>>> call({
    required String uid,
    int limit = 5,
  }) async {
    try {
      final list = await repo.getRecentMatches(uid, limit: limit);
      return Success(list);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
