import 'package:footlog/domain/home/repositories/matches_repository.dart' as home;
import 'package:footlog/domain/matches/repositories/matches_repository.dart' as matches;
import 'package:footlog/domain/home/entities/recent_match.dart';

class HomeMatchesRepositoryAdapter implements home.MatchesRepository {
  final matches.MatchesRepository inner;
  HomeMatchesRepositoryAdapter(this.inner);

  @override
  Future<List<RecentMatch>> getRecentMatches(String uid, {int limit = 5}) {

    return inner.getRecentMatches(uid, limit: limit);
  }
}
