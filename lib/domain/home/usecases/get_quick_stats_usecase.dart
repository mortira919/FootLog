// lib/domain/home/usecases/get_quick_stats_usecase.dart
import 'package:footlog/core/my_result.dart';
import 'package:footlog/domain/home/repositories/stats_repository.dart';
import 'package:footlog/domain/home/entities/quick_stats.dart';
import 'package:footlog/domain/home/enums/period.dart';

class GetQuickStatsUseCase {
  final StatsRepository repo;
  GetQuickStatsUseCase(this.repo);

  Future<MyResult<QuickStats>> call({
    required String uid,
    required Period period,
  }) async {
    try {
      final stats = await repo.getQuickStats(uid, period);
      return Success(stats);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
