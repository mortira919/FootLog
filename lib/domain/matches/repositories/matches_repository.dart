import 'package:footlog/domain/home/entities/recent_match.dart';
import 'package:footlog/domain/matches/entities/match_item.dart';

abstract class MatchesRepository {

  Future<String> addMatch(String uid, MatchItem m);
  Future<void> updateMatch(String uid, MatchItem m);
  Future<void> deleteMatch(String uid, String matchId);


  Future<List<RecentMatch>> getRecentMatches(String uid, {int limit = 5});
}
