import 'package:footlog/domain/stats/repositories/stats_repository.dart';

class StatsRepositoryMock implements StatsRepository {
  @override
  Future<StatsBundle> monthly(String uid, {int months = 6}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final labels = <String>[];
    final matches = <int>[];
    final goals = <int>[];
    final assists = <int>[];
    final interceptions = <int>[];
    final tackles = <int>[];
    final saves = <int>[];

    final base = [10, 5, 8, 6, 7, 9, 4, 11, 3, 12, 2, 13];
    for (int i = 0; i < months; i++) {
      final v = base[i % base.length];
      labels.add('M${i + 1}');
      matches.add(v);
      goals.add((v * 0.5).round());
      assists.add((v * 0.33).round());
      interceptions.add((v * 0.25).round());
      tackles.add((v * 0.2).round());
      saves.add((v * 0.18).round());
    }

    return StatsBundle(
      labels: labels,
      matches: matches,
      goals: goals,
      assists: assists,
      interceptions: interceptions,
      tackles: tackles,
      saves: saves,
    );
  }
}
