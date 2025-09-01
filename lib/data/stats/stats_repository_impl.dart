import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footlog/data/matches/dto/match_dto.dart';
import 'package:footlog/domain/stats/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final FirebaseFirestore db;
  StatsRepositoryImpl(this.db);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      db.collection('users').doc(uid).collection('matches');

  @override
  Future<StatsBundle> monthly(String uid, {int months = 6}) async {
    final now = DateTime.now();
    final startMonth = DateTime(now.year, now.month - (months - 1), 1);
    final endExclusive = DateTime(now.year, now.month + 1, 1);

    final snap = await _col(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startMonth))
        .where('date', isLessThan: Timestamp.fromDate(endExclusive))
        .orderBy('date')
        .get();

    // подготовим 0-массивы
    final labels = <String>[];
    final matches = List<int>.filled(months, 0);
    final goals = List<int>.filled(months, 0);
    final assists = List<int>.filled(months, 0);
    final interceptions = List<int>.filled(months, 0);
    final tackles = List<int>.filled(months, 0);
    final saves = List<int>.filled(months, 0); // 👈

    // подписи месяцев
    const ruShort = ['Янв','Фев','Мар','Апр','Май','Июн','Июл','Авг','Сен','Окт','Ноя','Дек'];
    for (int i = 0; i < months; i++) {
      final m = DateTime(startMonth.year, startMonth.month + i, 1);
      labels.add(ruShort[m.month - 1]);
    }

    int indexOfMonth(DateTime d) {
      final diff = (d.year - startMonth.year) * 12 + (d.month - startMonth.month);
      return (diff >= 0 && diff < months) ? diff : -1;
    }

    for (final doc in snap.docs) {
      final dto = MatchDto.fromJson(doc.id, doc.data());
      final date = dto.date.toDate();
      final idx = indexOfMonth(date);
      if (idx == -1) continue;

      matches[idx] += 1;
      goals[idx] += dto.myGoals;
      assists[idx] += dto.myAssists;
      interceptions[idx] += dto.myInterceptions;
      tackles[idx] += dto.myTackles;
      saves[idx] += dto.mySaves; // 👈 счётчик сейвов
    }

    return StatsBundle(
      labels: labels,
      matches: matches,
      goals: goals,
      assists: assists,
      interceptions: interceptions,
      tackles: tackles,
      saves: saves, // 👈
    );
  }
}
