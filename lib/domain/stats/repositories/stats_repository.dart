abstract class StatsRepository {
  /// Возвращает агрегаты за последние [months] месяцев (включая текущий),
  /// в хронологическом порядке: самый старый → текущий.
  Future<StatsBundle> monthly(String uid, {int months = 6});
}

class StatsBundle {
  final List<String> labels;       // ['Янв','Фев',...]
  final List<int> matches;         // кол-во матчей
  final List<int> goals;           // мои голы
  final List<int> assists;         // мои ассисты
  final List<int> interceptions;   // мои перехваты
  final List<int> tackles;         // мои отборы
  StatsBundle({
    required this.labels,
    required this.matches,
    required this.goals,
    required this.assists,
    required this.interceptions,
    required this.tackles,
  });
}
