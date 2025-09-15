import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:footlog/domain/matches/repositories/matches_repository.dart';
import 'package:footlog/domain/matches/entities/match_item.dart';
import 'package:footlog/domain/matches/enums/field_type.dart';
import 'package:footlog/domain/matches/enums/weather.dart';

import 'package:footlog/domain/home/entities/recent_match.dart';
import 'package:footlog/domain/home/enums/outcome.dart';

import '../dto/match_dto.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  final FirebaseFirestore db;
  MatchesRepositoryImpl(this.db);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      db.collection('users').doc(uid).collection('matches');


  String _fieldToStr(FieldType f) => f.name;
  FieldType _fieldFrom(String s) =>
      FieldType.values.firstWhere((e) => e.name == s, orElse: () => FieldType.natural);

  String _weatherToStr(Weather w) => w.name;
  Weather _weatherFrom(String s) =>
      Weather.values.firstWhere((e) => e.name == s, orElse: () => Weather.sunny);

  String _outcomeToStr(Outcome o) => o.name;
  Outcome _outcomeFrom(String s) =>
      Outcome.values.firstWhere((e) => e.name == s, orElse: () => Outcome.draw);


  MatchDto _toDto(MatchItem m) => MatchDto(
    id: m.id,
    date: Timestamp.fromDate(m.date),
    durationMin: m.durationMin,
    yourTeam: m.yourTeam,
    opponentTeam: m.opponentTeam,
    yourGoals: m.yourGoals,
    opponentGoals: m.opponentGoals,
    fieldType: _fieldToStr(m.fieldType),
    weather: _weatherToStr(m.weather),
    outcome: _outcomeToStr(m.outcome),
    yourLogoUrl: m.yourLogoUrl,
    opponentLogoUrl: m.opponentLogoUrl,
    myGoals: m.myGoals ?? 0,
    myAssists: m.myAssists ?? 0,
    myTackles: m.myTackles ?? 0,
    myInterceptions: m.myInterceptions ?? 0,
    mySaves: m.mySaves ?? 0,
  );

  MatchItem _toDomain(MatchDto d) => MatchItem(
    id: d.id,
    date: d.date.toDate(),
    durationMin: d.durationMin,
    yourTeam: d.yourTeam,
    opponentTeam: d.opponentTeam,
    yourGoals: d.yourGoals,
    opponentGoals: d.opponentGoals,
    fieldType: _fieldFrom(d.fieldType),
    weather: _weatherFrom(d.weather),
    outcome: _outcomeFrom(d.outcome),
    yourLogoUrl: d.yourLogoUrl,
    opponentLogoUrl: d.opponentLogoUrl,
    myGoals: d.myGoals,
    myAssists: d.myAssists,
    myTackles: d.myTackles,
    myInterceptions: d.myInterceptions,
    mySaves: d.mySaves,
  );


  @override
  Future<String> addMatch(String uid, MatchItem m) async {
    final dto = _toDto(m);
    final ref = await _col(uid).add(dto.toJson());
    return ref.id;
  }

  @override
  Future<void> updateMatch(String uid, MatchItem m) async {
    if (m.id == null) throw Exception('updateMatch: id is null');
    final dto = _toDto(m);
    await _col(uid).doc(m.id!).set(dto.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteMatch(String uid, String matchId) {
    return _col(uid).doc(matchId).delete();
  }


  @override
  Future<List<RecentMatch>> getRecentMatches(String uid, {int limit = 5}) async {
    final snap = await _col(uid).orderBy('date', descending: true).limit(limit).get();

    return snap.docs.map((d) {
      final dto = MatchDto.fromJson(d.id, d.data());

      final you = dto.yourGoals;
      final opp = dto.opponentGoals;
      final out = you == opp ? Outcome.draw : (you > opp ? Outcome.win : Outcome.loss);

      return RecentMatch(
        id: d.id,
        date: dto.date.toDate(),
        yourTeam: dto.yourTeam,
        opponentTeam: dto.opponentTeam,
        yourGoals: you,
        opponentGoals: opp,
        outcome: out,
        yourLogoUrl: dto.yourLogoUrl,
        opponentLogoUrl: dto.opponentLogoUrl,
      );
    }).toList();
  }
}
