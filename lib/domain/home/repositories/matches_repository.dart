import '../entities/recent_match.dart';

abstract class MatchesRepository {
  Future<List<RecentMatch>> getRecentMatches(String uid, {int limit = 5});
}
