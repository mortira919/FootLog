import 'package:footlog/core/my_result.dart';
import 'package:footlog/domain/home/enums/outcome.dart';
import 'package:footlog/domain/matches/entities/match_item.dart';
import 'package:footlog/domain/matches/repositories/matches_repository.dart';

class UpdateMatchUseCase {
  final MatchesRepository repo;
  UpdateMatchUseCase(this.repo);

  Future<MyResult<void>> call(String uid, MatchItem m) async {
    try {
      if (m.id == null) return const Error('Не задан id матча');

      final Outcome out = m.yourGoals == m.opponentGoals
          ? Outcome.draw
          : (m.yourGoals > m.opponentGoals ? Outcome.win : Outcome.loss);

      final fixed = m.copyWith(outcome: out);
      await repo.updateMatch(uid, fixed);
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
