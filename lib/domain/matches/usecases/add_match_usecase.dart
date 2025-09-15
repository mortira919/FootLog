import 'package:footlog/core/my_result.dart';
import 'package:footlog/domain/home/enums/outcome.dart';
import 'package:footlog/domain/matches/entities/match_item.dart';
import 'package:footlog/domain/matches/repositories/matches_repository.dart';

class AddMatchUseCase {
  final MatchesRepository repo;
  AddMatchUseCase(this.repo);

  Future<MyResult<String>> call(String uid, MatchItem m) async {
    try {

      if (m.durationMin < 10 || m.durationMin > 180) {
        return const Error('Длительность должна быть 10–180 мин');
      }
      if (m.yourGoals < 0 || m.opponentGoals < 0) {
        return const Error('Голы не могут быть отрицательными');
      }


      final Outcome out = m.yourGoals == m.opponentGoals
          ? Outcome.draw
          : (m.yourGoals > m.opponentGoals ? Outcome.win : Outcome.loss);

      final fixed = m.copyWith(outcome: out);
      final id = await repo.addMatch(uid, fixed);
      return Success(id);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
