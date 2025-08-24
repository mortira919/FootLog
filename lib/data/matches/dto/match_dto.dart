import 'package:cloud_firestore/cloud_firestore.dart';

/// Каноничный формат хранения матча в Firestore.
/// Коллекция: users/{uid}/matches/{matchId}
class MatchDto {
  final String? id;
  final Timestamp date;          // начало матча
  final int durationMin;         // длительность (мин)
  final String yourTeam;
  final String opponentTeam;
  final int yourGoals;
  final int opponentGoals;

  // ПОЛЯ ПОЗИЦИИ УДАЛЕНЫ (позиция хранится в профиле игрока)

  /// 'natural' | 'artificial' | 'indoor'
  final String fieldType;

  /// 'sunny' | 'cloudy' | 'rainSnow'
  final String weather;

  /// 'win' | 'loss' | 'draw'
  final String outcome;

  /// URL логотипа соперника (может быть null)
  final String? opponentLogoUrl;

  /// личная статистика игрока (всегда лежит в доке, по умолчанию 0)
  final int myGoals;
  final int myAssists;
  final int myTackles;
  final int myInterceptions;
  final int mySaves;

  final Timestamp? updatedAt;

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
    this.opponentLogoUrl,
    this.myGoals = 0,
    this.myAssists = 0,
    this.myTackles = 0,
    this.myInterceptions = 0,
    this.mySaves = 0,
    this.updatedAt,
  });

  factory MatchDto.fromJson(String id, Map<String, dynamic> j) => MatchDto(
    id: id,
    date: j['date'] as Timestamp,
    durationMin: (j['durationMin'] as num?)?.toInt() ?? 90,
    yourTeam: (j['yourTeam'] ?? '') as String,
    opponentTeam: (j['opponentTeam'] ?? '') as String,
    yourGoals: (j['yourGoals'] as num?)?.toInt() ?? 0,
    opponentGoals: (j['opponentGoals'] as num?)?.toInt() ?? 0,

    // position/positionInMatch могут быть в старых документах — просто игнорируем

    fieldType: (j['fieldType'] ?? 'natural') as String,
    weather: (j['weather'] ?? 'sunny') as String,
    outcome: (j['outcome'] ?? 'draw') as String,

    opponentLogoUrl: j['opponentLogoUrl'] as String?,

    myGoals: (j['myGoals'] as num?)?.toInt() ?? 0,
    myAssists: (j['myAssists'] as num?)?.toInt() ?? 0,
    myTackles: (j['myTackles'] as num?)?.toInt() ?? 0,
    myInterceptions: (j['myInterceptions'] as num?)?.toInt() ?? 0,
    mySaves: (j['mySaves'] as num?)?.toInt() ?? 0,

    updatedAt: j['updatedAt'] as Timestamp?,
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'durationMin': durationMin,
    'yourTeam': yourTeam,
    'opponentTeam': opponentTeam,
    'yourGoals': yourGoals,
    'opponentGoals': opponentGoals,
    // позицию больше НЕ пишем
    'fieldType': fieldType,
    'weather': weather,
    'outcome': outcome,
    if (opponentLogoUrl != null) 'opponentLogoUrl': opponentLogoUrl,

    'myGoals': myGoals,
    'myAssists': myAssists,
    'myTackles': myTackles,
    'myInterceptions': myInterceptions,
    'mySaves': mySaves,

    'updatedAt': FieldValue.serverTimestamp(),
  };
}
