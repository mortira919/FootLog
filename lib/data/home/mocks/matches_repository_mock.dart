import 'dart:async';
import 'package:footlog/domain/home/entities/recent_match.dart';
import 'package:footlog/domain/home/enums/outcome.dart';
import 'package:footlog/domain/home/repositories/matches_repository.dart';

class MatchesRepositoryMock implements MatchesRepository {
  @override
  Future<List<RecentMatch>> getRecentMatches(String uid, {int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      RecentMatch(date: now.subtract(const Duration(days: 1)),  opponent: 'Название 4', score: '3:1', outcome: Outcome.win),
      RecentMatch(date: now.subtract(const Duration(days: 4)),  opponent: 'Название 3', score: '1:2', outcome: Outcome.loss),
      RecentMatch(date: now.subtract(const Duration(days: 7)),  opponent: 'Название 4', score: '2:2', outcome: Outcome.draw),
      RecentMatch(date: now.subtract(const Duration(days: 11)), opponent: 'Название 3', score: '1:0', outcome: Outcome.win),
      RecentMatch(date: now.subtract(const Duration(days: 14)), opponent: 'Название 3', score: '0:1', outcome: Outcome.loss),
    ];
  }
}
