import 'dart:async';
import 'package:footlog/domain/home/enums/outcome.dart';
import 'package:footlog/domain/home/repositories/matches_repository.dart';

import '../../../domain/home/entities/recent_match.dart';

class MatchesRepositoryMock implements MatchesRepository {
  @override
  Future<List<RecentMatch>> getRecentMatches(String uid, {int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();

    final items = <RecentMatch>[
      RecentMatch(
        id: 'mock_1',
        date: now.subtract(const Duration(days: 1)),
        yourTeam: 'FootLog',
        opponentTeam: 'Eagles',
        yourGoals: 3,
        opponentGoals: 1,
        outcome: Outcome.win,
        opponentLogoUrl: null,
      ),
      RecentMatch(
        id: 'mock_2',
        date: now.subtract(const Duration(days: 4)),
        yourTeam: 'FootLog',
        opponentTeam: 'Wolves',
        yourGoals: 1,
        opponentGoals: 2,
        outcome: Outcome.loss,
        opponentLogoUrl: null,
      ),
      RecentMatch(
        id: 'mock_3',
        date: now.subtract(const Duration(days: 7)),
        yourTeam: 'FootLog',
        opponentTeam: 'Lions',
        yourGoals: 2,
        opponentGoals: 2,
        outcome: Outcome.draw,
        opponentLogoUrl: null,
      ),
      RecentMatch(
        id: 'mock_4',
        date: now.subtract(const Duration(days: 10)),
        yourTeam: 'FootLog',
        opponentTeam: 'Bulls',
        yourGoals: 2,
        opponentGoals: 1,
        outcome: Outcome.win,
        opponentLogoUrl: null,
      ),
      RecentMatch(
        id: 'mock_5',
        date: now.subtract(const Duration(days: 14)),
        yourTeam: 'FootLog',
        opponentTeam: 'Falcons',
        yourGoals: 0,
        opponentGoals: 1,
        outcome: Outcome.loss,
        opponentLogoUrl: null,
      ),
    ];

    return items.take(limit).toList();
  }
}