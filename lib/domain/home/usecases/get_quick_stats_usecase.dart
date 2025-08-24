import 'package:footlog/core/my_result.dart';
import 'package:footlog/domain/home/entities/quick_stats.dart';
import 'package:footlog/domain/home/enums/period.dart';
import 'package:footlog/domain/stats/repositories/stats_repository.dart' as perf;

class GetQuickStatsUseCase {
  final perf.StatsRepository _repo;
  GetQuickStatsUseCase(this._repo);

  Future<MyResult<QuickStats>> call({
    required String uid,
    required Period period,
  }) async {
    try {
      final months = switch (period) {
        Period.m1 => 1, Period.m6 => 6, Period.m12 => 12
      };

      final bundle = await _repo.monthly(uid, months: months);

      int sum(List<int> xs) => xs.fold(0, (a, b) => a + b);

      final quick = QuickStats(
        matches:       sum(bundle.matches),
        goals:         sum(bundle.goals),
        assists:       sum(bundle.assists),
        interceptions: sum(bundle.interceptions),
        tackles:       sum(bundle.tackles),
      );

      return Success(quick);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
