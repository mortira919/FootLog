import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footlog/domain/home/entities/recent_match.dart';
import 'package:footlog/domain/home/enums/outcome.dart';
import 'package:footlog/domain/home/repositories/matches_repository.dart';

class HomeMatchesRepositoryImpl implements MatchesRepository {
  final FirebaseFirestore db;
  HomeMatchesRepositoryImpl(this.db);

  @override
  Future<List<RecentMatch>> getRecentMatches(String uid, {int limit = 5}) async {
    final qs = await db
        .collection('users').doc(uid)
        .collection('matches')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    Outcome _outcome(dynamic v) {
      final s = (v is String ? v : v?.toString() ?? '').toLowerCase();
      return switch (s) {
        'win'  => Outcome.win,
        'loss' => Outcome.loss,
        'draw' => Outcome.draw,
        _      => Outcome.draw,
      };
    }

    DateTime _date(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int)       return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.parse(v as String);
    }

    int _i(dynamic v) => v is num ? v.toInt() : 0;
    String _s(dynamic v) => (v is String) ? v : (v ?? '').toString();

    return qs.docs.map((d) {
      final m = d.data();
      return RecentMatch(
        id: d.id,
        date: _date(m['date']),
        yourTeam: _s(m['yourTeam']),
        opponentTeam: _s(m['opponentTeam']),
        yourGoals: _i(m['yourGoals']),
        opponentGoals: _i(m['opponentGoals']),
        outcome: _outcome(m['outcome']),
        opponentLogoUrl: m['opponentLogoUrl'] as String?,
        yourLogoUrl:     m['yourLogoUrl']     as String?,
      );
    }).toList();
  }
}
