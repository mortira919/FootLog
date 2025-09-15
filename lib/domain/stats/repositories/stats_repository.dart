abstract class StatsRepository {

  Future<StatsBundle> monthly(String uid, {int months = 6});
}

class StatsBundle {
  final List<String> labels;
  final List<int> matches;
  final List<int> goals;
  final List<int> assists;
  final List<int> interceptions;
  final List<int> tackles;
  final List<int> saves;

  StatsBundle({
    required this.labels,
    required this.matches,
    required this.goals,
    required this.assists,
    required this.interceptions,
    required this.tackles,
    required this.saves,
  });
}
