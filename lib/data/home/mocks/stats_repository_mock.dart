import 'package:footlog/domain/stats/repositories/stats_repository.dart';

class StatsRepositoryMock implements StatsRepository {
  @override
  Future<StatsBundle> monthly(String uid, {int months = 6}) async {
    // имитация задержки
    await Future.delayed(const Duration(milliseconds: 200));

    // сформируем months точек слева направо (старые -> новые)
    final labels = <String>[];
    final matches = <int>[];
    final goals = <int>[];
    final assists = <int>[];
    final interceptions = <int>[];
    final tackles = <int>[];

    // просто тестовые числа
    final base = [10, 5, 8, 6, 7, 9, 4, 11, 3, 12, 2, 13];
    for (int i = 0; i < months; i++) {
      labels.add('M${i+1}');
      matches.add(base[i % base.length]);
      goals.add((base[i % base.length] / 2).round());
      assists.add((base[i % base.length] / 3).round());
      interceptions.add((base[i % base.length] / 4).round());
      tackles.add((base[i % base.length] / 5).round());
    }

    return StatsBundle(
      labels: labels,
      matches: matches,
      goals: goals,
      assists: assists,
      interceptions: interceptions,
      tackles: tackles,
    );
  }
}
