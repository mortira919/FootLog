import 'package:footlog/domain/home/enums/outcome.dart';

class RecentMatch {
  final String id;
  final DateTime date;
  final String yourTeam;
  final String opponentTeam;
  final int yourGoals;
  final int opponentGoals;
  final Outcome outcome;

  final String? opponentLogoUrl;

  final String? yourLogoUrl;

  const RecentMatch({
    required this.id,
    required this.date,
    required this.yourTeam,
    required this.opponentTeam,
    required this.yourGoals,
    required this.opponentGoals,
    required this.outcome,
    this.opponentLogoUrl,
    this.yourLogoUrl,
  });

  RecentMatch copyWith({
    String? id,
    DateTime? date,
    String? yourTeam,
    String? opponentTeam,
    int? yourGoals,
    int? opponentGoals,
    Outcome? outcome,
    String? opponentLogoUrl,
    String? yourLogoUrl,
  }) {
    return RecentMatch(
      id: id ?? this.id,
      date: date ?? this.date,
      yourTeam: yourTeam ?? this.yourTeam,
      opponentTeam: opponentTeam ?? this.opponentTeam,
      yourGoals: yourGoals ?? this.yourGoals,
      opponentGoals: opponentGoals ?? this.opponentGoals,
      outcome: outcome ?? this.outcome,
      opponentLogoUrl: opponentLogoUrl ?? this.opponentLogoUrl,
      yourLogoUrl: yourLogoUrl ?? this.yourLogoUrl,
    );
  }
}
