import '../entities/quick_stats.dart';
import '../../home/enums/period.dart';

abstract class StatsRepository {
  Future<QuickStats> getQuickStats(String uid, Period period);
}
