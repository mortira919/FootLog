import 'package:footlog/domain/home/entities/recent_match.dart';
import 'package:footlog/domain/matches/entities/match_item.dart';

abstract class MatchesRepository {
  // write-операции
  Future<String> addMatch(String uid, MatchItem m);   // -> matchId
  Future<void> updateMatch(String uid, MatchItem m);  // по m.id
  Future<void> deleteMatch(String uid, String matchId);

  // read для Home (у тебя уже используется)
  Future<List<RecentMatch>> getRecentMatches(String uid, {int limit = 5});
}
