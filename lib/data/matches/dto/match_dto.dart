import 'package:cloud_firestore/cloud_firestore.dart';

class MatchDto {
  final String? id;
  final Timestamp date;
  final int durationMin;
  final String yourTeam;
  final String opponentTeam;
  final int yourGoals;
  final int opponentGoals;
  final String fieldType;
  final String weather;
  final String outcome;

  // 👇 ЛОГОТИПЫ
  final String? yourLogoUrl;
  final String? opponentLogoUrl;

  // личная статистика
  final int myGoals;
  final int myAssists;
  final int myTackles;
  final int myInterceptions;
  final int mySaves;

  MatchDto({
    this.id,
    required this.date,
    required this.durationMin,
    required this.yourTeam,
    required this.opponentTeam,
    required this.yourGoals,
    required this.opponentGoals,
    required this.fieldType,
    required this.weather,
    required this.outcome,
    this.yourLogoUrl,
    this.opponentLogoUrl,
    this.myGoals = 0,
    this.myAssists = 0,
    this.myTackles = 0,
    this.myInterceptions = 0,
    this.mySaves = 0,
  });

  factory MatchDto.fromJson(String id, Map<String, dynamic> j) {
    DateTime _date(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.parse(v as String);
    }

    int _i(dynamic v) => v is num ? v.toInt() : 0;
    String _s(dynamic v) => (v is String) ? v : (v ?? '').toString();

    // приводим к Timestamp для единообразия
    final ts = j['date'] is Timestamp
        ? j['date'] as Timestamp
        : Timestamp.fromDate(_date(j['date']));

    return MatchDto(
      id: id,
      date: ts,
      durationMin: _i(j['durationMin']),
      yourTeam: _s(j['yourTeam']),
      opponentTeam: _s(j['opponentTeam']),
      yourGoals: _i(j['yourGoals']),
      opponentGoals: _i(j['opponentGoals']),
      fieldType: _s(j['fieldType']),
      weather: _s(j['weather']),
      outcome: _s(j['outcome']),
      yourLogoUrl: j['yourLogoUrl'] as String?,
      opponentLogoUrl: j['opponentLogoUrl'] as String?,
      myGoals: _i(j['myGoals']),
      myAssists: _i(j['myAssists']),
      myTackles: _i(j['myTackles']),
      myInterceptions: _i(j['myInterceptions']),
      mySaves: _i(j['mySaves']),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'durationMin': durationMin,
    'yourTeam': yourTeam,
    'opponentTeam': opponentTeam,
    'yourGoals': yourGoals,
    'opponentGoals': opponentGoals,
    'fieldType': fieldType,
    'weather': weather,
    'outcome': outcome,
    // 👇 ОБА URL СКЛАДЫВАЕМ
    if (yourLogoUrl != null) 'yourLogoUrl': yourLogoUrl,
    if (opponentLogoUrl != null) 'opponentLogoUrl': opponentLogoUrl,
    'myGoals': myGoals,
    'myAssists': myAssists,
    'myTackles': myTackles,
    'myInterceptions': myInterceptions,
    'mySaves': mySaves,
  };
}
