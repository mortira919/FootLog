import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footlog/domain/home/enums/outcome.dart';
import 'package:footlog/domain/matches/enums/field_type.dart';
import 'package:footlog/domain/matches/enums/weather.dart';

class MatchItem {
  final String? id;

  final String? yourLogoUrl;

  final String? opponentLogoUrl;

  final DateTime date;
  final int durationMin;
  final String yourTeam;
  final String opponentTeam;
  final int yourGoals;
  final int opponentGoals;
  final FieldType fieldType;
  final Weather weather;
  final Outcome outcome;


  final int? myGoals;
  final int? myAssists;
  final int? myTackles;
  final int? myInterceptions;
  final int? mySaves;

  const MatchItem({
    this.id,
    this.yourLogoUrl,
    this.opponentLogoUrl,
    required this.date,
    required this.durationMin,
    required this.yourTeam,
    required this.opponentTeam,
    required this.yourGoals,
    required this.opponentGoals,
    required this.fieldType,
    required this.weather,
    required this.outcome,
    this.myGoals,
    this.myAssists,
    this.myTackles,
    this.myInterceptions,
    this.mySaves,
  });

  MatchItem copyWith({
    String? id,
    String? yourLogoUrl,
    String? opponentLogoUrl,
    DateTime? date,
    int? durationMin,
    String? yourTeam,
    String? opponentTeam,
    int? yourGoals,
    int? opponentGoals,
    FieldType? fieldType,
    Weather? weather,
    Outcome? outcome,
    int? myGoals,
    int? myAssists,
    int? myTackles,
    int? myInterceptions,
    int? mySaves,
  }) {
    return MatchItem(
      id: id ?? this.id,
      yourLogoUrl: yourLogoUrl ?? this.yourLogoUrl,
      opponentLogoUrl: opponentLogoUrl ?? this.opponentLogoUrl,
      date: date ?? this.date,
      durationMin: durationMin ?? this.durationMin,
      yourTeam: yourTeam ?? this.yourTeam,
      opponentTeam: opponentTeam ?? this.opponentTeam,
      yourGoals: yourGoals ?? this.yourGoals,
      opponentGoals: opponentGoals ?? this.opponentGoals,
      fieldType: fieldType ?? this.fieldType,
      weather: weather ?? this.weather,
      outcome: outcome ?? this.outcome,
      myGoals: myGoals ?? this.myGoals,
      myAssists: myAssists ?? this.myAssists,
      myTackles: myTackles ?? this.myTackles,
      myInterceptions: myInterceptions ?? this.myInterceptions,
      mySaves: mySaves ?? this.mySaves,
    );
  }


  Map<String, dynamic> toMap() => {
    'date': Timestamp.fromDate(date),
    'durationMin': durationMin,
    'yourTeam': yourTeam.trim(),
    'opponentTeam': opponentTeam.trim(),
    'yourGoals': yourGoals,
    'opponentGoals': opponentGoals,
    'fieldType': fieldType.name,
    'weather': weather.name,
    'outcome': outcome.name,
    if (yourLogoUrl != null) 'yourLogoUrl': yourLogoUrl,
    if (opponentLogoUrl != null) 'opponentLogoUrl': opponentLogoUrl,


    if (myGoals != null) 'myGoals': myGoals,
    if (myAssists != null) 'myAssists': myAssists,
    if (myTackles != null) 'myTackles': myTackles,
    if (myInterceptions != null) 'myInterceptions': myInterceptions,
    if (mySaves != null) 'mySaves': mySaves,
  };


  factory MatchItem.fromMap(Map<String, dynamic> m, {String? id}) {
    final dynamic rawDate = m['date'];
    final DateTime parsedDate = rawDate is Timestamp
        ? rawDate.toDate()
        : rawDate is int
        ? DateTime.fromMillisecondsSinceEpoch(rawDate)
        : DateTime.parse(rawDate as String);

    String readEnum(dynamic v) => v is String ? v : v.toString();
    int _readInt(dynamic v, [int def = 0]) => v == null ? def : (v as num).toInt();

    return MatchItem(
      id: id,
      yourLogoUrl: m['yourLogoUrl'] as String?,
      opponentLogoUrl: m['opponentLogoUrl'] as String?,
      date: parsedDate,
      durationMin: _readInt(m['durationMin'], 90),
      yourTeam: (m['yourTeam'] as String?)?.trim() ?? '',
      opponentTeam: (m['opponentTeam'] as String?)?.trim() ?? '',
      yourGoals: _readInt(m['yourGoals']),
      opponentGoals: _readInt(m['opponentGoals']),
      fieldType: FieldType.values.byName(readEnum(m['fieldType'])),
      weather: Weather.values.byName(readEnum(m['weather'])),
      outcome: Outcome.values.byName(readEnum(m['outcome'])),
      myGoals: _readInt(m['myGoals']),
      myAssists: _readInt(m['myAssists']),
      myTackles: _readInt(m['myTackles']),
      myInterceptions: _readInt(m['myInterceptions']),
      mySaves: _readInt(m['mySaves']),
    );
  }


  factory MatchItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      MatchItem.fromMap(doc.data()!, id: doc.id);
}
