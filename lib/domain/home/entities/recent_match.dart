import '../../home/enums/outcome.dart';

class RecentMatch {
  final DateTime date;
  final String opponent;
  final String score; // напр. "2:1"
  final Outcome outcome;

  const RecentMatch({
    required this.date,
    required this.opponent,
    required this.score,
    required this.outcome,
  });
}
